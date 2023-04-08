# linux-ipsec-zscaler

route-based

would need vti0 interface up/down script to add or delete the VPN route `ip route add 185.46.212.88 dev vti0`

```sh
# /etc/ipsec.d/zscaler.conf
conn zscaler
    type=tunnel
    authby=secret
    auto=start
    left=%defaultroute
    leftid={{ VM PUBLIC IP }}
    leftsubnet=0.0.0.0/0
    right=fra4-vpn.zscaler.net
    rightsubnet=0.0.0.0/0
    mark=5/0xffffffff
    vti-interface=vti0
    vti-routing=no
    ikev2=yes
    ike=aes256-sha2_256;dh14
    ikelifetime=86400s
    dpdaction=restart
    dpdtimeout=20s
    dpddelay=25s
    nat-keepalive=yes
    phase2=esp
    esp=null-md5
    salifetime=28800s
```

```
# /etc/ipsec.d/zscaler.secrets
fra4-vpn.zscaler.net : PSK "sCAkcUDwK4cqBLw9H8G"

# 
%any %any : PSK "sCAkcUDwK4cqBLw9H8G"
#
 : PSK "sCAkcUDwK4cqBLw9H8G"
```

ipsec whack --status
ipsec whack --trafficstatus
tcpdump -n -i eth0 esp or udp port 500 or udp port 4500

policy-based:
```sh
# /etc/ipsec.d/zscaler.conf
conn zscaler
    type=tunnel
    authby=secret
    auto=start
    left=%defaultroute
    leftid={{ VM PUBLIC IP }}
    leftsubnet=0.0.0.0/0
    right=fra4-vpn.zscaler.net
    rightsubnet=185.46.212.88/32
    vti-interface=vti0
    vti-routing=yes
    mark=5/0xffffffff
    ikev2=yes
    ike=aes256-sha2_256;dh14
    ikelifetime=86400s
    dpdaction=restart
    dpdtimeout=20s
    dpddelay=25s
    nat-keepalive=yes
    phase2=esp
    esp=null-md5
    salifetime=28800s
```