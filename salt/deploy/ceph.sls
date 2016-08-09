# vi: set ft=yaml.jinja :
{% set environment = salt['pillar.get']('environment') -%}

mon_setup:
  salt.state:
    - tgt: 'G@roles:ceph-mon and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: ceph.mon
    - pillar:
        environment: {{ environment }}

osd_setup:
  salt.state:
    - tgt: 'G@roles:ceph-osd and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: ceph.osd
    - require:
      - salt: mon_setup
    - pillar:
        environment: {{ environment }}

mds_setup:
  salt.state:
    - tgt: 'G@roles:ceph-mds and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: ceph.mds
    - require:
      - salt: mon_setup
    - pillar:
        environment: {{ environment }}

client_setup:
  salt.state:
    - tgt: 'G@roles:ceph-client and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: ceph.client
    - require:
      - salt: mon_setup
    - pillar:
        environment: {{ environment }}

rest_api_setup:
  salt.state:
    - tgt: 'G@roles:ceph-rest-api and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: ceph.rest_api
    - require:
      - salt: mon_setup
    - pillar:
        environment: {{ environment }}