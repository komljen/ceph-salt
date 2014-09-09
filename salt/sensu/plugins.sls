# vi: set ft=yaml.jinja :

include:
  - common.git
  - common.bc
  - .sensu

sensu-plugins-repo:
  git.latest:
    - name: https://github.com/sensu/sensu-community-plugins.git
    - target: /etc/sensu/community
    - require:
      - pkg: sensu

/etc/sensu/plugins:
  file.symlink:
    - target: /etc/sensu/community/plugins
    - force: True
    - require:
        - git: sensu-plugins-repo
