# vi: set ft=yaml.jinja :

include:
  - .plugins

sensu_repo:
  pkgrepo.managed:
    - name: deb http://repos.sensuapp.org/apt sensu main
    - file: /etc/apt/sources.list.d/sensu.list
    - key_url: http://repos.sensuapp.org/apt/pubkey.gpg
    - require_in:
      - pkg: sensu

sensu:
  pkg.installed: []

/etc/default/sensu:
  file.replace:
    - pattern: EMBEDDED_RUBY=false
    - repl: EMBEDDED_RUBY=true
    - watch:
      - pkg: sensu

/etc/sensu:
  file.directory:
    - user: sensu
    - group: sensu
    - mode: '0755'
    - require:
        - pkg: sensu

/etc/sensu/conf.d:
  file.directory:
    - user: sensu
    - group: sensu
    - mode: '0755'
    - require:
      - file: /etc/sensu

