# vi: set ft=yaml.jinja :

first_mon_setup:
  salt.state:
    - tgt: 'vagrant-ubuntu-trusty-64*'
    - sls: ceph.mon

mon_setup:
  salt.state:
    - tgt: 'role:ceph-mon'
    - tgt_type: grain
    - sls: ceph.mon
    - require:
      - salt: first_mon_setup

osd_setup:
  salt.state:
    - tgt: 'role:ceph-osd'
    - tgt_type: grain
    - sls: ceph.osd
    - require:
      - salt: mon_setup
