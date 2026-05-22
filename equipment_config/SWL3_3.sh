hostname SWL3_3
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== UPLINK TRUNK → SWL3_1 (Primary) =====
interface Ethernet0/3
 description TO_SWL3_1_PRIMARY_UPLINK
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 100
 no shutdown
!
! ===== UPLINK TRUNK → SWL3_2 (Cross-Backup) =====
interface Ethernet0/2
 description TO_SWL3_2_CROSS_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 200
 no shutdown
!
! ===== DOWNLINK – TÒA A ACCESS SWITCHES =====
interface Ethernet1/0
 description TO_A-G-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet1/1
 description TO_A-1-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet1/2
 description TO_A-2-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet1/3
 description TO_A-3-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description TO_A-4-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/1
 description TO_A-5-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/2
 description TO_A-6-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/3
 description TO_A-7-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree portfast trunk
 no shutdown
!
! ===== DOWNLINK – TÒA E ACCESS SWITCHES (cross-backup) =====
interface Ethernet3/0
 description TO_E-G-SW-01_ACCESS_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/1
 description TO_E-1-SW-01_ACCESS_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/2
 description TO_E-2-SW-01_ACCESS_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/3
 description TO_E-3-SW-01_ACCESS_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI – Distribution (IP .250/mask, chỉ OSPF, không HSRP) =====
interface Vlan10
 description A-G-STAFF
 ip address 10.1.0.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan20
 description A-1-STAFF
 ip address 10.1.10.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan30
 description A-2-STAFF
 ip address 10.1.20.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan40
 description A-3-STAFF
 ip address 10.1.30.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan50
 description A-4-STAFF
 ip address 10.1.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan60
 description A-5-STAFF
 ip address 10.1.50.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan70
 description A-6-STAFF
 ip address 10.1.60.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan78
 description A-7-STAFF
 ip address 10.1.70.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan82
 description E-G-EXECUTIVE-STAFF
 ip address 10.8.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan92
 description E-1-FINANCE-STAFF
 ip address 10.9.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan102
 description E-2-HR-STAFF
 ip address 10.10.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan112
 description E-3-IT-STAFF
 ip address 10.11.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan113
 description E-3-SERVER-FARM
 ip address 10.11.50.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan999
 description OOB-MANAGEMENT
 ip address 10.99.99.4 255.255.255.224
 no shutdown
!
interface Vlan1040
 description INBAND-MGMT
 ip address 10.100.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
! ===== OSPF =====
router ospf 1
 router-id 3.3.3.3
 network 10.1.0.0 0.0.255.255 area 0
 network 10.8.0.0 0.7.255.255 area 0
 network 10.9.0.0 0.0.255.255 area 0
 network 10.10.0.0 0.0.255.255 area 0
 network 10.11.0.0 0.0.255.255 area 0
 network 10.99.99.0 0.0.0.31 area 0
 network 10.100.40.0 0.0.0.255 area 0
 passive-interface default
 no passive-interface Ethernet0/3
 no passive-interface Ethernet0/2
!
! ===== SPANNING TREE =====
! SWL3_3 là STP root cho Tòa A (priority thấp hơn SWL3_4 với Tòa A)
! SWL3_3 là STP backup cho Tòa E
spanning-tree vlan 10-79 priority 16384
spanning-tree vlan 82-999 priority 24576
!
username admin privilege 15 secret VinHealth@Dist
ip domain-name vinhealth.local
ip ssh version 2
crypto key generate rsa modulus 2048
!
line vty 0 4
 login local
 transport input ssh
!
logging host 10.100.32.10
service timestamps log datetime msec
ntp server 10.100.33.1
!
end