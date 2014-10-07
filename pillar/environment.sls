nodes:
  master:
    roles:
      - ceph-client
  ceph-node01:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  ceph-node02:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdc:
        journal: sdb
      sdd:
        journal: sdb

# Examples:
# MON and OSD on separate nodes.
# Journal on same drive with OSD.
#nodes:
#  ceph-node01:
#    roles:
#      - ceph-mon
#  ceph-node02:
#    roles:
#      - ceph-osd
#    devs:
#      sdb:
#        journal: sdb
#      sdc:
#        journal: sdc
