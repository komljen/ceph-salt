# vi: set ft=yaml.jinja :

{% set cluster = salt['grains.get']('environment','ceph') %}

ceph:
  pkg.installed

/etc/ceph/{{ cluster }}.conf:
  file.managed:
    - template: jinja
    - source: salt://ceph/etc/ceph.conf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: ceph
