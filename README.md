# Pec

OpenStackにおいて複数サーバの起動や、
DHCPサーバがない状況でのIP自動採番を実現します。

## インストール方法


    $ gem install pec

## 使用方法
### コマンド
実行ディレクトリに存在するPec.yamlに基づきホストを作成します。
ホスト名が指定された場合はそのホストのみ作成します。

    $ pec up <hostname>

    $ pec destroy <hostname>

### 設定ファイル
[fog](https://github.com/fog/fog)を利用しているので、fogの設定を行ってください。

```
% cat ~/.fog
default:
  openstack_auth_url: "http://your-openstack-endpoint/v2.0/tokens"
  openstack_username: "admin"
  openstack_tenant: "admin"
  openstack_api_key: "admin-no-password"
```


`~/Pec.yaml`
```
pyama-test001:
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.small
  networks:
    eth0:
      bootproto: static
      ip_address: 157.7.190.128/26
      gateway: 157.7.190.129
      dns1: 8.8.8.8
      dns2: 8.8.8.8
    eth1:
      bootproto: static
      ip_address: 10.51.113.0/24
      dns1: 8.8.8.8
      dns2: 8.8.8.8
  user_data:
    hostname: pyama-test001
    fqdn: pyama-test001.ikemen.com
    repo_releasever: 7.1.1503
pyama-test002:
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.midium
  networks:
    eth0:
      bootproto: static
      ip_address: 157.7.190.128/26
      gateway: 157.7.190.129
      dns1: 8.8.8.8
      dns2: 8.8.8.8
    eth1:
      bootproto: static
      ip_address: 10.51.113.0/24
      dns1: 8.8.8.8
      dns2: 8.8.8.8
  user_data:
    hostname: pyama-test002
    fqdn: pyama-test002.ikemen.com
    repo_releasever: 7.1.1503
```
`image`,`flavor`は必須項目です。
`networks`について指定する場合は、`bootproto`,`ip_address`が必須です。`ip_address`は`xxx.xxx.xxx.xxx/yy`の方式を想定しており、ネットワークアドレスが指定された場合、そのサブネットで未使用のアドレスを自動で採番します。
`user_data`については`nova api`にネットワーク設定を加えて引き渡すため、cloud-init記法に準拠します。


## Author
* pyama86
