enable
configure terminal

hostname Firewall2
!
ip cef
!
! =====================================================
! 1. INTERFACES
! =====================================================

! OUTSIDE -> R2
interface FastEthernet2/0
 description OUTSIDE_TO_R2
 ip address 10.100.4.6 255.255.255.252
 ip nat outside
 ip access-group OUTSIDE_IN in
 no shutdown
!
! INSIDE -> Core SwitchL3_2
interface FastEthernet0/0
 description INSIDE_TO_SWL3_2
 ip address 10.100.20.2 255.255.255.252
 ip nat inside
 no shutdown
!
!
! =====================================================
! 2. ROUTING
! =====================================================

! Default route to R2
ip route 0.0.0.0 0.0.0.0 10.100.4.5

! Internal networks via Core Switch
ip route 10.1.0.0 255.255.0.0 10.100.20.1
ip route 10.2.0.0 255.255.0.0 10.100.20.1
ip route 10.8.0.0 255.248.0.0 10.100.20.1
ip route 10.99.99.0 255.255.255.224 10.100.20.1
ip route 10.100.0.0 255.255.0.0 10.100.20.1
ip route 10.200.0.0 255.255.255.0 10.100.20.1
!
!
! =====================================================
! 3. NAT / PAT
! =====================================================

access-list 1 permit 10.0.0.0 0.255.255.255

ip nat inside source list 1 interface FastEthernet2/0 overload
!
!
! =====================================================
! 4. ACL SECURITY
! =====================================================

ip access-list extended INSIDE_IN
 permit ip 10.0.0.0 0.255.255.255 any
 deny ip any any log
 exit
!
ip access-list extended OUTSIDE_IN
 permit tcp any 10.200.10.0 0.0.0.255 eq 80
 permit tcp any 10.200.10.0 0.0.0.255 eq 443
 permit icmp any any echo-reply
 deny ip any any log
 exit
!
!
! =====================================================
! 5. SSH / MANAGEMENT
! =====================================================

aaa new-model
aaa authentication login default local
!
username admin privilege 15 secret VinHealth@FW2
!
ip domain-name vinhealth.local
crypto key generate rsa modulus 2048
ip ssh version 2
!
line vty 0 4
 login authentication default
 transport input ssh
 exec-timeout 10 0
!
!
! =====================================================
! 6. LOGGING
! =====================================================

logging buffered 16384 informational
service timestamps log datetime msec localtime
no ip http server
no ip http secure-server
!
end
write memory