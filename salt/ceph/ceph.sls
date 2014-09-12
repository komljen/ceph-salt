# vi: set ft=yaml.jinja :

{% set cluster = salt['grains.get']('environment','ceph') -%}

{% if salt['config.get']('oscodename') == 'precise' -%}

ceph_repo:
  pkgrepo.managed:
    - name: deb http://ceph.com/debian/ precise main
    - file: /etc/apt/sources.list.d/ceph.list
    - key_url: https://raw.github.com/ceph/ceph/master/keys/release.asc
    - require_in:
      - pkg: ceph

{% endif -%}

ceph:
  pkg.installed: []

/etc/ceph/{{ cluster }}.conf:
  file.managed:
    - template: jinja
    - source: salt://ceph/etc/ceph.conf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: ceph
