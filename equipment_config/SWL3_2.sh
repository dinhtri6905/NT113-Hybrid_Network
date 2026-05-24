hostname SWL3_2
!
! ===== OBJECT TRACKING =====
track 1 interface Ethernet0/0 line-protocol
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== ROUTED UPLINK → FIREWALL2 =====
interface Ethernet0/0
 description TO_FIREWALL2_INSIDE
 no switchport
 ip address 10.100.20.1 255.255.255.252
 no shutdown
!
! ===== ROUTED INTER-CORE LINK → SWL3_1 =====
interface Ethernet0/1
 description TO_SWL3_1_INTER_CORE
 no switchport
 ip address 10.100.30.2 255.255.255.252
 no shutdown
!
! ===== TRUNK → SWL3_3 (Distribution cross-backup) =====
interface Ethernet0/2
 description TO_SWL3_3_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK → SWL3_4 (Distribution primary – Tòa E) =====
interface Ethernet0/3
 description TO_SWL3_4_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – Tòa A (priority 100, .253, VIP .254 giống SWL3_1) =====
interface Vlan10
 description A-G-STAFF
 ip address 10.1.0.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 100
 standby 10 preempt
 standby 10 track 1 decrement 20
 no shutdown
!
interface Vlan11
 ip address 10.1.1.253 255.255.254.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 11 ip 10.1.1.254
 standby 11 priority 100
 standby 11 preempt
 standby 11 track 1 decrement 20
 no shutdown
!
interface Vlan12
 ip address 10.1.3.253 255.255.255.0
 standby version 2
 standby 12 ip 10.1.3.254
 standby 12 priority 100
 standby 12 preempt
 standby 12 track 1 decrement 20
 no shutdown
!
interface Vlan13
 ip address 10.1.4.125 255.255.255.128
 standby version 2
 standby 13 ip 10.1.4.126
 standby 13 priority 100
 standby 13 preempt
 standby 13 track 1 decrement 20
 no shutdown
!
interface Vlan20
 ip address 10.1.10.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 20 ip 10.1.10.254
 standby 20 priority 100
 standby 20 preempt
 standby 20 track 1 decrement 20
 no shutdown
!
interface Vlan21
 ip address 10.1.11.253 255.255.254.0
 standby version 2
 standby 21 ip 10.1.11.254
 standby 21 priority 100
 standby 21 preempt
 standby 21 track 1 decrement 20
 no shutdown
!
interface Vlan22
 ip address 10.1.13.253 255.255.255.0
 standby version 2
 standby 22 ip 10.1.13.254
 standby 22 priority 100
 standby 22 preempt
 standby 22 track 1 decrement 20
 no shutdown
!
interface Vlan23
 ip address 10.1.14.125 255.255.255.128
 standby version 2
 standby 23 ip 10.1.14.126
 standby 23 priority 100
 standby 23 preempt
 standby 23 track 1 decrement 20
 no shutdown
!
interface Vlan30
 ip address 10.1.20.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 30 ip 10.1.20.254
 standby 30 priority 100
 standby 30 preempt
 standby 30 track 1 decrement 20
 no shutdown
!
interface Vlan31
 ip address 10.1.21.253 255.255.254.0
 standby version 2
 standby 31 ip 10.1.21.254
 standby 31 priority 100
 standby 31 preempt
 standby 31 track 1 decrement 20
 no shutdown
!
interface Vlan32
 ip address 10.1.23.253 255.255.255.0
 standby version 2
 standby 32 ip 10.1.23.254
 standby 32 priority 100
 standby 32 preempt
 standby 32 track 1 decrement 20
 no shutdown
!
interface Vlan33
 ip address 10.1.24.125 255.255.255.128
 standby version 2
 standby 33 ip 10.1.24.126
 standby 33 priority 100
 standby 33 preempt
 standby 33 track 1 decrement 20
 no shutdown
!
interface Vlan40
 ip address 10.1.30.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 40 ip 10.1.30.254
 standby 40 priority 100
 standby 40 preempt
 standby 40 track 1 decrement 20
 no shutdown
!
interface Vlan41
 ip address 10.1.31.253 255.255.254.0
 standby version 2
 standby 41 ip 10.1.31.254
 standby 41 priority 100
 standby 41 preempt
 standby 41 track 1 decrement 20
 no shutdown
