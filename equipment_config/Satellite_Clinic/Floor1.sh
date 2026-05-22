### 11.4 SAT-1-SW-01 – Floor 2 Clinic (Tầng 1 – Khám chuyên khoa)
hostname SAT-1-SW-01
!
spanning-tree mode rapid-pvst
!
vlan 210
 name SAT-1-CLINIC
vlan 211
 name SAT-1-DIAGNOSTIC
vlan 212
 name SAT-1-CCTV
vlan 213
 name SAT-1-SW
!
interface Ethernet0/0
 description TRUNK-TO-SWL3_Clinic
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 210,211,212,213
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description CLINIC_STAFF
 switchport mode access
 switchport access vlan 210
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description DIAGNOSTIC_DEVICES
 switchport mode access
 switchport access vlan 211
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description CCTV_DEVICES
 switchport mode access
 switchport access vlan 212
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Vlan213
 description MANAGEMENT
 ip address 10.2.30.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.2.30.6
!
end
write memory