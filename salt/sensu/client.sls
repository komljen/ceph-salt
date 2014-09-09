# vi: set ft=yaml.jinja :

include:
  - .sensu

sensu-client:
  service.running:
    - require:
      - pkg: sensu
    - watch:
      - file: /etc/sensu/conf.d/client.json
      - file: /etc/sensu/conf.d/checks-all.json
      - file: /etc/sensu/conf.d/rabbitmq.json

{% for file in 'client.json','rabbitmq.json' -%}
/etc/sensu/conf.d/{{ file }}:
  file.managed:
    - template: jinja
    - source: salt://sensu/etc/{{ file }}
    - user: sensu
    - group: sensu
    - mode: '0444'
    - require:
      - file: /etc/sensu/conf.d

{% endfor -%}

/etc/sensu/conf.d/checks-all.json:
  file.managed:
    - template: jinja
    - source: salt://sensu/etc/checks/checks-all.json
    - user: sensu
    - group: sensu
    - mode: '0444'
    - require:
      - file: /etc/sensu/conf.d