!
interface Vlan42
 ip address 10.1.33.253 255.255.255.0
 standby version 2
 standby 42 ip 10.1.33.254
 standby 42 priority 100
 standby 42 preempt
 standby 42 track 1 decrement 20
 no shutdown
!
interface Vlan43
 ip address 10.1.34.125 255.255.255.128
 standby version 2
 standby 43 ip 10.1.34.126
 standby 43 priority 100
 standby 43 preempt
 standby 43 track 1 decrement 20
 no shutdown
!
interface Vlan50
 ip address 10.1.40.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 50 ip 10.1.40.254
 standby 50 priority 100
 standby 50 preempt
 standby 50 track 1 decrement 20
 no shutdown
!
interface Vlan51
 ip address 10.1.41.253 255.255.254.0
 standby version 2
 standby 51 ip 10.1.41.254
 standby 51 priority 100
 standby 51 preempt
 standby 51 track 1 decrement 20
 no shutdown
!
interface Vlan52
 ip address 10.1.43.253 255.255.255.0
 standby version 2
 standby 52 ip 10.1.43.254
 standby 52 priority 100
 standby 52 preempt
 standby 52 track 1 decrement 20
 no shutdown
!
interface Vlan53
 ip address 10.1.44.125 255.255.255.128
 standby version 2
 standby 53 ip 10.1.44.126
 standby 53 priority 100
 standby 53 preempt
 standby 53 track 1 decrement 20
 no shutdown
!
interface Vlan60
 ip address 10.1.50.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 60 ip 10.1.50.254
 standby 60 priority 100
 standby 60 preempt
 standby 60 track 1 decrement 20
 no shutdown
!
interface Vlan61
 ip address 10.1.51.253 255.255.255.0
 standby version 2
 standby 61 ip 10.1.51.254
 standby 61 priority 100
 standby 61 preempt
 standby 61 track 1 decrement 20
 no shutdown
!
interface Vlan62
 ip address 10.1.52.253 255.255.255.0
 standby version 2
 standby 62 ip 10.1.52.254
 standby 62 priority 100
 standby 62 preempt
 standby 62 track 1 decrement 20
 no shutdown
!
interface Vlan63
 ip address 10.1.53.125 255.255.255.128
 standby version 2
 standby 63 ip 10.1.53.126
 standby 63 priority 100
 standby 63 preempt
 standby 63 track 1 decrement 20
 no shutdown
!
interface Vlan70
 ip address 10.1.60.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 70 ip 10.1.60.254
 standby 70 priority 100
 standby 70 preempt
 standby 70 track 1 decrement 20
 no shutdown
!
interface Vlan71
 ip address 10.1.61.253 255.255.255.0
 standby version 2
 standby 71 ip 10.1.61.254
 standby 71 priority 100
 standby 71 preempt
 standby 71 track 1 decrement 20
 no shutdown
!
interface Vlan72
 ip address 10.1.62.253 255.255.255.0
 standby version 2
 standby 72 ip 10.1.62.254
 standby 72 priority 100
 standby 72 preempt
 standby 72 track 1 decrement 20
 no shutdown
!
interface Vlan73
 ip address 10.1.63.125 255.255.255.128
 standby version 2
 standby 73 ip 10.1.63.126
 standby 73 priority 100
 standby 73 preempt
 standby 73 track 1 decrement 20
 no shutdown
!
interface Vlan76
 ip address 10.1.73.125 255.255.255.128
 standby version 2
 standby 76 ip 10.1.73.126
 standby 76 priority 100
 standby 76 preempt
 standby 76 track 1 decrement 20
 no shutdown
!
interface Vlan77
 ip address 10.1.72.253 255.255.255.0
 standby version 2
 standby 77 ip 10.1.72.254
 standby 77 priority 100
 standby 77 preempt
 standby 77 track 1 decrement 20
 no shutdown
!
interface Vlan78
 ip address 10.1.70.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 78 ip 10.1.70.254
 standby 78 priority 100
 standby 78 preempt
 standby 78 track 1 decrement 20
 no shutdown
!
interface Vlan79
 ip address 10.1.71.253 255.255.255.0
 standby version 2
 standby 79 ip 10.1.71.254
 standby 79 priority 100
 standby 79 preempt
 standby 79 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa E (priority 100) =====
