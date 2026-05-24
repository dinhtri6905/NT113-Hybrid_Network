hostname SWL3_1
!
! ===== OBJECT TRACKING =====
track 1 interface Ethernet0/0 line-protocol
!
ip routing
spanning-tree mode rapid-pvst
!
! ===== VTP =====
vtp mode server
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== VLAN DATABASE – Tòa A =====
vlan 10
 name A-G-STAFF
vlan 11
 name A-G-PATIENT-WIFI
vlan 12
 name A-G-DEVICES
vlan 13
 name A-G-CCTV
vlan 20
 name A-1-STAFF
vlan 21
 name A-1-PACS-DICOM
vlan 22
 name A-1-DEVICES
vlan 23
 name A-1-CCTV
vlan 30
 name A-2-STAFF
vlan 31
 name A-2-LIS-IOT
vlan 32
 name A-2-DEVICES
vlan 33
 name A-2-CCTV
vlan 40
 name A-3-STAFF
vlan 41
 name A-3-CRITICAL-DEVICES
vlan 42
 name A-3-MONITORING
vlan 43
 name A-3-CCTV
vlan 50
 name A-4-STAFF
vlan 51
 name A-4-CRITICAL-DEVICES
vlan 52
 name A-4-MONITORING
vlan 53
 name A-4-CCTV
vlan 60
 name A-5-STAFF
vlan 61
 name A-5-PATIENT-WIFI
vlan 62
 name A-5-NURSE-CALL
vlan 63
 name A-5-CCTV
vlan 70
 name A-6-STAFF
vlan 71
 name A-6-PATIENT-WIFI
vlan 72
 name A-6-NURSE-CALL
vlan 73
 name A-6-CCTV
vlan 76
 name A-7-CCTV
vlan 77
 name A-7-NURSE-CALL
vlan 78
 name A-7-STAFF
vlan 79
 name A-7-PATIENT-WIFI-VIP
!
! ===== VLAN DATABASE – Tòa E =====
vlan 82
 name E-G-EXECUTIVE-STAFF
vlan 85
 name E-G-CCTV
vlan 86
 name E-G-ACCESS-SW
vlan 92
 name E-1-FINANCE-STAFF
vlan 95
 name E-1-CCTV
vlan 96
 name E-1-ACCESS-SW
vlan 102
 name E-2-HR-STAFF
vlan 105
 name E-2-CCTV
vlan 106
 name E-2-ACCESS-SW
vlan 112
 name E-3-IT-STAFF
vlan 113
 name E-3-SERVER-FARM
vlan 115
 name E-3-CCTV
vlan 116
 name E-3-ACCESS-SW
vlan 999
 name OOB-MANAGEMENT
!
! ===== VLAN DATABASE – Infrastructure =====
vlan 1000
 name CORE-NETWORK
vlan 1010
 name DIST-SWITCHES
vlan 1040
 name INBAND-MGMT
vlan 1041
 name RADIUS-AAA
vlan 1042
 name SYSLOG-MONITORING
vlan 1043
 name NTP-SERVERS
!
! ===== ROUTED UPLINK → FIREWALL1 =====
interface Ethernet0/0
 description TO_FIREWALL1_INSIDE
 no switchport
 ip address 10.100.10.1 255.255.255.252
 no shutdown
!
! ===== ROUTED INTER-CORE LINK → SWL3_2 =====
interface Ethernet0/1
 description TO_SWL3_2_INTER_CORE
 no switchport
 ip address 10.100.30.1 255.255.255.252
 no shutdown
!
! ===== TRUNK → SWL3_4 (Distribution cross-backup) =====
interface Ethernet0/2
 description TO_SWL3_4_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK → SWL3_3 (Distribution primary – Tòa A) =====
interface Ethernet0/3
 description TO_SWL3_3_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – Tòa A Tầng G =====
interface Vlan10
 description A-G-STAFF 10.1.0.0/24
 ip address 10.1.0.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 110
 standby 10 preempt
 standby 10 track 1 decrement 20
 no shutdown
!
interface Vlan11
 description A-G-PATIENT-WIFI 10.1.1.0/23
 ip address 10.1.1.252 255.255.254.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 11 ip 10.1.1.254
 standby 11 priority 110
 standby 11 preempt
 standby 11 track 1 decrement 20
 no shutdown
!
interface Vlan12
 description A-G-DEVICES 10.1.3.0/24
 ip address 10.1.3.252 255.255.255.0
 standby version 2
 standby 12 ip 10.1.3.254
 standby 12 priority 110
 standby 12 preempt
 standby 12 track 1 decrement 20
 no shutdown
