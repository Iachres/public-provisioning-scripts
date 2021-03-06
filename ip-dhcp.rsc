:log info "started ip-dhcp script";
:global WANInterfaceName [/interface get [/interface find comment=WAN] name];
:if ( [/ip pool find where name=default-dhcp] = "") do={
  :log info "Adding default DHCP pool";
  /ip pool add name=default-dhcp ranges=192.168.88.10-192.168.88.254;
} else={
  :log info "Default DHCP Pool Already Exists";
}
:local DHCPPoolExists [:len [/ip dhcp-server find address-pool=default-dhcp]];
:if (($DHCPPoolExists = 0 ) && ([/ip dhcp-server find where name=default-dhcp] = "")) do={
  :log info "Adding DHCP pool to server";
  /ip dhcp-server add address-pool=default-dhcp disabled=no interface=bridge name=defconf;
}

/ip neighbor discovery-settings set discover-interface-list=all

:if ( [:len [/interface list member find interface=bridge]] = 0 ) do={
  /interface list member add comment=defconf interface=bridge list=LAN;
}

:if ( [:len [/interface list member find interface=$WANInterfaceName]] = 0 ) do={
  /interface list member add comment=defconf interface=$WANInterfaceName list=WAN;
}
:if ( [/ip address find network=192.168.88.0 interface=bridge ] = "" ) do={
  /ip address add address=192.168.88.1/24 comment=defconf interface=bridge network=192.168.88.0;
}

:if ([/ip dhcp-client get [/ip dhcp-client find interface=$WANInterfaceName] value-name=interface] = "" ) do={
  /ip dhcp-client add comment=defconf dhcp-options=hostname,clientid disabled=no interface=$WANInterfaceName;
}
:if ([/ip dhcp-server get [/ip dhcp-server find comment=defconf] value-name=address] = "" ) do={
  /ip dhcp-server network add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1;
}
/ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.4.4;
:log info "Finished ip-dhcp script";
