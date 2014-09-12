# vi: set ft=yaml.jinja :

sensu_server_setup:
  salt.state:
    - tgt: 'roles:sensu-server'
    - tgt_type: grain
    - sls: sensu.server

sensu_client_setup:
  salt.state:
    - tgt: 'roles:sensu-client'
    - tgt_type: grain
    - sls: sensu.client
    - require:
      - salt: sensu_server_setup
