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

#add_to_crush:
#  cmd.run:
#    - name: ceph osd crush add-bucket {{ host }} host
#    - onlyif: test -f {{ keyring }}
#    - unless: ceph osd tree | grep {{ host }}

#place_root_default:
#  cmd.wait:
#    - name: ceph osd crush move {{ host }} root=default
#    - watch:
#      - cmd: add_to_crush

{% for dev in salt['pillar.get']('nodes:' + host + ':devs') -%}
{% set osd = salt['pillar.get']('nodes:' + host + ':devs:' + dev + ':osd') -%}
{% set journal = salt['pillar.get']('nodes:' + host + ':devs:' + dev + ':journal') -%}
{% if dev -%}

disk_prepare {{ dev }}:
  cmd.run:
    - name: ceph-disk prepare --cluster {{ cluster }} --cluster-uuid {{ fsid }} --fs-type xfs /dev/{{ dev }} /dev/{{ journal }}
    - unless: parted --script /dev/{{ dev }} print | egrep  -sq '^ 1.*ceph'

disk_activate {{ dev }}:
  cmd.wait:
    - name: ceph-disk activate /dev/{{ dev }}
    - onlyif: test -f {{ bootstrap_osd_keyring }}
    - timeout: 10
    - watch:
      - cmd: disk_prepare {{ dev }}

#create_osd {{ osd }}:
#  cmd.run:
#    - name: ceph osd create
#    - unless: ceph osd ls | grep {{ osd }}

#populate_osd {{ osd }}:
#  cmd.wait:
#    - name: ceph-osd -i {{ osd }} --mkfs --mkkey
#    - watch:
#      - cmd: create_osd {{ osd }}

#register_osd {{ osd }}:
#  cmd.wait:
#    - name: ceph auth add osd.{{ osd }} osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/{{ cluster }}-{{ osd }}/keyring
#    - watch:
#      - cmd: populate_osd {{ osd }}

#add_osd_crush {{ osd }}:
#  cmd.wait:
#    - name: ceph osd crush add osd.{{ osd }} 1.0 host={{ host }}
#    - watch:
#      - cmd: register_osd {{ osd }}

#start_osd {{ osd }}:
#  cmd.run:
#    - name: start ceph-osd id={{ osd }}
#    - unless: status ceph-osd id={{ osd }}
#    - require:
#      - cmd: register_osd {{ osd }}

{% endif -%}
{% endfor -%}

