### 11.4 SAT-1-SW-01 – Floor 2 Clinic (Tầng 1 – Khám chuyên khoa)

```
hostname SAT-1-SW-01
!
vlan 210
 name SAT-1-CLINIC
vlan 211
 name SAT-1-DIAGNOSTIC
vlan 212
 name SAT-1-CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 210,211,212
 no shutdown
!
interface range GigabitEthernet0/2 - 12
 description CLINIC_STAFF
 switchport mode access
 switchport access vlan 210
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/13 - 18
 description DIAGNOSTIC_DEVICES
 switchport mode access
 switchport access vlan 211
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/19 - 24
 switchport mode access
 switchport access vlan 212
 spanning-tree portfast
 no shutdown
!
interface Vlan210
 ip address 10.2.20.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.2.20.254
end