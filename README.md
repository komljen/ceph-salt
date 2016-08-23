# Ceph cluster deployment
[![Flattr this git repo](https://img.shields.io/badge/donate-flattr-red.svg)](https://flattr.com/submit/auto?user_id=komljen&url=https://github.com/komljen/ceph-salt&title=Ceph cluster deployment with SaltStack&language=&tags=github&category=software)

Salt states for Ceph cluster deployment.

Support for:

 * Ceph MON
 * Ceph OSD
 * Ceph MDS
 * Ceph Clients
 * Ceph REST API

Details:

 * Support for Ceph multi-environment deployment from one salt master node.
 * Deploy any number of MONs, OSDs or MDS services. Also, those states could be used to add new nodes after a cluster is created.
 * Support to select which disks are OSDs or Journals.
 * Support for cluster and public network.

Those states are tested on Ubuntu 14.04 with Ceph Hammer release and Salt v2016.3.2.

# Vagrant

If you want to test this deployment on your local machine inside VMs, the easiest way is to use Vagrant with VirtualBox provider. All you need is to go inside vagrant directory and run:

```
cd vagrant && vagrant up
```
This will bring up 3 VMs, one master, and 3 minion nodes. Ceph will be deployed on all three nodes. Also, those VMs will have two additional network interfaces to emulate public and cluster network for Ceph and three additional drives attached to them. Two will be used for OSDs and one for a journal.

Test the connectivity between master and minions:

```
vagrant ssh master
sudo salt -G 'environment:VAGRANT' test.ping
```
If everything is OK you can proceed with the Ceph deployment step: https://github.com/komljen/ceph-salt#deployment

# Local environment

First, you need Salt master and minions installed and running on all nodes and minions keys should be accepted. The easiest way to install SaltStack is using bootstrap script:

Master:

```
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -M -g https://github.com/saltstack/salt.git git v2016.3.2
```
Minions:

```
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -g https://github.com/saltstack/salt.git git v2016.3.2
```

### Master configuration

On the master node you need to include additional options. Edit master config file ```/etc/salt/master```. Replace ```<USER>``` with username where this repository will be cloned:

```
file_recv: True
file_roots:
  base:
    - /home/<USER>/ceph-salt/salt
    - /var/cache/salt/master/minions
pillar_roots:
  base:
    - /home/<USER>/config
    - /home/<USER>/ceph-salt/pillar
worker_threads: 10
hash_type: sha256
jinja_trim_blocks: True
jinja_lstrip_blocks: True
```

New options will make sure that minions can send files to the master and other minions to be able to get those files. Also here you can change where your salt states and config files are located. Salt master restart is required:

```
sudo service salt-master restart
```

### Minions configuration

On all minion nodes, you need to edit the configuration file. Edit minion config file ```/etc/salt/minion```. Replace ```<ENV_NAME>``` and master IP address to match with your environment:

```
master: 192.168.33.10
hash_type: sha256
grains:
  environment: <ENV_NAME>
```

Salt minion restart is required:

```
sudo service salt-minion restart
```

**NOTE:** To add new Ceph environment just install minions and choose new environment name!

### Connection check

On master node accept all minions with:

```
sudo salt-key -A
```
Now all minions are connected and you should be able to send any command to a particular environment. Examples:

```
sudo salt -G 'environment:PROD' test.ping
sudo salt -G 'environment:STAGE' test.ping
```
If everything is fine clone this git repository on the master node. Use the same user you specified in master configuration file:

```
git clone https://github.com/komljen/ceph-salt.git -b master
```
Copy configuration files for each environment except ```top.sls``` file:

```
mkdir -p ~/config
cp ~/ceph-salt/pillar/environment-EXAMPLE.sls ~/config/environment-<ENV_NAME>.sls
cp ~/ceph-salt/pillar/ceph-EXAMPLE.sls ~/config/ceph-<ENV_NAME>.sls
cp ~/ceph-salt/pillar/top.sls ~/config/top.sls
```
Edit ```~/config/top.sls``` file and replace ENV_NAME with your environment:

```
  'environment:<ENV_NAME>':
    - match: grain
    - environment-<ENV_NAME>
    - ceph-<ENV_NAME>
```
If you have more environments add it here. Example:

```
  'environment:PROD':
    - match: grain
    - environment-PROD
    - ceph-PROD

  'environment:STAGE':
    - match: grain
    - environment-STAGE
    - ceph-STAGE
```

### Configuration options

Edit ```~/config/environment-<ENV_NAME>.sls``` file to match with your environment. For node names use hostnames (not FQDN):

```
nodes:
  master:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-mds
      - ceph-client
      - ceph-rest-api
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node01:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-mds
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
  node02:
    roles:
      - ceph-osd
      - ceph-mon
      - ceph-mds
    osds:
      sdc:
        journal: sdb
      sdd:
        journal: sdb
```
Now edit ```~/config/ceph-<ENV_NAME>.sls``` if you want to make additional changes to ceph configuration. Take a look at those options to match with your machines:

```
ceph:
  version: hammer
  cluster_name: ceph
  rest_api:
    port: 5000
  global:
    cluster_network: 192.168.36.0/24
    fsid: 294bc494-81ba-4c3c-ac5d-af7b3442a2a5
    public_network: 192.168.33.0/24
  mon:
    interface: eth1 # Should match public_network
```
Proceed with deployment step after all changes are done.

**NOTE:** Generate your FSID with ```uuidgen``` command!

# Deployment

First, you need to run high state to add roles to minions based on ```environment-<ENV_NAME>.sls``` file. All roles for all environments will be applied:

```
sudo salt '*' state.highstate
```
To start Ceph cluster deployment run orchestrate state:

```
sudo salt-run state.orchestrate deploy.ceph pillar='{environment: ENV_NAME}'
```
It will take few minutes to complete. Then you can check ceph cluster status:

```
sudo ceph -s
```

# Ceph consulting

I'm providing Ceph consulting services including architecture design and implementation.
Please contact me for more details.
