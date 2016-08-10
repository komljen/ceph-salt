# vi: set ft=yaml.jinja :
{% import 'ceph/global_vars.jinja' as conf with context %}
{% set psls = sls.split('.')[0] %}

include:
  - .repo

ceph:
  pkg.installed:
    - require:
      - pkgrepo: ceph_repo

{{ conf.conf_file }}:
  file.managed:
    - template: jinja
    - source: salt://{{ psls }}/etc/ceph/ceph.conf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: ceph

cp.push {{ conf.conf_file }}:
  module.wait:
    - name: cp.push
    - path: {{ conf.conf_file }}
    - watch:
      - file: {{ conf.conf_file }}

/etc/updatedb.conf:
  file.replace:
    - pattern: (^PRUNEPATHS.*)(\")
    - repl: \1 /var/lib/ceph"
    - unless: grep -q "PRUNEPATHS.*/var/lib/ceph" /etc/updatedb.conf

updatedb:
  cmd.wait:
    - watch:
      - file: /etc/updatedb.conf
