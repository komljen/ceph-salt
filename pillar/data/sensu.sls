sensu:
  server:
    rabbitmq:
      user: sensu
      password: secret
      vhost: "/sensu"
      ssl: false
      interface: eth1
    dashboard:
      uchiwa:
       user: admin
       password: admin
       port: 3000