interface Vlan82
 ip address 10.8.40.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 82 ip 10.8.40.254
 standby 82 priority 100
 standby 82 preempt
 standby 82 track 1 decrement 20
 no shutdown
!
interface Vlan85
 ip address 10.8.50.125 255.255.255.128
 standby version 2
 standby 85 ip 10.8.50.126
 standby 85 priority 100
 standby 85 preempt
 standby 85 track 1 decrement 20
 no shutdown
!
interface Vlan92
 ip address 10.9.40.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 92 ip 10.9.40.254
 standby 92 priority 100
 standby 92 preempt
 standby 92 track 1 decrement 20
 no shutdown
!
interface Vlan95
 ip address 10.9.50.125 255.255.255.128
 standby version 2
 standby 95 ip 10.9.50.126
 standby 95 priority 100
 standby 95 preempt
 standby 95 track 1 decrement 20
 no shutdown
!
interface Vlan102
 ip address 10.10.40.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 102 ip 10.10.40.254
 standby 102 priority 100
 standby 102 preempt
 standby 102 track 1 decrement 20
 no shutdown
!
interface Vlan105
 ip address 10.10.50.125 255.255.255.128
 standby version 2
 standby 105 ip 10.10.50.126
 standby 105 priority 100
 standby 105 preempt
 standby 105 track 1 decrement 20
 no shutdown
!
interface Vlan112
 ip address 10.11.40.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 112 ip 10.11.40.254
 standby 112 priority 100
 standby 112 preempt
 standby 112 track 1 decrement 20
 no shutdown
!
interface Vlan113
 ip address 10.11.50.253 255.255.255.0
 standby version 2
 standby 113 ip 10.11.50.254
 standby 113 priority 100
 standby 113 preempt
 standby 113 track 1 decrement 20
 no shutdown
!
interface Vlan115
 ip address 10.11.60.125 255.255.255.128
 standby version 2
 standby 115 ip 10.11.60.126
 standby 115 priority 100
 standby 115 preempt
 standby 115 track 1 decrement 20
 no shutdown
!
! ===== SVI – Management =====
interface Vlan999
 description OOB-MANAGEMENT 10.99.99.0/27
 ip address 10.99.99.3 255.255.255.224
 no shutdown
!
interface Vlan1040
 description INBAND-MGMT
 ip address 10.100.40.253 255.255.255.0
 standby version 2
 standby 1040 ip 10.100.40.254
 standby 1040 priority 100
 standby 1040 preempt
 standby 1040 track 1 decrement 20
 no shutdown
!
interface Vlan1041
 ip address 10.100.31.61 255.255.255.192
 no shutdown
!
interface Vlan1042
 ip address 10.100.32.61 255.255.255.192
 no shutdown
!
interface Vlan1043
 ip address 10.100.33.61 255.255.255.192
 no shutdown
!
! ===== OSPF =====
router ospf 1
 router-id 2.2.2.2
 network 10.1.0.0 0.0.255.255 area 0
 network 10.8.0.0 0.7.255.255 area 0
 network 10.9.0.0 0.0.255.255 area 0
 network 10.10.0.0 0.0.255.255 area 0
 network 10.11.0.0 0.0.255.255 area 0
 network 10.99.99.0 0.0.0.31 area 0
 network 10.100.20.0 0.0.0.3 area 0
 network 10.100.30.0 0.0.0.3 area 0
 network 10.100.31.0 0.0.0.63 area 0
 network 10.100.32.0 0.0.0.63 area 0
 network 10.100.33.0 0.0.0.63 area 0
 network 10.100.40.0 0.0.0.255 area 0
 default-information originate
 passive-interface default
 no passive-interface Ethernet0/0
 no passive-interface Ethernet0/1
!
ip route 0.0.0.0 0.0.0.0 10.100.20.2
!
! ===== SPANNING TREE – Core STANDBY =====
spanning-tree vlan 1-4094 priority 8192
!
username admin privilege 15 secret VinHealth@Core
ip domain-name vinhealth.local
ip ssh version 2
crypto key generate rsa modulus 2048
!
line vty 0 15
 login local
 transport input ssh
!
logging host 10.100.32.10
service timestamps log datetime msec
ntp server 10.100.33.1
!
end