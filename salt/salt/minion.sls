# vi: set ft=yaml.jinja :

salt-minion:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/salt/grains
    - require:
      - pkg: salt-minion

sleep 5:
  cmd.wait:
    - watch:
      - service: salt-minion
