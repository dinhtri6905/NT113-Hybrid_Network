hostname SWL3_Clinic
!
ip routing
spanning-tree mode rapid-pvst
!
! ===== VLAN DATABASE =====
vlan 200
 name SAT-G-RECEPTION
vlan 201
 name SAT-G-EMERGENCY
vlan 202
 name SAT-G-CCTV
vlan 203
 name SAT-G-SW
vlan 210
 name SAT-1-CLINIC
vlan 211
 name SAT-1-DIAGNOSTIC
vlan 212
 name SAT-1-CCTV
vlan 213
 name SAT-1-SW
vlan 220
 name SAT-2-SERVER-ROOM
vlan 221
 name SAT-2-FIREWALL-MGMT
vlan 222
 name SAT-2-VPN-TUNNEL
vlan 223
 name SAT-2-CCTV
!
! ===== UPLINK KẾT NỐI R3/FW3  =====
interface Ethernet0/0
 description TO_FIREWALL3_INSIDE
 no switchport
 ip address 10.2.41.1 255.255.255.248
 no shutdown
!
! ===== DOWNLINK TRUNK XUỐNG FLOOR SWITCHES =====
interface Ethernet3/0
 description TO_SAT_FloorG
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 200,201,202,203
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/1
 description TO_SAT_Floor1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 210,211,212,213
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/2
 description TO_SAT_Floor2_MDF
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 220,221,222,223
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI =====
interface Vlan200
 description SAT-G-RECEPTION 10.2.0.0/24
 ip address 10.2.0.254 255.255.255.0
 ip helper-address 10.100.31.10
 no shutdown
!
interface Vlan201
 description SAT-G-EMERGENCY 10.2.1.0/24
 ip address 10.2.1.254 255.255.255.0
 ip helper-address 10.100.31.10
 no shutdown
!
interface Vlan202
 description SAT-G-CCTV 10.2.2.0/25
 ip address 10.2.2.124 255.255.255.128
 no shutdown
!
interface Vlan203
 description SAT-G-SWITCH-MGMT
 ip address 10.2.10.6 255.255.255.248
 no shutdown
!
interface Vlan210
 description SAT-1-CLINIC 10.2.20.0/24
 ip address 10.2.20.254 255.255.255.0
 ip helper-address 10.100.31.10
 no shutdown
!
interface Vlan211
 description SAT-1-DIAGNOSTIC 10.2.21.0/24
 ip address 10.2.21.254 255.255.255.0
 no shutdown
!
interface Vlan212
 description SAT-1-CCTV 10.2.22.0/25
 ip address 10.2.22.124 255.255.255.128
 no shutdown
!
interface Vlan213
 description SAT-1-SWITCH-MGMT
 ip address 10.2.30.6 255.255.255.248
 no shutdown
!
interface Vlan220
 description SAT-2-SERVER-ROOM 10.2.40.0/25
 ip address 10.2.40.124 255.255.255.128
 no shutdown
!
interface Vlan221
 description SAT-2-FIREWALL-MGMT
 ip address 10.2.42.1 255.255.255.248
 no shutdown
!
interface Vlan223
 description SAT-2-CCTV 10.2.43.0/25
 ip address 10.2.43.124 255.255.255.128
 no shutdown
!
! ===== ROUTING =====
ip route 10.1.0.0 255.255.0.0 10.2.41.2
ip route 10.8.0.0 255.248.0.0 10.2.41.2
ip route 10.100.0.0 255.255.0.0 10.2.41.2
ip route 0.0.0.0 0.0.0.0 10.2.41.2
!
!
username admin privilege 15 secret nt113-project
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
!
ntp server 10.100.33.1
logging host 10.100.32.10
end
write memory