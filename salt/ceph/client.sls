# vi: set ft=yaml.jinja :

{% import 'ceph/global_vars.jinja' as conf with context -%}

include:
  - .repo

ceph-common:
  pkg.installed:
    - require:
      - pkgrepo: ceph_repo

{{ conf.conf_file }}:
  cmd.run:
    - name: echo "Getting ceph configuration file:"

{% for mon in salt['mine.get']('roles:ceph-mon','grains.items','grain') -%}

cp.get_file {{ mon }}{{ conf.conf_file }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ conf.conf_file }}
    - dest: {{ conf.conf_file }}
    - watch:
      - cmd: {{ conf.conf_file }}

{% endfor -%}

{{ conf.admin_keyring }}:
  cmd.run:
    - name: echo "Getting admin keyring:"
    - unless: test -f {{ conf.admin_keyring }}

{% for mon in salt['mine.get']('roles:ceph-mon','grains.items','grain') -%}

cp.get_file {{ mon }}{{ conf.admin_keyring }}:
  module.wait:
    - name: cp.get_file
    - path: salt://{{ mon }}/files{{ conf.admin_keyring }}
    - dest: {{ conf.admin_keyring }}
    - watch:
      - cmd: {{ conf.admin_keyring }}

{% endfor -%}

/var/log/ceph:
  file.directory:
    - makedirs: True

/var/run/ceph:
  file.directory:
    - makedirs: True

