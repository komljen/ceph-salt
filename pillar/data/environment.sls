nodes:
  vagrant-ubuntu-trusty-64:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdd
        osd: 0
      sdc:
        journal: sdd
        osd: 1
