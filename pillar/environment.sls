nodes:
  master:
    roles:
      - ceph-mon
  node01:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node02:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
