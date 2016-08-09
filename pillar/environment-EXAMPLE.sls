nodes:
  master:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-mds
      - ceph-client
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
      - ceph-mds
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node02:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-mds
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
