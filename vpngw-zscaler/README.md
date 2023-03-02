# vpngw-zscaler lab notes

This lab builds an IPSec VPN connection from Azure VPN Gateway to Zscaler

Target solution is to use the tunnel to Zscaler in a default route and a no-default route environment (manual proxy on a VM)

Note: This would easily be achievable using a NVA to do the VPN tunnel and DNAT (e.g. Fortigate). However, that is not possible

## Things to check out 
- [x] Check Peering settings (remote gateway transit)
- [x] Try building tunnel with Zscaler (adjust VPN tunnel settings)
- [ ] DNAT solutions for non-default route environments (how to send traffic into the tunnel)
- [ ] Test VMSS Bicep config
- [ ] Linux GRE tunnel to Zscaler maybe?
- [ ] iptables metrics for VM - telegraf iptables plugin

## Default route env

### Routing tables when VPN tunnel is DOWN

```bash
az network nic show-effective-route-table -n nic-vm-gw -g rg-zsc-vpngw -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.1.0.0/16       VnetLocal
Default   Active   10.8.0.0/16       VNetPeering
Default   Active   0.0.0.0/0         Internet

###

az network nic show-effective-route-table -n nic-vm-sp -g rg-zsc-vpngw -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.8.0.0/16       VnetLocal
Default   Active   10.1.0.0/16       VNetPeering
Default   Active   0.0.0.0/0         Internet

###

az network vnet-gateway list-learned-routes -g rg-zsc-vpngw -n vpngw-zsc -o table
Network      NextHop    Origin    SourcePeer    AsPath    Weight
-----------  ---------  --------  ------------  --------  --------
10.1.0.0/16             Network   10.1.0.7                32768
10.1.0.0/16             Network   10.1.0.6                32768
```

### Routing tables when VPN tunnel is UP

```bash
az network nic show-effective-route-table -n nic-vm-gw -g rg-zsc-vpngw -o table
Source                 State    Address Prefix    Next Hop Type          Next Hop IP
---------------------  -------  ----------------  ---------------------  -------------
Default                Active   10.1.0.0/16       VnetLocal
Default                Active   10.8.0.0/16       VNetPeering
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.7
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.7
Default                Active   0.0.0.0/0         Internet

###
# Spoke Vnet has 'Use the remote virtual network's gatway or Route Server' UNSET

az network nic show-effective-route-table -n nic-vm-sp -g rg-zsc-vpngw -o table
Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.8.0.0/16       VnetLocal
Default   Active   10.1.0.0/16       VNetPeering
Default   Active   0.0.0.0/0         Internet

# Spoke Vnet has 'Use the remote virtual network's gatway or Route Server' SET
az network nic show-effective-route-table -n nic-vm-sp -g rg-zsc-vpngw -o table
Source                 State    Address Prefix    Next Hop Type          Next Hop IP
---------------------  -------  ----------------  ---------------------  -------------
Default                Active   10.8.0.0/16       VnetLocal
Default                Active   10.1.0.0/16       VNetPeering
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.7
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.7
Default                Active   0.0.0.0/0         Internet

###

az network nic show-effective-route-table -n nic-vm-gw -g rg-zsc-vpngw -o table
Source                 State    Address Prefix    Next Hop Type          Next Hop IP
---------------------  -------  ----------------  ---------------------  -------------
Default                Active   10.1.0.0/16       VnetLocal
Default                Active   10.8.0.0/16       VNetPeering
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   0.0.0.0/1         VirtualNetworkGateway  10.1.0.7
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   128.0.0.0/1       VirtualNetworkGateway  10.1.0.7
Default                Active   0.0.0.0/0         Internet
````

## Non-default route env
### Advertising Global Public Service Edges in the VPN tunnel

[About Global Public Service Edges](https://help.zscaler.com/zia/about-global-zscaler-enforcement-nodes)

Zscaler VPN test URL: `http://gateway.zscaler.net/vpntest`

Note: PAC file on spoke VM cannot resolve to e.g. 185.46.212.88 due to onpremise restrictions, which would make everything easier

```bash
az network nic show-effective-route-table -n nic-vm-gw -g rg-zsc-vpngw -o table
Source                 State    Address Prefix    Next Hop Type          Next Hop IP
---------------------  -------  ----------------  ---------------------  -------------
Default                Active   10.1.0.0/16       VnetLocal
Default                Active   10.8.0.0/16       VNetPeering
VirtualNetworkGateway  Active   185.46.212.88/32  VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   185.46.212.88/32  VirtualNetworkGateway  10.1.0.7
VirtualNetworkGateway  Active   185.46.212.89/32  VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   185.46.212.89/32  VirtualNetworkGateway  10.1.0.7
Default                Active   0.0.0.0/0         Internet

###

az network nic show-effective-route-table -n nic-vm-sp -g rg-zsc-vpngw -o table
Source                 State    Address Prefix    Next Hop Type          Next Hop IP
---------------------  -------  ----------------  ---------------------  -------------
Default                Active   10.8.0.0/16       VnetLocal
Default                Active   10.1.0.0/16       VNetPeering
VirtualNetworkGateway  Active   185.46.212.88/32  VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   185.46.212.88/32  VirtualNetworkGateway  10.1.0.7
VirtualNetworkGateway  Active   185.46.212.89/32  VirtualNetworkGateway  10.1.0.6
VirtualNetworkGateway  Active   185.46.212.89/32  VirtualNetworkGateway  10.1.0.7
Default                Active   0.0.0.0/0         Internet
```

