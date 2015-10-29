# Pec
[![Build Status](https://travis-ci.org/pyama86/pec.svg?branch=master)](https://travis-ci.org/pyama86/pec)
[![Code Climate](https://codeclimate.com/github/pyama86/pec/badges/gpa.svg)](https://codeclimate.com/github/pyama86/pec)
[![Test Coverage](https://codeclimate.com/github/pyama86/pec/badges/coverage.svg)](https://codeclimate.com/github/pyama86/pec/coverage)

OpenStack Vm create wrapper

## Install

    $ gem install pec

## Usage
    # set up
    $ pec init

```
create - /Pec.yaml
create - /user_data/web_server.yaml.sample
```

    $ pec up <hostname_regex> <hostname_regex>...

    $ pec destroy <hostname_regex> <hostname_regex>... 

    $ pec status <hostname_regex> <hostname_regex>...

    $ pec config <hostname_regex> <hostname_regex>...

### Configure
#### Pec.yaml
```
# merge of yaml
_default_: &def
  tenant: your_tenant
  image: centos-7.1_chef-12.3_puppet-3.7
  flavor: m1.small
  availability_zone: nova

# vm config
pyama-test001:
  <<: *def
  networks:
    eth0:
      bootproto: static
      allowed_address_pairs:
      - 10.1.1.5/24
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
  <<: *def
・・・

# include config
inludes:
  - path/to/a.yaml
  - path/to/b.yaml

```
##### Detail

| column            | require | value                           |
| ----------------- | ------- | ------------------------------- |
| instance_name     |    ○    | pyama-test001*                  |
| tenant            |    ○    | your_tenant                     |
| image             |    ○    | centos-7.1_chef-12.3_puppet-3.7 |
| flavor            |    ○    | m1.small                        |
| networks          |    -    | []                              |
| security_group    |    -    | [default,ssh]                   |
| templates         |    -    | [base.yaml,webserver.yaml]      |
| user_data         |    -    | -                               |
| availability_zone |    -    | nova                            |

* it begins with `_` instance name is yaml merge template

##### Networks
| column                | require | value                                                      |
| --------------------- | --------| ---------------------------------------------------------- |
| bootproto             |    ○    | static or dhcp                                             |
| ip_address            |    ※    | 10.1.1.1/24                                                |
| path                  |         | default:/etc/sysconfig/network-scripts/ifcfg-[device_name] |
| allowed_address_pairs |         | [10.1.1.2/24]                                              |

※ bootproto=static is required
Items other than the above are output to the configuration file with `KEY = value` format

#### Includes
```yaml
# example
inludes:
  - path/to/a.yaml
  - path/to/b.yaml
```

Read order is this as
1.Pec.yaml
2.path/to/a.yaml
3.path/to/b.yaml

## Author
* pyama86
