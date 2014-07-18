Deploy Ceph cluster with SaltStack
=========

Salt states for Ceph cluster deployment. Currently only Ceph MONs and OSDs are supported.
Tested on Ubuntu 14.04 with Ceph Firefly release.

Prepare your environment
==============

First you need salt master and minions installed and running. On the master node you need to include additional options defined in configs/master file:

    file_recv: True
    file_roots:
      base:
        - /srv/salt
        - /var/cache/salt/master/minions

Those changes will add option for minions to send files to the master and other minions to be able to get those files. Restart your salt master and clone my git repository:

    rm -rf /srv/salt /srv/pillar
    cd /srv && git clone https://github.com/komljen/salt-ceph.git .

Then edit pillar/data/environment.sls to match with your environment:

    nodes:
      vagrant-ubuntu-trusty-64:
        roles:
          - ceph-osd
          - ceph-mon
        devs:
          sdb:
            journal: sdd
          sdc:
            journal: sdd

Deployment
==============

To start Ceph cluster deployment run orchestrate state:

    salt-run state.orchestrate orchestration.ceph
    
It will take few minutes and after that you can check your cluster status.
