# vi: set ft=yaml.jinja :

{% set psls = sls.split('.')[0] -%}

include:
  - .minion

/etc/salt/grains:
  file.managed:
    - template: jinja
    - source: salt://{{ psls }}/etc/salt/grains