### DNAT solutions

Problem: Traffic in non-default route environments needs to be forwarded into the tunnel

#### Azure Load Balancer

Problem: Health probes probably aren't forwarded into the tunnel, because they originate from `168.63.129.16`. The backend pool is therefore not reachable

> Load Balancer health probes originate from the IP address 168.63.129.16 and must not be blocked for probes to mark your instance as up

[Azure Load Balancer health probes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview#probe-source-ip-address)

[What is IP 168.63.129.16?](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-faqs#what-is-ip-168-63-129-16-)

#### Linux NVA

Use `vm-gwsn` to do a DNAT into the VPN tunnel

Note: Destination port `10101` is a Zscaler dedicated proxy port

```
sysctl -w net.ipv4.ip_forward=1

echo 1 > /proc/sys/net/ipv4/ip_forward

sudo iptables -t nat -L -v

sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 10101 -j DNAT --to-destination 185.46.212.88:10101
sudo iptables -t nat -A POSTROUTING -d 185.46.212.88 -j MASQUERADE

watch -n 1 "sudo iptables-save -t nat -c"

 ```

working result:

```
jo@vm-gwsn:~$ tcpdump -i eth0 'port 10101' 

17:53:16.490228 IP 185.46.212.88.10101 > 10.1.1.4.57323: Flags [P.], seq 193959:193998, ack 2964, win 2113, length 39
17:53:16.490241 IP 10.1.1.4.10101 > 10.8.0.4.57323: Flags [P.], seq 193928:193959, ack 2964, win 2113, length 31
17:53:16.490244 IP 10.1.1.4.10101 > 10.8.0.4.57323: Flags [P.], seq 193959:193998, ack 2964, win 2113, length 39
17:53:16.490723 IP 10.8.0.4.57323 > 10.1.1.4.10101: Flags [P.], seq 2964:2999, ack 193928, win 2050, length 35
17:53:16.490723 IP 10.8.0.4.57323 > 10.1.1.4.10101: Flags [.], ack 193998, win 2050, length 0
17:53:16.490739 IP 10.1.1.4.57323 > 185.46.212.88.10101: Flags [P.], seq 2964:2999, ack 193928, win 2050, length 35
17:53:16.490743 IP 10.1.1.4.57323 > 185.46.212.88.10101: Flags [.], ack 193998, win 2050, length 0
17:53:16.490850 IP 10.8.0.4.57323 > 10.1.1.4.10101: Flags [P.], seq 2999:3038, ack 193998, win 2050, length 39
17:53:16.490853 IP 10.1.1.4.57323 > 185.46.212.88.10101: Flags [P.], seq 2999:3038, ack 193998, win 2050, length 39
17:53:16.495014 IP 185.46.212.88.10101 > 10.1.1.4.57323: Flags [.], ack 3038, win 2111, length 0
17:53:16.495027 IP 10.1.1.4.10101 > 10.8.0.4.57323: Flags [.], ack 3038, win 2111, length 0
17:53:16.543674 IP 10.8.0.4.57327 > 10.1.1.4.10101: Flags [P.], seq 3424:3463, ack 13642, win 2050, length 39
17:53:16.543702 IP 10.1.1.4.57327 > 185.46.212.88.10101: Flags [P.], seq 3424:3463, ack 13642, win 2050, length 39

###

jo@vm-gwsn:~$ sudo iptables -t nat -L -v
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  127  6604 DNAT       tcp  --  eth0   any     anywhere             anywhere             tcp dpt:10101 to:185.46.212.88:10101

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
   56  2912 MASQUERADE  all  --  any    any     anywhere             185.46.212.88       

###

# Generated by iptables-save v1.8.7 on Thu Mar  2 18:58:36 2023
*security
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [7853:1150983]
-A OUTPUT -d 168.63.129.16/32 -p tcp -m tcp --dport 53 -j ACCEPT
-A OUTPUT -d 168.63.129.16/32 -p tcp -m owner --uid-owner 0 -j ACCEPT
-A OUTPUT -d 168.63.129.16/32 -p tcp -m conntrack --ctstate INVALID,NEW -j DROP
COMMIT
# Completed on Thu Mar  2 18:58:36 2023
# Generated by iptables-save v1.8.7 on Thu Mar  2 18:58:36 2023
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp -m tcp --dport 10101 -j DNAT --to-destination 185.46.212.88:10101
-A POSTROUTING -d 185.46.212.88/32 -j MASQUERADE
COMMIT
# Completed on Thu Mar  2 18:58:36 2023
````

Downside: Client IP is not preserved because of the DNAT

VM considerations:

[Expected network bandwidth for Azure VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series#dsv2-series)

DSv2-series  supports ephemeral OS disks

#### Linux NVA as VMSS

For availability and scalability reasons, a VMSS can be considered. The VMs can run kind of stateless with a minimal cloud-init config and ephemeral OS disk.

Instances can be scaled on CPU, RAM and networking metrics