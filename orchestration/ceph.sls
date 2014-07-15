# vi: set ft=yaml.jinja :

mon_setup:
  salt.state:
    - tgt: 'role:ceph-mon'
    - tgt_type: grain
    - sls: ceph.mon

osd_setup:
  salt.state:
    - tgt: 'role:ceph-osd'
    - tgt_type: grain
    - sls: ceph.osd
    - require:
      - salt: mon_setup
