def ports
  [
    double(
      id: 1,
      name: "eth0",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "10.10.10.10"
        }
      ]
    ),
    double(
      id: 1,
      name: "eth1",
      mac_address: '00:00:00:00:00:00',
      fixed_ips: [
        {
          'ip_address' => "20.20.20.20"
        }
      ]
    )
  ]
end

def networks
  [
    [
      "eth0",
      {
        "bootproto" => "static",
        "ip_address" => "10.10.10.10/24",
        "dns-nameservers" => "8.8.8.8",
        "gateway" => "1.1.1.1"
      }
    ],
    [
      "eth1",
      {
        "bootproto" => "static",
        "ip_address" => "20.20.20.20/24",
        "dns-nameservers" => "8.8.8.8",
        "gateway" => "2.2.2.2"
      }
    ]
  ]
end