!
interface Vlan13
 description A-G-CCTV 10.1.4.0/25
 ip address 10.1.4.124 255.255.255.128
 standby version 2
 standby 13 ip 10.1.4.126
 standby 13 priority 110
 standby 13 preempt
 standby 13 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 1 =====
interface Vlan20
 description A-1-STAFF 10.1.10.0/24
 ip address 10.1.10.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 20 ip 10.1.10.254
 standby 20 priority 110
 standby 20 preempt
 standby 20 track 1 decrement 20
 no shutdown
!
interface Vlan21
 description A-1-PACS-DICOM 10.1.11.0/23
 ip address 10.1.11.252 255.255.254.0
 standby version 2
 standby 21 ip 10.1.11.254
 standby 21 priority 110
 standby 21 preempt
 standby 21 track 1 decrement 20
 no shutdown
!
interface Vlan22
 description A-1-DEVICES 10.1.13.0/24
 ip address 10.1.13.252 255.255.255.0
 standby version 2
 standby 22 ip 10.1.13.254
 standby 22 priority 110
 standby 22 preempt
 standby 22 track 1 decrement 20
 no shutdown
!
interface Vlan23
 description A-1-CCTV 10.1.14.0/25
 ip address 10.1.14.124 255.255.255.128
 standby version 2
 standby 23 ip 10.1.14.126
 standby 23 priority 110
 standby 23 preempt
 standby 23 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 2 =====
interface Vlan30
 description A-2-STAFF 10.1.20.0/24
 ip address 10.1.20.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 30 ip 10.1.20.254
 standby 30 priority 110
 standby 30 preempt
 standby 30 track 1 decrement 20
 no shutdown
!
interface Vlan31
 description A-2-LIS-IOT 10.1.21.0/23
 ip address 10.1.21.252 255.255.254.0
 standby version 2
 standby 31 ip 10.1.21.254
 standby 31 priority 110
 standby 31 preempt
 standby 31 track 1 decrement 20
 no shutdown
!
interface Vlan32
 description A-2-DEVICES 10.1.23.0/24
 ip address 10.1.23.252 255.255.255.0
 standby version 2
 standby 32 ip 10.1.23.254
 standby 32 priority 110
 standby 32 preempt
 standby 32 track 1 decrement 20
 no shutdown
!
interface Vlan33
 description A-2-CCTV 10.1.24.0/25
 ip address 10.1.24.124 255.255.255.128
 standby version 2
 standby 33 ip 10.1.24.126
 standby 33 priority 110
 standby 33 preempt
 standby 33 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 3 (Critical) =====
interface Vlan40
 description A-3-STAFF 10.1.30.0/24
 ip address 10.1.30.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 40 ip 10.1.30.254
 standby 40 priority 110
 standby 40 preempt
 standby 40 track 1 decrement 20
 no shutdown
!
interface Vlan41
 description A-3-CRITICAL-DEVICES 10.1.31.0/23
 ip address 10.1.31.252 255.255.254.0
 standby version 2
 standby 41 ip 10.1.31.254
 standby 41 priority 110
 standby 41 preempt
 standby 41 track 1 decrement 20
 no shutdown
!
interface Vlan42
 description A-3-MONITORING 10.1.33.0/24
 ip address 10.1.33.252 255.255.255.0
 standby version 2
 standby 42 ip 10.1.33.254
 standby 42 priority 110
 standby 42 preempt
 standby 42 track 1 decrement 20
 no shutdown
!
interface Vlan43
 description A-3-CCTV 10.1.34.0/25
 ip address 10.1.34.124 255.255.255.128
 standby version 2
 standby 43 ip 10.1.34.126
 standby 43 priority 110
 standby 43 preempt
 standby 43 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 4 (ICU) =====
interface Vlan50
 description A-4-STAFF 10.1.40.0/24
 ip address 10.1.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 50 ip 10.1.40.254
 standby 50 priority 110
 standby 50 preempt
 standby 50 track 1 decrement 20
 no shutdown
!
interface Vlan51
 description A-4-CRITICAL-DEVICES 10.1.41.0/23
 ip address 10.1.41.252 255.255.254.0
 standby version 2
 standby 51 ip 10.1.41.254
 standby 51 priority 110
 standby 51 preempt
 standby 51 track 1 decrement 20
 no shutdown
!
interface Vlan52
 description A-4-MONITORING 10.1.43.0/24
 ip address 10.1.43.252 255.255.255.0
 standby version 2
 standby 52 ip 10.1.43.254
 standby 52 priority 110
 standby 52 preempt
 standby 52 track 1 decrement 20
 no shutdown
