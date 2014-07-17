# vi: set ft=yaml.jinja :

salt-minion:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/salt/grains
    - require:
      - pkg: salt-minion

/etc/salt/grains:
  file.managed:
    - template: jinja
    - source: salt://common/salt-minion/etc/grains
    - require:
      - pkg: salt-minion

