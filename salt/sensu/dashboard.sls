# vi: set ft=yaml.jinja :

include:
  - .server

uchiwa:
  pkg.installed:
    - require:
      - pkg: sensu
  service.running:
    - require:
      - service: sensu-api
    - watch:
      - file: /etc/sensu/uchiwa.json

/etc/sensu/uchiwa.json:
  file.managed:
    - template: jinja
    - source: salt://sensu/etc/uchiwa.json
    - user: sensu
    - group: sensu
    - mode: '0444'
