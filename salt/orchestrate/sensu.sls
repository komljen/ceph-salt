# vi: set ft=yaml.jinja :

server_setup:
  salt.state:
    - tgt: 'roles:sensu-server'
    - tgt_type: grain
    - sls: sensu.server

client_setup:
  salt.state:
    - tgt: 'roles:sensu-client'
    - tgt_type: grain
    - sls: sensu.client
    - require:
      - salt: server_setup
