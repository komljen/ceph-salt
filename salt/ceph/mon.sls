# vi: set ft=yaml.jinja :

{% set cluster = salt['grains.get']('environment','ceph') %}
{% set host = salt['config.get']('host') %}
{% set ip = salt['config.get']('fqdn_ip4') %}
{% set keyring = '/etc/ceph/' + cluster + '.client.admin.keyring' %}
{% set secret = '/tmp/' + cluster + '.mon.keyring' %}
{% set monmap = '/tmp/' + cluster + 'monmap' %}
{% set nodes = salt['pillar.get']('nodes').iterkeys() %}
{% set mons = [] %}

{% for node in nodes %}

{% set is_mon = salt['pillar.get']('nodes:' + node + ':mon') %}

{% if is_mon == true %}
{% do mons.append(node) -%}
{% endif %}

{% endfor %}

include:
  - .ceph

/var/lib/ceph/mon/{{ cluster }}-{{ host }}:
  file.directory:
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: ceph

gen_mon_secret:
  cmd.run:
    - name: ceph-authtool --create-keyring {{ secret }} --gen-key -n mon. --cap mon 'allow *'
    - unless: test -f /var/lib/ceph/mon/{{ cluster }}-{{ host }}/keyring || test -f {{ secret }}

gen_admin_keyring:
  cmd.run:
    - name: ceph-authtool --create-keyring {{ keyring }} --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
    - unless: test -f /var/lib/ceph/mon/{{ cluster }}-{{ host }}/keyring || test -f {{ keyring }}

import_keyring:
  cmd.wait:
    - name: ceph-authtool {{ secret }} --import-keyring {{ keyring }}
    - unless: ceph-authtool {{ secret }} --list | grep '^\[client.admin\]'
    - watch:
      - cmd: gen_mon_secret
      - cmd: gen_admin_keyring

cp.push {{ keyring }}:
  module.wait:
    - name: cp.push
    - path: {{ keyring }}
    - watch:
      - cmd: gen_mon_secret

{% for mon in mons %}
cp.get_file {{mon}}{{ keyring }}:
  module.run:
    - name: cp.get_file
    - path: salt://{{ mon }}{{ keyring }}
    - dest: {{ keyring }}
{% endfor %}

