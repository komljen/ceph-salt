Deploy Ceph cluster with SaltStack
=========

Salt states for Ceph cluster deployment. Currently only Ceph MONs and OSDs are supported.
Tested on Ubuntu 12.04 with Ceph Firefly release.

Test environment with Vagrant
==============

If you want to test this deployment on your local machine inside VMs, the easiest way is to use Vagrant with VirtualBox provider. All you need is to go inside vagrant directory and run:

    vagrant up

This will bring up 3 VMs, one master and 2 minion nodes. Ceph will be deployed on two minion nodes. Also those VMs will have two additional network interfaces to emulate public and cluster network for Ceph and two additional HDDs attached to them. One will be used for OSD and one for journal. Environment description is located here: pillar/data/environment.sls

Login to master node and make changes inside master configuration file (https://github.com/komljen/salt-ceph#master-node).

    vagrant ssh master

After salt master restart accept minion keys:

    sudo su -
    salt-key -A

Test the connectivity between master and minions:

    salt '*' test.ping
    
If everything is OK you can proceed with Ceph deployment step (https://github.com/komljen/salt-ceph#deployment).

Prepare your environment
==============

First you need Salt master and minions installed and running on all nodes.

Master node
--------------

On the master node you need to include additional options defined in configs/master file. Append this to your /etc/salt/master:

    file_recv: True
    file_roots:
      base:
        - /srv/salt
        - /var/cache/salt/master/minions

Those options will make sure that minions can send files to the master and other minions to be able to get those files. Salt master restart is required.

    service salt-master restart

Salt states and pillars
--------------

Restart the Salt master node and clone my git repository:

    rm -rf /srv/salt /srv/pillar
    cd /srv && git clone https://github.com/komljen/salt-ceph.git .

Then edit pillar/data/environment.sls to match with your environment:

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

Now your environment is ready for Ceph deployment.

Deployment
==============

To start Ceph cluster deployment run orchestrate state from Salt master:

    salt-run state.orchestrate orchestration.ceph
    
If you want more verbosity output run same command with debug log level:

    salt-run -l debug state.orchestrate orchestration.ceph

It will take few minutes to complete. Then you can check ceph cluster status from master:

    salt 'ceph-node01' cmd.run 'ceph -s'

