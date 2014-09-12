Deploy Ceph cluster with SaltStack
=========

Salt states for Ceph cluster deployment. Currently only Ceph MONs and OSDs are supported.
Tested on Ubuntu 12.04 with Ceph Firefly release.

Test environment with Vagrant
==============

If you want to test this deployment on your local machine inside VMs, the easiest way is to use Vagrant with VirtualBox provider. All you need is to go inside vagrant directory and run:

    cd vagrant && vagrant up

This will bring up 3 VMs, one master and 2 minion nodes. Ceph will be deployed on two minion nodes. Also those VMs will have two additional network interfaces to emulate public and cluster network for Ceph and two additional HDDs attached to them. One will be used for OSD and one for journal. Environment description is located here: pillar/data/environment.sls

Test the connectivity between master and minions:

    vagrant ssh master
    sudo salt '*' test.ping
    
If everything is OK you can proceed with Ceph deployment step: https://github.com/komljen/ceph-salt#deployment

Prepare your environment
==============

First you need Salt master and minions installed and running on all nodes and minions keys should be accepted.

Master node
--------------

On the master node you need to include additional options. Append this to your /etc/salt/master:

    file_recv: True
    file_roots:
      base:
        - /srv/salt
        - /var/cache/salt/master/minions

Those options will make sure that minions can send files to the master and other minions to be able to get those files. Salt master restart is required.

    service salt-master restart

Salt states and pillars
--------------

Clone this git repository:

    rm -rf /srv/salt /srv/pillar
    cd /srv && git clone https://github.com/komljen/salt-ceph.git .

Configuration options
--------------

Environment description file with examples is located here: pillar/data/environment.sls. Edit this file to match with your environment:

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

Ceph configuration file will be automatically generated. Edit pillar/data/ceph.sls if you want to make additional changes:

    ceph:
      global:
        fsid: 294bc494-81ba-4c3c-ac5d-af7b3442a2a5
        public_network: 192.168.33.0/24
        cluster_network: 192.168.36.0/24
      client:
        rbd_cache: true
        rbd_cache_size: 134217728
      osd:
        journal_size: 3072
        pool_default_size: 3
        pool_default_min_size: 1
        pool_default_pg_num: 1024
        pool_default_pgp_num: 1024
        crush_chooseleaf_type: 1
        filestore_merge_threshold: 40
        filestore_split_multiple: 8
        op_threads: 8
      custom:
        mon_interface: eth1

Take a look at those options to match with your machines:

    public_network: 192.168.33.0/24
    cluster_network: 192.168.36.0/24
    mon_interface: eth1

Proceed with deployment step after changes are done.

Deployment
==============

To start Ceph cluster deployment run orchestrate state from Salt master:

    salt-run state.orchestrate orchestrate.ceph
    
If you want more verbosity output run same command with debug log level:

    salt-run -l debug state.orchestrate orchestrate.ceph

It will take few minutes to complete. Then you can check ceph cluster status from master:

    salt 'ceph-node01' cmd.run 'ceph -s'

