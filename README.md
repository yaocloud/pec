# Noah

OpenStackにおいて複数サーバの起動や、
DHCPサーバがない状況でのIP自動採番を実現します。

## インストール方法


    $ gem install noah

## 使用方法
### コマンド
実行ディレクトリに存在するNoah.yamlに基づきホストを作成します。
ホスト名が指定された場合はそのホストのみ作成します。

    $ noah up <hostname>

    $ noah destroy <hostname>

### 設定ファイル
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
    hostname: www-19
    fqdn: www-19.muumuu-domain.com
    repo_releasever: 7.1.1503
```
`image`,`flavor`は必須項目です。
`networks`について指定する場合は、`bootproto`,`ip_address`が必須です。`ip_address`は`xxx.xxx.xxx.xxx/yy`の方式を想定しており、ネットワークアドレスが指定された場合、そのサブネットで未使用のアドレスを自動で採番します。
`user_data`については`nova api`にネットワーク設定を加えて引き渡すため、cloud-init記法に準拠します。


## Author
* pyama86
