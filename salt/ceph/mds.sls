# vi: set ft=yaml.jinja :

{% import 'ceph/global_vars.jinja' as conf with context -%}
{% set bootstrap_mds_keyring = '/var/lib/ceph/bootstrap-mds/' + conf.cluster + '.keyring' -%}

include:
  - .ceph

{{ bootstrap_mds_keyring }}:
  cmd.run:
    - name: echo "Getting bootstrap MDS keyring"
    - unless: test -f {{ bootstrap_mds_keyring }}

{% for mon in salt['mine.get']('roles:ceph-mon','grains.items','grain') -%}

cp.get_file {{ mon }}{{ bootstrap_mds_keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ bootstrap_mds_keyring }}
    - dest: {{ bootstrap_mds_keyring }}
    - watch:
      - cmd: {{ bootstrap_mds_keyring }}

{% endfor -%}

/var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: '0644'

gen_mds_keyring:
  cmd.run:
    - name: |
        ceph --cluster {{ conf.cluster }} \
             --name client.bootstrap-mds \
             --keyring /var/lib/ceph/bootstrap-mds/{{ conf.cluster }}.keyring \
             auth get-or-create mds.{{ conf.host }} osd 'allow rwx' mds 'allow' mon 'allow profile mds' \
             -o /var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}/keyring
    - unless: test -f /var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}/keyring
    - require:
      - file: /var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}

start_mds:
  cmd.run:
    - name: start ceph-mds id={{ conf.host }} cluster={{ conf.cluster }}
    - unless: status ceph-mds id={{ conf.host }} cluster={{ conf.cluster }}
    - require:
      - cmd: gen_mds_keyring

/var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}/upstart:
  file.touch:
    - unless: test -f /var/lib/ceph/mds/{{ conf.cluster }}-{{ conf.host }}/upstart
