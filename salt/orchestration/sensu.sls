# vi: set ft=yaml.jinja :

assign_roles:
  salt.state:
    - tgt: '*'
    - sls: common.salt-minion

sensu_server_setup:
  salt.state:
    - tgt: 'roles:sensu-server'
    - tgt_type: grain
    - sls: sensu.server
    - require:
      - salt: assign_roles

sensu_client_setup:
  salt.state:
    - tgt: 'roles:sensu-client'
    - tgt_type: grain
    - sls: sensu.client
    - require:
      - salt: sensu_server_setup

add_sensu_check:
  salt.state:
    - tgt: 'roles:ceph-client'
    - tgt_type: grain
    - sls: sensu.checks.ceph
    - require:
      - salt: osd_setup
