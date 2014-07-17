nodes:
  vagrant-ubuntu-trusty-64:
    roles:
      - ceph-osd
      - ceph-mon
    devs:
      sdb:
        journal: sdf
        osd: 0
      sdc:
        journal: sdf
        osd: 1
      sdd:
        journal: sdg
        osd: 2
      sde:
        journal: sdg
        osd: 3
