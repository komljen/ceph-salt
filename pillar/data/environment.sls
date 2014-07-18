nodes:
  minion01:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdc
  minion02:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdc
