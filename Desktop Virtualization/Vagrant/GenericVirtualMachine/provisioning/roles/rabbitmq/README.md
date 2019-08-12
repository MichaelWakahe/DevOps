Requirements
------------

Need ansible 2+


Role Variables
--------------

```yaml
rabbitmq_vhosts:
- name:    vhost1
  node:    node_name # Optional, defaults to "rabbit"
  tracing: yes # Optional, defaults to "no"

rabbitmq_users:
- vhost: vhost1
  user: user1
  password: password1
  node: node_name # Optional, defaults to "rabbit"
  configure_priv: "^resource.*" # Optional, defaults to ".*"
  read_priv: "^$" # Disallow reading.
  write_priv: "^$" # Disallow writing.
- vhost: vhost1
  user: user2
  password: password2
  force: no
  tags: # Optional, user tags
  - administrator
```



Management
-------

The Management Plugin is installed by this role. 

The management UI can be accessed using a Web browser at http://{node-hostname}:15672/. For example, the
URL can be: [http://192.168.1.249:15672](http://192.168.1.249:15672)

More on the Management Plugin can be found in the [official documentation](https://www.rabbitmq.com/management.html).
