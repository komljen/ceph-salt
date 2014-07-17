Deploy Ceph cluster with SaltStack
=========

Salt states for Ceph cluster deployment. Currently only Ceph MONs and OSDs are supported.
Tested on Ubuntu 14.04 with Ceph Firefly release.

Prepare your environment
==============

First you need salt master and minions installed and running. On master node you need to include additional options defined in configs/master file. Restart your master and proceed with next step.

Clone my git repository:

    rm -rf /srv/salt /srv/pillar
    cd /srv && git clone https://github.com/komljen/salt-ceph.git .

Then edit pillar/data/environment.sls to match your environment.

Deployment
==============

To start Ceph cluster deployment run orchestrate state:

    salt-run state.orchestrate orchestration.ceph
    
It will take few minutes and after that you can check your cluster status.