!
interface Vlan53
 description A-4-CCTV 10.1.44.0/25
 ip address 10.1.44.124 255.255.255.128
 standby version 2
 standby 53 ip 10.1.44.126
 standby 53 priority 110
 standby 53 preempt
 standby 53 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 5 =====
interface Vlan60
 description A-5-STAFF 10.1.50.0/24
 ip address 10.1.50.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 60 ip 10.1.50.254
 standby 60 priority 110
 standby 60 preempt
 standby 60 track 1 decrement 20
 no shutdown
!
interface Vlan61
 description A-5-PATIENT-WIFI 10.1.51.0/24
 ip address 10.1.51.252 255.255.255.0
 standby version 2
 standby 61 ip 10.1.51.254
 standby 61 priority 110
 standby 61 preempt
 standby 61 track 1 decrement 20
 no shutdown
!
interface Vlan62
 description A-5-NURSE-CALL 10.1.52.0/24
 ip address 10.1.52.252 255.255.255.0
 standby version 2
 standby 62 ip 10.1.52.254
 standby 62 priority 110
 standby 62 preempt
 standby 62 track 1 decrement 20
 no shutdown
!
interface Vlan63
 description A-5-CCTV 10.1.53.0/25
 ip address 10.1.53.124 255.255.255.128
 standby version 2
 standby 63 ip 10.1.53.126
 standby 63 priority 110
 standby 63 preempt
 standby 63 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 6 =====
interface Vlan70
 description A-6-STAFF 10.1.60.0/24
 ip address 10.1.60.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 70 ip 10.1.60.254
 standby 70 priority 110
 standby 70 preempt
 standby 70 track 1 decrement 20
 no shutdown
!
interface Vlan71
 description A-6-PATIENT-WIFI 10.1.61.0/24
 ip address 10.1.61.252 255.255.255.0
 standby version 2
 standby 71 ip 10.1.61.254
 standby 71 priority 110
 standby 71 preempt
 standby 71 track 1 decrement 20
 no shutdown
!
interface Vlan72
 description A-6-NURSE-CALL 10.1.62.0/24
 ip address 10.1.62.252 255.255.255.0
 standby version 2
 standby 72 ip 10.1.62.254
 standby 72 priority 110
 standby 72 preempt
 standby 72 track 1 decrement 20
 no shutdown
!
interface Vlan73
 description A-6-CCTV 10.1.63.0/25
 ip address 10.1.63.124 255.255.255.128
 standby version 2
 standby 73 ip 10.1.63.126
 standby 73 priority 110
 standby 73 preempt
 standby 73 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa A Tầng 7 (VIP) =====
interface Vlan76
 description A-7-CCTV 10.1.73.0/25
 ip address 10.1.73.124 255.255.255.128
 standby version 2
 standby 76 ip 10.1.73.126
 standby 76 priority 110
 standby 76 preempt
 standby 76 track 1 decrement 20
 no shutdown
!
interface Vlan77
 description A-7-NURSE-CALL 10.1.72.0/24
 ip address 10.1.72.252 255.255.255.0
 standby version 2
 standby 77 ip 10.1.72.254
 standby 77 priority 110
 standby 77 preempt
 standby 77 track 1 decrement 20
 no shutdown
!
interface Vlan78
 description A-7-STAFF 10.1.70.0/24
 ip address 10.1.70.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 78 ip 10.1.70.254
 standby 78 priority 110
 standby 78 preempt
 standby 78 track 1 decrement 20
 no shutdown
!
interface Vlan79
 description A-7-PATIENT-WIFI-VIP 10.1.71.0/24
 ip address 10.1.71.252 255.255.255.0
 standby version 2
 standby 79 ip 10.1.71.254
 standby 79 priority 110
 standby 79 preempt
 standby 79 track 1 decrement 20
 no shutdown
!
! ===== SVI – Tòa E =====
interface Vlan82
 description E-G-EXECUTIVE-STAFF 10.8.40.0/24
 ip address 10.8.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 82 ip 10.8.40.254
 standby 82 priority 110
 standby 82 preempt
 standby 82 track 1 decrement 20
 no shutdown
!
interface Vlan85
 description E-G-CCTV 10.8.50.0/25
 ip address 10.8.50.124 255.255.255.128
 standby version 2
 standby 85 ip 10.8.50.126
 standby 85 priority 110
 standby 85 preempt
 standby 85 track 1 decrement 20
 no shutdown
!
interface Vlan92
 description E-1-FINANCE-STAFF 10.9.40.0/24
 ip address 10.9.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 92 ip 10.9.40.254
 standby 92 priority 110
 standby 92 preempt
 standby 92 track 1 decrement 20
 no shutdown
