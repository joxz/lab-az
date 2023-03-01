# vpngw-zscaler

This lab builds an IPSec VPN connection from Azure VPN Gateway to Zscaler

TODO: 
- Check Peering settings (remote gateway transit)
- Try building tunnel with Zscaler (adjust VPN tunnel settings)

Current route tables:

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