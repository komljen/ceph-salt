# vi: set ft=yaml.jinja :

{% set cluster = salt['grains.get']('environment','ceph') -%}
{% set fsid = salt['pillar.get']('ceph:global:fsid') -%}
{% set host = salt['config.get']('host') -%}
{% set bootstrap_osd_keyring = '/var/lib/ceph/bootstrap-osd/' + cluster + '.keyring' -%}
{% set keyring = '/var/lib/ceph/bootstrap-osd/' + cluster + '.keyring' -%}

include:
  - .ceph

{{ bootstrap_osd_keyring }}:
  cmd.run:
    - name: echo "Bootstrap OSD keyring doesn't exists"
    - unless: test -f {{ bootstrap_osd_keyring }}

{% for mon in salt['mine.get']('roles:ceph-mon','network.ip_addrs','grain' ) -%}

cp.get_file {{mon}}{{ bootstrap_osd_keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ bootstrap_osd_keyring }}
    - dest: {{ bootstrap_osd_keyring }}
    - watch:
      - cmd: {{ bootstrap_osd_keyring }}

{% endfor -%}

{% for dev in salt['pillar.get']('nodes:' + host + ':devs') -%}
{% set journal = salt['pillar.get']('nodes:' + host + ':devs:' + dev + ':journal') -%}
{% if dev -%}

disk_prepare {{ dev }}:
  cmd.run:
    - name: ceph-disk prepare --cluster {{ cluster }} --cluster-uuid {{ fsid }} --fs-type xfs /dev/{{ dev }} /dev/{{ journal }}
    - unless: parted --script /dev/{{ dev }} print | grep 'ceph data'

disk_activate {{ dev }}1:
  cmd.wait:
    - name: ceph-disk activate /dev/{{ dev }}1
    - onlyif: test -f {{ bootstrap_osd_keyring }}
    - timeout: 10
    - watch:
      - cmd: disk_prepare {{ dev }}

{% endif -%}
{% endfor -%}

start ceph-osd-all:
  cmd.run:
    - onlyif: initctl list | grep "ceph-osd-all stop/waiting"
