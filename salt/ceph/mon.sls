# vi: set ft=yaml.jinja :

{% import 'ceph/global_vars.jinja' as conf with context -%}
{% set ip = salt['network.ip_addrs'](conf.mon_interface)[0] -%}
{% set secret = '/var/lib/ceph/tmp/' + conf.cluster + '.mon.keyring' -%}
{% set monmap = '/var/lib/ceph/tmp/' + conf.cluster + 'monmap' -%}

include:
  - .ceph

{{ conf.admin_keyring }}:
  cmd.run:
    - name: echo "Getting admin keyring"
    - unless: test -f {{ conf.admin_keyring }}

random_wait:
  cmd.run:
    - name: 'sleep $(( ( RANDOM % 7 ) + 2 ))'

{% for mon in salt['mine.get']('roles:ceph-mon','grains.items','grain') -%}

cp.get_file {{ mon }}{{ conf.admin_keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ conf.admin_keyring }}
    - dest: {{ conf.admin_keyring }}
    - watch:
      - cmd: {{ conf.admin_keyring }}

{% endfor -%}

get_mon_secret:
  cmd.run:
    - name: ceph --cluster {{ conf.cluster }} auth get mon. -o {{ secret }}
    - onlyif: test -f {{ conf.admin_keyring }}
    - unless: test -f {{ secret }}

get_mon_map:
  cmd.run:
    - name: ceph --cluster {{ conf.cluster }} mon getmap -o {{ monmap }}
    - onlyif: test -f {{ conf.admin_keyring }}
    - unless: test -f {{ monmap }}

gen_mon_secret:
  cmd.run:
    - name: |
        ceph-authtool --cluster {{ conf.cluster }} \
                      --create-keyring {{ secret }} \
                      --gen-key -n mon. \
                      --cap mon 'allow *'
    - unless: test -f /var/lib/ceph/mon/{{ conf.cluster }}-{{ conf.host }}/keyring || test -f {{ secret }}

gen_admin_keyring:
  cmd.run:
    - name: |
        ceph-authtool --cluster {{ conf.cluster }} \
                      --create-keyring {{ conf.admin_keyring }} \
                      --gen-key -n client.admin \
                      --set-uid=0 \
                      --cap mon 'allow *' \
                      --cap osd 'allow *' \
                      --cap mds 'allow'
    - unless: test -f /var/lib/ceph/mon/{{ conf.cluster }}-{{ conf.host }}/keyring || test -f {{ conf.admin_keyring }}

import_keyring:
  cmd.wait:
    - name: |
        ceph-authtool --cluster {{ conf.cluster }} {{ secret }} \
                      --import-keyring {{ conf.admin_keyring }}
    - unless: ceph-authtool {{ secret }} --list | grep '^\[client.admin\]'
    - watch:
      - cmd: gen_mon_secret
      - cmd: gen_admin_keyring

cp.push {{ conf.admin_keyring }}:
  module.wait:
    - name: cp.push
    - path: {{ conf.admin_keyring }}
    - watch:
      - cmd: gen_admin_keyring

gen_mon_map:
  cmd.run:
    - name: |
        monmaptool --cluster {{ conf.cluster }} \
                   --create \
                   --add {{ conf.host }} {{ ip }} \
                   --fsid {{ conf.fsid }} {{ monmap }}
    - unless: test -f {{ monmap }}

populate_mon:
  cmd.run:
    - name: |
        ceph-mon --cluster {{ conf.cluster }} \
                 --mkfs -i {{ conf.host }} \
                 --monmap {{ monmap }} \
                 --keyring {{ secret }}
    - unless: test -d /var/lib/ceph/mon/{{ conf.cluster }}-{{ conf.host }}

start_mon:
  cmd.run:
    - name: start ceph-mon id={{ conf.host }} cluster={{ conf.cluster }}
    - unless: status ceph-mon id={{ conf.host }} cluster={{ conf.cluster }}
    - require:
      - cmd: populate_mon

bootstrap_keyring_wait:
  cmd.wait:
    - name: |
        while [[ $(ls -1 /var/lib/ceph/bootstrap-* | grep {{ conf.cluster }}.keyring | wc -l) != 3 ]]; do sleep 0.2; done
    - timeout: 30
    - watch:
      - cmd: start_mon

{% for service in 'osd','mds','rgw' -%}

cp.push /var/lib/ceph/bootstrap-{{ service }}/{{ conf.cluster }}.keyring:
  module.wait:
    - name: cp.push
    - path: /var/lib/ceph/bootstrap-{{ service }}/{{ conf.cluster }}.keyring
    - watch:
      - cmd: bootstrap_keyring_wait

{% endfor -%}

/var/lib/ceph/mon/{{ conf.cluster }}-{{ conf.host }}/upstart:
  file.touch:
    - unless: test -f /var/lib/ceph/mon/{{ conf.cluster }}-{{ conf.host }}/upstart
