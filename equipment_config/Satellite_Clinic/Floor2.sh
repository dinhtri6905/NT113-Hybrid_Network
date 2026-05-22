### 11.5 Floor 3 – MDF Satellite (Tầng 2 – Server Room)

```
hostname SAT-MDF-SW-01
!
vlan 220
 name SAT-2-SERVER-ROOM
vlan 221
 name SAT-2-FIREWALL-ASA
vlan 223
 name SAT-2-CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 220,221,223
 no shutdown
!
interface range GigabitEthernet0/2 - 8
 description SERVER_ROOM_EQUIPMENT
 switchport mode access
 switchport access vlan 220
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 12
 description CCTV_MDF
 switchport mode access
 switchport access vlan 223
 spanning-tree portfast
 no shutdown
!
interface Vlan220
 ip address 10.2.40.1 255.255.255.128
 no shutdown
!
ip default-gateway 10.2.40.126
end