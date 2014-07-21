# vi: set ft=yaml.jinja :

assign_roles:
  salt.state:
    - tgt: '*'
    - sls: common.salt-minion

mon_setup:
  salt.state:
    - tgt: 'roles:ceph-mon'
    - tgt_type: grain
    - sls: ceph.mon
    - require:
      - salt: assign_roles

osd_setup:
  salt.state:
    - tgt: 'roles:ceph-osd'
    - tgt_type: grain
    - sls: ceph.osd
    - require:
      - salt: mon_setup
