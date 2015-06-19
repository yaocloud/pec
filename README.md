# Pec
[![Build Status](https://travis-ci.org/pyama86/pec.svg?branch=master)](https://travis-ci.org/pyama86/pec)
[![Code Climate](https://codeclimate.com/github/pyama86/pec/badges/gpa.svg)](https://codeclimate.com/github/pyama86/pec)
[![Test Coverage](https://codeclimate.com/github/pyama86/pec/badges/coverage.svg)](https://codeclimate.com/github/pyama86/pec/coverage)

OpenStackにおいて複数サーバの起動一括起動停止や、 DHCPサーバがない状況でのIP自動採番を実現します。
作って壊してが驚くほどかんたんに。

## Install

    $ gem install pec

## Usage

セットアップ・定義ファイル作成

    $ pec init

```
create - /Pec.yaml
create - /user_datas/web_server.yaml.sample
```

Pec.yamlに基づきホストを作成します。
ホスト名が指定された場合はそのホストのみ作成、削除します。

    $ pec up <hostname>

    $ pec destroy <hostname>

    $ pec status <hostname>

### Configure
#### Pec.yaml
```
pyama-test001:
  tenant: your_tenant
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.small
  networks:
    eth0:
      bootproto: static
      ip_address: 10.1.1.1/24
      gateway: 10.1.1.254
      dns1: 8.8.8.8
      dns2: 8.8.8.8
    eth1:
      bootproto: dhcp
  security_group:
  - default
  - ssh
  templates:
  - base.yaml
  - webserver.yaml
  user_data:
    hostname: pyama-test001
    fqdn: pyama-test001.ikemen.com
    repo_releasever: 7.1.1503
pyama-test002:
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.midium
・・・

```
##### Detail

| 項目名         | 説明                                           | 必須 | 例示                            |
| -------------- | ---------------------------------------------- | ---- | ------------------------------- |
| instance_name  | インスタンス名                                 | ○    | pyama-test001                   |
| tenant         | テナント名                                     | ○    | your_tenant                     |
| image          | イメージ名                                     | ○    | centos-7.1_chef-12.3_puppet-3.7 |
| flavor         | フレーバー名                                   | ○    | m1.small                        |
| networks       | ネットワーク定義                               | -    | []                              |
| security_group | セキュリティグループ名                         | -    | [default,ssh]                   |
| templates      | `user_data`のテンプレート.`./user_datas`に配置 | -    | [base.yaml,webserver.yaml]      |
| user_data      | cloud-init記法に準拠                           | -    | -                               |

##### Networks
| 項目名       | 説明             | 必須 | 例示           |
| ------------ | ---------------- | ---- | -------------- |
| device_name | デバイス名       | ○    | eth0           |
| bootproto    | 設定方式         | ○    | static or dhcp |
| ip_address   | IPアドレス(CIDR) | ※    | 10.1.1.1/24    |
| path   | NW設定保存パス |     | default:/etc/sysconfig/network-scripts/ifcfg-[device_name]    |
※ bootproto=staticの場合必須
上記以外の項目は設定ファイルに`KEY=value`形式で出力されます。

## Author
* pyama86
