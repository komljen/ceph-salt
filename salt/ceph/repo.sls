# vi: set ft=yaml.jinja :

{% set oscodename = salt['config.get']('oscodename') -%}
{% set version = salt['pillar.get']('ceph:version') -%}

ceph_repo:
  pkgrepo.managed:
    - name: deb http://ceph.com/debian-{{ version }}/ {{ oscodename }} main
    - file: /etc/apt/sources.list.d/ceph.list
    - key_url: https://raw.github.com/ceph/ceph/master/keys/release.asc
