# vi: set ft=yaml.jinja :

{% set cluster = salt['grains.get']('environment','ceph') -%}
{% set host = salt['config.get']('host') -%}
{% set fsid = salt['pillar.get']('ceph:global:fsid') -%}
{% set keyring = '/etc/ceph/' + cluster + '.client.admin.keyring' -%}
{% set mons = [] -%}

{% set host = salt['config.get']('host') -%}
{% set is_mon = salt['pillar.get']('nodes:' + node + ':mon') -%}
{% if is_mon == true -%}
{% do mons.append(node) -%}
{% endif -%}
{% endfor -%}

include:
  - .ceph

{{ keyring }}:
  cmd.run:
    - name: echo "Keyring doesn't exists"
    - unless: test -f {{ keyring }}

{% for mon in mons -%}

cp.get_file {{mon}}{{ keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ keyring }}
    - dest: {{ keyring }}
    - watch:
      - cmd: {{ keyring }}

{% endfor -%}

add_to_crush:
  run.cmd:
    - name: ceph osd crush add-bucket {{ host }} host

place_root_default:
  run.cmd:
    - name: ceph osd crush move {{ host }} root=default

{% for dev in salt['pillar.get']('nodes:' + host + ':devs') -%}
{% set osd = salt['pillar.get']('nodes:' + host + ':devs:' + dev + ':osd') -%}
{% set journal = salt['pillar.get']('nodes:' + host + ':devs:' + dev + ':journal') -%}

create_osd:
  cmd.run:
    - name: ceph osd create

populate_osd:
  cmd.wait:
    - name: ceph-osd -i {{ osd }} --mkfs --mkkey
    - watch:
      - cmd: create_osd

register_osd:
  cmd.run:
    -name: ceph auth add osd.{{ osd }} osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-{{ osd }}/keyring

add_osd_crush:
  cmd.run:
    - name: ceph osd crush add osd.{{ osd }} 1.0 host={{ host }}

start_osd:
  cmd.run:
    - name: start ceph-osd id={{ osd }}
    - unless: status ceph-osd id={{ osd }}
    - require:
      - cmd: populate_osd

{% endfor -%}

