# vpngw-zscaler

This lab builds an IPSec VPN connection from Azure VPN Gateway to Zscaler

Target solution is to use the tunnel to Zscaler in a default route environment and a no-default route environment (manual proxy on a VM)

Note: This would easily be achievable using a NVA to do the VPN tunnel and DNAT (e.g. Fortigate). However, that is not possible

## Things to check out 
- Check Peering settings (remote gateway transit)
- Try building tunnel with Zscaler (adjust VPN tunnel settings)
- DNAT solutions for non-default route environments (how to send traffic into the tunnel)

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

Problem: Health probes probably aren't forwarded through the tunnel, because they originate from `168.63.129.16`, instance is therefore not reachable

> Load Balancer health probes originate from the IP address 168.63.129.16 and must not be blocked for probes to mark your instance as up

[Azure Load Balancer health probes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview#probe-source-ip-address)

[What is IP 168.63.129.16?](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-faqs#what-is-ip-168-63-129-16-)

