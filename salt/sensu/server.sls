# vi: set ft=yaml.jinja :

{% set rabbitmq_user = salt['pillar.get']('sensu:server:rabbitmq:user') -%}
{% set rabbitmq_pass = salt['pillar.get']('sensu:server:rabbitmq:password') -%}
{% set rabbitmq_vhost = salt['pillar.get']('sensu:server:rabbitmq:vhost') -%}

include:
  - .sensu
  - rabbitmq
  - redis
  - .dashboard

{% for file in 'handlers.json','rabbitmq.json','redis.json','api.json' -%}
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

rabbitmq-user-setup:
  rabbitmq_user.present:
    - name: {{ rabbitmq_user }}
    - password: {{ rabbitmq_pass }}
    - require:
      - pkg: rabbitmq-server

rabbitmq-vhost-setup:
  rabbitmq_vhost.present:
    - name: "{{ rabbitmq_vhost }}"
    - user: {{ rabbitmq_user }}
    - conf: .*
    - write: .*
    - read: .*
    - require:
      - rabbitmq_user: {{ rabbitmq_user }}

sensu-server:
  service.running:
    - require:
      - pkg: sensu
      - rabbitmq_user: rabbitmq-user-setup
      - rabbitmq_vhost: rabbitmq-vhost-setup
    - watch:
      - file: /etc/sensu/conf.d/handlers.json
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/redis.json

sensu-api:
  service.running:
    - watch:
      - service: sensu-server
      - file: /etc/sensu/conf.d/api.json
