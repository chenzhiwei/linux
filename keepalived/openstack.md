# 在OpenStack VM上使用Keepalived

需要满足两个条件：

1. VM中允许 VRRP 协议包通过，可以通过添加 Security Group 来实现，VRRP协议的代码是`112`，在OpenStack上添加允许VRRP的Security Group时能用到。
2. 在Neutron里创建VIP的Port并且允许其挂载到VM上面：

下面例子中，`192.168.0.14`为VIP，然后两台挂载VIP的VM的Port中`allowed_address_pairs`里需要设置上VIP。

```
$ neutron port-create --name vip-port demo-net
Created a new port:
+-----------------------+-------------------------------------------------------------------------------------+
| Field                 | Value                                                                               |
+-----------------------+-------------------------------------------------------------------------------------+
| admin_state_up        | True                                                                                |
| allowed_address_pairs |                                                                                     |
| binding:host_id       |                                                                                     |
| binding:profile       | {}                                                                                  |
| binding:vif_details   | {}                                                                                  |
| binding:vif_type      | unbound                                                                             |
| binding:vnic_type     | normal                                                                              |
| device_id             |                                                                                     |
| device_owner          |                                                                                     |
| fixed_ips             | {"subnet_id": "9bc8ad9b-fa50-41c3-8381-7b86e8fd554b", "ip_address": "192.168.0.14"} |
| id                    | ae020587-e870-4e38-b72a-6c8980bb92f6                                                |
| mac_address           | fa:16:3e:03:84:81                                                                   |
| name                  | vip-port                                                                            |
| network_id            | f2592a01-e31d-4bdc-8aa7-ca66f938eb83                                                |
| security_groups       | da933f24-4b8f-4478-909a-ca19aece379d                                                |
| status                | DOWN                                                                                |
| tenant_id             | 619a60d46b1349f7998116abec50b088                                                    |
+-----------------------+-------------------------------------------------------------------------------------+
$ neutron port-create --name vm1-port --allowed-address-pair ip_address=192.168.0.14 demo-net
Created a new port:
+-----------------------+-------------------------------------------------------------------------------------+
| Field                 | Value                                                                               |
+-----------------------+-------------------------------------------------------------------------------------+
| admin_state_up        | True                                                                                |
| allowed_address_pairs | {"ip_address": "192.168.0.14", "mac_address": "fa:16:3e:69:b2:d2"}                  |
| binding:host_id       |                                                                                     |
| binding:profile       | {}                                                                                  |
| binding:vif_details   | {}                                                                                  |
| binding:vif_type      | unbound                                                                             |
| binding:vnic_type     | normal                                                                              |
| device_id             |                                                                                     |
| device_owner          |                                                                                     |
| fixed_ips             | {"subnet_id": "9bc8ad9b-fa50-41c3-8381-7b86e8fd554b", "ip_address": "192.168.0.15"} |
| id                    | 9ef8a695-0409-43db-9878-bf6b555dcfee                                                |
| mac_address           | fa:16:3e:69:b2:d2                                                                   |
| name                  | vm1-port                                                                            |
| network_id            | f2592a01-e31d-4bdc-8aa7-ca66f938eb83                                                |
| security_groups       | da933f24-4b8f-4478-909a-ca19aece379d                                                |
| status                | DOWN                                                                                |
| tenant_id             | 619a60d46b1349f7998116abec50b088                                                    |
+-----------------------+-------------------------------------------------------------------------------------+
$ neutron port-create --name vm2-port --allowed-address-pair ip_address=192.168.0.14 demo-net
Created a new port:
+-----------------------+-------------------------------------------------------------------------------------+
| Field                 | Value                                                                               |
+-----------------------+-------------------------------------------------------------------------------------+
| admin_state_up        | True                                                                                |
| allowed_address_pairs | {"ip_address": "192.168.0.14", "mac_address": "fa:16:3e:9e:8c:66"}                  |
| binding:host_id       |                                                                                     |
| binding:profile       | {}                                                                                  |
| binding:vif_details   | {}                                                                                  |
| binding:vif_type      | unbound                                                                             |
| binding:vnic_type     | normal                                                                              |
| device_id             |                                                                                     |
| device_owner          |                                                                                     |
| fixed_ips             | {"subnet_id": "9bc8ad9b-fa50-41c3-8381-7b86e8fd554b", "ip_address": "192.168.0.16"} |
| id                    | 928c8761-b98b-4c2f-be41-e4ab5ee82eab                                                |
| mac_address           | fa:16:3e:9e:8c:66                                                                   |
| name                  | vm2-port                                                                            |
| network_id            | f2592a01-e31d-4bdc-8aa7-ca66f938eb83                                                |
| security_groups       | da933f24-4b8f-4478-909a-ca19aece379d                                                |
| status                | DOWN                                                                                |
| tenant_id             | 619a60d46b1349f7998116abec50b088                                                    |
+-----------------------+-------------------------------------------------------------------------------------+
```

Refer: https://blog.codecentric.de/en/2016/11/highly-available-vips-openstack-vms-vrrp/
