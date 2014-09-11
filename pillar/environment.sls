nodes:
  master:
    roles:
      - sensu-server
      - sensu-client
  ceph-node01:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-client
      - sensu-client
    devs:
      sdb:
        journal: sdc

#  ceph-node02:
#    roles:
#      - ceph-osd
#      - ceph-mon
#      - sensu-client
#    devs:
#      sdb:
#        journal: sdc
#
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
