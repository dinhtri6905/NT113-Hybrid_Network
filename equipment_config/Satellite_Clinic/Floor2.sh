### 11.5 Floor 3 – MDF Satellite (Tầng 2 – Server Room)
hostname SAT-MDF-SW-01
!
spanning-tree mode rapid-pvst
!
vlan 220
 name SAT-2-SERVER-ROOM
vlan 221
 name SAT-2-FIREWALL-ASA
vlan 223
 name SAT-2-CCTV
!
interface Ethernet0/0
 description TRUNK-TO-SWL3_Clinic
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 220,221,222,223
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description SERVER_ROOM_EQUIPMENT
 switchport mode access
 switchport access vlan 220
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description CCTV_MDF
 switchport mode access
 switchport access vlan 223
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Vlan220
 ip address 10.2.40.1 255.255.255.128
 no shutdown
!
ip default-gateway 10.2.40.126
end
write memory