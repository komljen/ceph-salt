# vi: set ft=yaml.jinja :
{% import 'ceph/global_vars.jinja' as conf with context %}
{% set psls = sls.split('.')[0] %}

include:
  - .client

/etc/init.d/ceph-rest-api:
  file.managed:
    - template: jinja
    - source: salt://{{ psls }}/etc/init.d/ceph-rest-api
    - user: root
    - group: root
    - mode: '0755'

ceph-rest-api:
  service.running:
    - enable: True
    - reload: True
    - require:
      - file: /etc/init.d/ceph-rest-api
