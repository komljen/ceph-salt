# vi: set ft=yaml.jinja :

{% import 'ceph/global_vars.jinja' as conf with context -%}

include:
  - .ceph

{{ conf.bootstrap_osd_keyring }}:
  cmd.run:
    - name: echo "Getting bootstrap OSD keyring"
    - unless: test -f {{ conf.bootstrap_osd_keyring }}

{% for mon in salt['mine.get']('roles:ceph-mon','grains.items','grain') -%}

cp.get_file {{ mon }}{{ conf.bootstrap_osd_keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ conf.bootstrap_osd_keyring }}
    - dest: {{ conf.bootstrap_osd_keyring }}
    - watch:
      - cmd: {{ conf.bootstrap_osd_keyring }}

{% endfor -%}

{% for osd in salt['pillar.get']('nodes:' + conf.host + ':osds') -%}
{% if osd -%}
{% set journal = salt['pillar.get']('nodes:' + conf.host + ':osds:' + osd + ':journal') -%}

disk_prepare {{ osd }}:
  cmd.run:
    - name: |
        ceph-disk prepare --cluster {{ conf.cluster }} \
                          --cluster-uuid {{ conf.fsid }} \
                          --fs-type xfs /dev/{{ osd }} /dev/{{ journal }}
    - unless: parted --script /dev/{{ osd }} print | grep 'ceph data'

{% endif -%}
{% endfor -%}

start ceph-osd-all:
  cmd.run:
    - onlyif: initctl list | grep "ceph-osd-all stop/waiting"
