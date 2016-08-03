# vi: set ft=yaml.jinja :

base:
  '*':
    - mine_functions

  'environment:ENV_NAME':
    - match: grain
    - environment-ENV_NAME
    - ceph-ENV_NAME
