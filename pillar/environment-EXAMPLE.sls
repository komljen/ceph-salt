nodes:
  master:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-rest-api
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node01:
    roles:
      - ceph-osd
      - ceph-mon
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node02:
    roles:
      - ceph-osd
      - ceph-mon
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
