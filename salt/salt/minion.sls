# vi: set ft=yaml.jinja :

salt-minion:
  service.running:
    - watch:
      - file: /etc/salt/grains

sleep 5:
  cmd.wait:
    - watch:
      - service: salt-minion
