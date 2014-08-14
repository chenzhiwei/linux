# Chef Local Mode

No Chef server required. I like this feature.

## Chef local mode directory structure

```
chef-repo
|-- clients/
|-- cookbooks/COOKBOOK_NAME/
|-- databags/BAGNAME/
|-- environments/
|-- nodes/
|-- roles/
`-- users/
```

## Initialize node

```
# cd chef-repo
# chef-client -z
```

After initialize you node, there will be a json file in your `nodes` directory.

The content of this json file like this:

```
{
  "name": "your_node_name",
  "automatic": {
    "hostname": "chef-server",
    "machinename": "chef-server",
    "platform": "redhat",
    "platform_version": "6.4",
    "platform_family": "rhel",
    "kernel": {
      "name": "Linux",
      "release": "2.6.32-358.el6.x86_64",
      "version": "#1 SMP Tue Jan 29 11:47:41 EST 2013",
      "machine": "x86_64",
      "os": "GNU/Linux",
      "modules": {
        ...
    }
    "network": {
      "interfaces": {
        "lo": {
          "mtu": "16436",
          "flags": [
            "LOOPBACK",
            "UP",
            "LOWER_UP"
          ],
          "encapsulation": "Loopback",
          "addresses": {
            "127.0.0.1": {
              "family": "inet",
              "prefixlen": "8",
              "netmask": "255.0.0.0",
              "scope": "Node"
            },
            "::1": {
              "family": "inet6",
              "prefixlen": "128",
              "scope": "Node"
            }
          }
        }
        "eth0": {
          "type": "eth",
          "number": "0",
          "mtu": "1500",
          "flags": [
            "BROADCAST",
            "MULTICAST",
            "UP",
            "LOWER_UP"
          ],
          "encapsulation": "Ethernet",
          "addresses": {
            "FA:16:3B:C4:8E:65": {
              "family": "lladdr"
            },
            "192.168.122.100": {
              "family": "inet",
              "prefixlen": "24",
              "netmask": "255.255.255.0",
              "broadcast": "192.168.122.255",
              "scope": "Global"
            },
            "fe80::f816:3bff:fec4:8e65": {
              "family": "inet6",
              "prefixlen": "64",
              "scope": "Link"
            }
          }
        }
      }
    }
  }
}
```

Open it, you will see your node's attributes and you can use them in your recipes like this:

```
hostname = node['hostname']
arch = node['kernel']['machine']
platform = node['platform']
platform_family = node['platform_family']
platform_version = node['platform_version']
```

Below I will show you how to add your own attribute to this node.

## Create a cookbook

```
# cd chef-repo/cookbooks
# mkdir demo
# tree demo
demo
|-- metadata.rb
|-- attributes/default.rb
|-- recipes/install.rb
|-- templates/default/nginx-site.conf.erb
```

* metadata.rb

```
name 'demo'
version '0.1.0'
```

* attributes/default.rb

```
default['demo']['package'] = 'nginx'
default['demo']['service'] = 'nginx'
default['demo']['conf'] = 'demo.conf'
default['demo']['ip'] = '127.0.0.1'
default['demo']['port'] = 80
```

* recipes/install.rb

```
pkg_name = node['demo']['package']
svc_name = node['demo']['service']
conf_name = node['demo']['conf']

package pkg_name do
  action :install
end

service svc_name do
  action :start
end

template "/etc/nginx/conf.d/#{conf_name}" do
  source 'nginx-site.conf.erb'
  action :create
  notifies :restart, "service[#{svc_name}]", :immediately
end
```

* templates/default/nginx-site.conf.erb

```
server {
  listen <%= node['demo']['ip'] %>:<%= node['demo']['port'] %>;

  location / {
    root /var/www/html;
  }
}
```

## Create a role

```
# cd chef-repo/roles
# vim demo-role.json
```

* demo-role.json

```
{
  "name": "demo-role",
  "run_list": [
    "recipe[demo::install]"
  ]
}
```

## Assign a role to node

```
# knife node -z run_list add your_node_name 'role[demo-role]'
```

## Create en environment

```
# cd chef-repo/environments
# vim demo_env.json
```

* demo_env.json

```
{
  "name": "demo_env",
  "override_attributes": {
    "demo": {
      "port": 8000,
      "ip": "10.0.0.100"
    }  
  }
}
```

## Run Chef

```
# chef-client -z -E demo_env
```

## Reference

<http://www.getchef.com/blog/2013/10/31/chef-client-z-from-zero-to-chef-in-8-5-seconds/>