!
interface Vlan95
 description E-1-CCTV 10.9.50.0/25
 ip address 10.9.50.124 255.255.255.128
 standby version 2
 standby 95 ip 10.9.50.126
 standby 95 priority 110
 standby 95 preempt
 standby 95 track 1 decrement 20
 no shutdown
!
interface Vlan96
 description E-1-ACCESS-SW 10.9.60.0/29
 ip address 10.9.60.5 255.255.255.248
 standby version 2
 standby 96 ip 10.9.60.6
 standby 96 priority 110
 standby 96 preempt
 standby 96 track 1 decrement 20
 no shutdown
!
interface Vlan102
 description E-2-HR-STAFF 10.10.40.0/24
 ip address 10.10.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 102 ip 10.10.40.254
 standby 102 priority 110
 standby 102 preempt
 standby 102 track 1 decrement 20
 no shutdown
!
interface Vlan105
 description E-2-CCTV 10.10.50.0/25
 ip address 10.10.50.124 255.255.255.128
 standby version 2
 standby 105 ip 10.10.50.126
 standby 105 priority 110
 standby 105 preempt
 standby 105 track 1 decrement 20
 no shutdown
!
interface Vlan106
 description E-2-ACCESS-SW 10.10.60.0/29
 ip address 10.10.60.5 255.255.255.248
 standby version 2
 standby 106 ip 10.10.60.6
 standby 106 priority 110
 standby 106 preempt
 standby 106 track 1 decrement 20
 no shutdown
!
interface Vlan112
 description E-3-IT-STAFF 10.11.40.0/24
 ip address 10.11.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 112 ip 10.11.40.254
 standby 112 priority 110
 standby 112 preempt
 standby 112 track 1 decrement 20
 no shutdown
!
interface Vlan113
 description E-3-SERVER-FARM 10.11.50.0/24
 ip address 10.11.50.252 255.255.255.0
 standby version 2
 standby 113 ip 10.11.50.254
 standby 113 priority 110
 standby 113 preempt
 standby 113 track 1 decrement 20
 no shutdown
!
interface Vlan115
 description E-3-CCTV 10.11.60.0/25
 ip address 10.11.60.124 255.255.255.128
 standby version 2
 standby 115 ip 10.11.60.126
 standby 115 priority 110
 standby 115 preempt
 standby 115 track 1 decrement 20
 no shutdown
!
interface Vlan116
 description E-3-ACCESS-SW 10.11.60.0/29
 ip address 10.11.60.5 255.255.255.248
 standby version 2
 standby 116 ip 10.11.60.6
 standby 116 priority 110
 standby 116 preempt
 standby 116 track 1 decrement 20
 no shutdown
!
! ===== SVI – Management =====
interface Vlan999
 description OOB-MANAGEMENT 10.99.99.0/27
 ip address 10.99.99.2 255.255.255.224
 no shutdown
!
interface Vlan1040
 description INBAND-MGMT 10.100.40.0/24
 ip address 10.100.40.252 255.255.255.0
 standby version 2
 standby 1040 ip 10.100.40.254
 standby 1040 priority 110
 standby 1040 preempt
 standby 1040 track 1 decrement 20
 no shutdown
!
interface Vlan1041
 description RADIUS-AAA 10.100.31.0/26
 ip address 10.100.31.62 255.255.255.192
 no shutdown
!
interface Vlan1042
 description SYSLOG-MONITORING 10.100.32.0/26
 ip address 10.100.32.62 255.255.255.192
 no shutdown
!
interface Vlan1043
 description NTP-SERVERS 10.100.33.0/26
 ip address 10.100.33.62 255.255.255.192
 no shutdown
!
! ===== OSPF =====
router ospf 1
 router-id 1.1.1.1
 network 10.1.0.0 0.0.255.255 area 0
 network 10.8.0.0 0.7.255.255 area 0
 network 10.9.0.0 0.0.255.255 area 0
 network 10.10.0.0 0.0.255.255 area 0
 network 10.11.0.0 0.0.255.255 area 0
 network 10.99.99.0 0.0.0.31 area 0
 network 10.100.10.0 0.0.0.3 area 0
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
! ===== DEFAULT ROUTE → Firewall1 =====
ip route 0.0.0.0 0.0.0.0 10.100.10.2
!
! ===== SPANNING TREE – Core ACTIVE (lowest priority = root) =====
spanning-tree vlan 1-4094 priority 4096
!
! ===== MANAGEMENT =====
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