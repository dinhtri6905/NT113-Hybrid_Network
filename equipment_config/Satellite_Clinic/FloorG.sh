! === SAT_FloorG (Tầng G – Tiếp nhận & Cấp cứu) ===
hostname SAT_FloorG
!
spanning-tree mode rapid-pvst
!
vlan 200
 name SAT-G-RECEPTION
vlan 201
 name SAT-G-EMERGENCY
vlan 202
 name SAT-G-CCTV
vlan 203
 name SAT-G-SW-MGMT
!
interface Vlan203
 description MANAGEMENT
 ip address 10.2.10.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.2.10.6
!
interface Ethernet0/0
 description TRUNK-TO-SWL3_Clinic
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport nonegotiate
 switchport trunk allowed vlan 200,201,202,203
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN200-RECEPTION
 switchport mode access
 switchport access vlan 200
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN201-EMERGENCY
 switchport mode access
 switchport access vlan 201
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN202-CCTV
 switchport mode access
 switchport access vlan 202
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
ntp server 10.100.33.1
logging host 10.100.32.10
end
write memory