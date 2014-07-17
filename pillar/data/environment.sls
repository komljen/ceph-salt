nodes:
  vagrant-ubuntu-trusty-64:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdd
      sdc:
        journal: sdd
