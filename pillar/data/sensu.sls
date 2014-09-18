sensu:
  server:
    interface: eth1
    rabbitmq:
      user: sensu
      password: secret
      vhost: "/sensu"
      ssl: false
    dashboard:
      uchiwa:
       user: admin
       password: admin
       port: 3000
  client:
    interface: eth1
