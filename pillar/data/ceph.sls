ceph:
  version: firefly
  cluster_name: ceph
  global:
    cluster_network: 192.168.36.0/24
    fsid: 294bc494-81ba-4c3c-ac5d-af7b3442a2a5
    public_network: 192.168.33.0/24
  client:
    rbd_cache: "true"
    rbd_cache_writethrough_until_flash: "true"
    rbd_cache_size: 134217728
  osd:
    crush_chooseleaf_type: 1
    crush_update_on_start: "true"
    filestore_merge_threshold: 40
    filestore_split_multiple: 8
    filestore_op_threads: 4
    journal_size: 512
    op_threads: 4
    disk_threads: 1
    scrub_load_threshold: "0.5"
    map_cache_size: 512
    max_backfills: 2
    pool_default_min_size: 1
    pool_default_pg_num: 128
    pool_default_pgp_num: 128
    pool_default_size: 3
  mon:
    interface: eth1
