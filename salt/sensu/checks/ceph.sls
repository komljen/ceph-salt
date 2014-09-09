# vi: set ft=yaml.jinja :

include:
  - sensu.client

/etc/sensu/conf.d/checks-ceph.json:
  file.managed:
    - template: jinja
    - source: salt://sensu/etc/checks/checks-ceph.json
    - user: sensu
    - group: sensu
    - mode: '0444'
    - watch_in:
      - service: sensu-client
