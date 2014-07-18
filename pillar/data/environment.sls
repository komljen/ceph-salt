nodes:
  ceph-node01:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdc
  ceph-node02:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdc
