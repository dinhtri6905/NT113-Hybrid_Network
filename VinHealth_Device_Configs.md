# VinHealth – Cấu hình Thiết bị Mạng (Còn lại sau ISP1 & ISP2)

> **Phạm vi tài liệu:** R1, R2, Firewall1, Firewall2, SWL3\_1 (Core ACTIVE), SWL3\_2 (Core STANDBY), SWL3\_3 & SWL3\_4 (Distribution), toàn bộ Access Switch Tòa A & Tòa E, cụm Satellite Clinic (R3+FW3, SWL3\_Clinic, Floor 1-3).
> ISP1 và ISP2 đã cấu hình trước, không lặp lại ở đây.

---

## Quy ước địa chỉ SVI & HSRP

| Vai trò | IP trên /24 | IP trên /23 (block thứ 2) | IP trên /25 | Ghi chú |
|---|---|---|---|---|
| SWL3\_1 (Core ACTIVE) | x.x.x.252 | x.x.x.252 | x.x.x.124 | HSRP priority 110 |
| SWL3\_2 (Core STANDBY) | x.x.x.253 | x.x.x.253 | x.x.x.125 | HSRP priority 100 |
| **HSRP VIP (GW của PC)** | **x.x.x.254** | **x.x.x.254** | **x.x.x.126** | Địa chỉ PC dùng làm gateway |
| SWL3\_3 (Distribution) | x.x.x.250 | x.x.x.250 | x.x.x.122 | Tham gia OSPF |
| SWL3\_4 (Distribution) | x.x.x.251 | x.x.x.251 | x.x.x.123 | Tham gia OSPF |
| Access Switch (mgmt) | x.x.x.254 (ip default-gw) | — | — | L2 only, không SVI |

---

## 1. R1 – Edge Router Primary

**Model:** Cisco ASR 1002-X (IOS XE) | **Kết nối:** ISP1 ← fa0/0, ISP2-cross ← fa1/0, FW1 → fa2/0

```
hostname R1
!
ip cef
!
! ===== INTERFACES =====
interface FastEthernet0/0
 description TO_ISP1_PRIMARY
 ip address 100.100.100.2 255.255.255.252
 no shutdown
!
interface FastEthernet1/0
 description TO_ISP2_CROSS_BACKUP
 ip address 100.100.200.2 255.255.255.252
 no shutdown
!
interface FastEthernet2/0
 description TO_FIREWALL1_INSIDE
 ip address 10.100.0.1 255.255.255.252
 no shutdown
!
! ===== IP SLA – THEO DÕI ISP1 =====
ip sla 1
 icmp-echo 100.100.100.1 source-interface FastEthernet0/0
 threshold 5000
 timeout 5000
 frequency 10
ip sla schedule 1 life forever start-time now
!
track 1 ip sla 1 reachability
!
! ===== STATIC ROUTES =====
! Default qua ISP1 (primary) – theo dõi bằng IP SLA
ip route 0.0.0.0 0.0.0.0 100.100.100.1 10 track 1
! Floating default qua ISP2-cross (backup, AD=20)
ip route 0.0.0.0 0.0.0.0 100.100.200.1 20
! Route về nội bộ qua Firewall1
ip route 10.0.0.0 255.0.0.0 10.100.0.2
!
! ===== LOGGING & MGMT =====
logging buffered 16384 informational
service timestamps log datetime msec localtime
no ip http server
no ip http secure-server
!
line con 0
 logging synchronous
line vty 0 4
 login local
 transport input ssh
!
username admin privilege 15 secret 0 VinHealth@2024
crypto key generate rsa modulus 2048
ip ssh version 2
!
end
```

---

## 2. R2 – Edge Router Backup

**Model:** Cisco ASR 1002-X (IOS XE) | **Kết nối:** ISP2 ← fa0/0, ISP1-cross ← fa1/0, FW2 → fa2/0

```
hostname R2
!
ip cef
!
interface FastEthernet0/0
 description TO_ISP2_PRIMARY
 ip address 100.100.101.2 255.255.255.252
 no shutdown
!
interface FastEthernet1/0
 description TO_ISP1_CROSS_BACKUP
 ip address 100.100.201.2 255.255.255.252
 no shutdown
!
interface FastEthernet2/0
 description TO_FIREWALL2_INSIDE
 ip address 10.100.4.5 255.255.255.252
 no shutdown
!
ip sla 1
 icmp-echo 100.100.101.1 source-interface FastEthernet0/0
 threshold 5000
 timeout 5000
 frequency 10
ip sla schedule 1 life forever start-time now
!
track 1 ip sla 1 reachability
!
ip route 0.0.0.0 0.0.0.0 100.100.101.1 10 track 1
ip route 0.0.0.0 0.0.0.0 100.100.201.1 20
ip route 10.0.0.0 255.0.0.0 10.100.4.6
!
logging buffered 16384 informational
service timestamps log datetime msec localtime
no ip http server
no ip http secure-server
!
line vty 0 4
 login local
 transport input ssh
!
username admin privilege 15 secret 0 VinHealth@2024
crypto key generate rsa modulus 2048
ip ssh version 2
!
end
```

---

## 3. Firewall1 – Primary (Cisco ASA 5516-X)

**Kết nối:** outside G0/1 → R1 (10.100.0.2/30) | inside G0/0 → SWL3\_1 (10.100.10.2/30)

===
enable
configure terminal

hostname Firewall1

ip cef

! ===== INTERFACES =====

! OUTSIDE -> R1
interface FastEthernet2/0
 description OUTSIDE_TO_R1
 ip address 10.100.0.2 255.255.255.252
 ip access-group OUTSIDE_IN in
 no shutdown
 exit

! INSIDE -> Core Switch
interface FastEthernet0/0
 description INSIDE_TO_SWL3_1
 ip address 10.100.10.2 255.255.255.252
 ip access-group INSIDE_IN in
 ip nat inside
 no shutdown
 exit

! Đánh dấu outside NAT
interface FastEthernet2/0
 ip nat outside
 exit

! ===== ROUTING =====

! Default route ra R1
ip route 0.0.0.0 0.0.0.0 10.100.0.1

! Route mạng nội bộ
ip route 10.1.0.0 255.255.0.0 10.100.10.1
ip route 10.2.0.0 255.255.0.0 10.100.10.1
ip route 10.8.0.0 255.248.0.0 10.100.10.1
ip route 10.99.99.0 255.255.255.224 10.100.10.1
ip route 10.100.0.0 255.255.0.0 10.100.10.1
ip route 10.200.0.0 255.255.0.0 10.100.10.1

! ===== ACL =====

ip access-list extended INSIDE_IN
 permit ip 10.0.0.0 0.255.255.255 any
 deny ip any any log
 exit

ip access-list extended OUTSIDE_IN
 permit tcp any 10.200.10.0 0.0.0.255 eq 443
 permit tcp any 10.200.10.0 0.0.0.255 eq 80
 permit icmp any any echo-reply
 deny ip any any log
 exit

! ===== NAT/PAT =====

access-list 1 permit 10.0.0.0 0.255.255.255

ip nat inside source list 1 interface FastEthernet2/0 overload

! ===== SSH =====

aaa new-model
aaa authentication login default local

username admin privilege 15 secret VinHealth@FW1

ip domain-name vinhealth.local

crypto key generate rsa modulus 2048

ip ssh version 2

line vty 0 4
 login authentication default
 transport input ssh
 exit

! ===== LOGGING =====

logging buffered 16384 informational
service timestamps log datetime msec localtime

no ip http server
no ip http secure-server

end
write memory
===
```
! ===== BASIC =====
hostname Firewall1
domain-name vinhealth.local
enable password VinHealth@FW1 encrypted
!
! ===== INTERFACES =====
interface GigabitEthernet0/1
 nameif outside
 security-level 0
 ip address 10.100.0.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet0/0
 nameif inside
 security-level 100
 ip address 10.100.10.2 255.255.255.252
 no shutdown
!
! ===== ROUTING =====
! Default gateway ra ngoài qua R1
route outside 0.0.0.0 0.0.0.0 10.100.0.1 1
! Route về Tòa A qua core switch SWL3_1
route inside 10.1.0.0 255.255.0.0 10.100.10.1 1
! Route về Tòa E
route inside 10.8.0.0 255.248.0.0 10.100.10.1 1
! Route về Infrastructure
route inside 10.100.0.0 255.255.0.0 10.100.10.1 1
! Route về OOB Management
route inside 10.99.99.0 255.255.255.224 10.100.10.1 1
! Route về Phòng khám vệ tinh
route inside 10.2.0.0 255.255.0.0 10.100.10.1 1
! Route về AWS VPC
route inside 10.200.0.0 255.255.0.0 10.100.10.1 1
!
! ===== ACCESS LIST =====
! Cho phép traffic nội bộ qua lại (inter-VLAN routing do core switch xử lý)
access-list INSIDE_IN extended permit ip 10.0.0.0 255.0.0.0 any
access-list INSIDE_IN extended permit ip any 10.0.0.0 255.0.0.0
access-list INSIDE_IN extended deny ip any any log
!
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 443
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 80
access-list OUTSIDE_IN extended permit icmp any any echo-reply
access-list OUTSIDE_IN extended deny ip any any log
!
access-group INSIDE_IN in interface inside
access-group OUTSIDE_IN in interface outside
!
! ===== NAT =====
! Không NAT traffic nội bộ (internal-to-internal)
nat (inside,outside) 1 source static any any destination static any any
! PAT cho traffic ra Internet từ nội bộ
object network INTERNAL_NETWORKS
 subnet 10.0.0.0 255.0.0.0
 nat (inside,outside) dynamic interface
!
! ===== LOGGING =====
logging enable
logging buffered informational
logging host inside 10.100.32.10
!
! ===== MANAGEMENT =====
ssh 10.99.99.0 255.255.255.224 inside
ssh timeout 10
ssh version 2
aaa authentication ssh console LOCAL
username admin password VinHealth@FW1 privilege 15
!
! ===== HIGH AVAILABILITY (HA) – Pair với Firewall2 =====
! Nếu dùng ASA Failover, uncomment và chỉnh IP failover link
! failover
! failover link FAILOVER_LINK GigabitEthernet0/2
! failover interface ip FAILOVER_LINK 10.50.1.1 255.255.255.252 standby 10.50.1.2
! failover group 1
!  primary
!  preempt
!
end
```

---

## 4. Firewall2 – Standby (Cisco ASA 5516-X)

**Kết nối:** outside G0/1 → R2 (10.100.4.6/30) | inside G0/0 → SWL3\_2 (10.100.20.2/30)
===
enable
configure terminal

hostname Firewall2

ip cef

! ===== INTERFACES =====

! OUTSIDE -> R2
interface FastEthernet2/0
 description OUTSIDE_TO_R2
 ip address 10.100.4.6 255.255.255.252
 ip access-group OUTSIDE_IN in
 ip nat outside
 no shutdown
 exit

! INSIDE -> Core SwitchL3_2
interface FastEthernet0/0
 description INSIDE_TO_SWL3_2
 ip address 10.100.20.2 255.255.255.252
 ip access-group INSIDE_IN in
 ip nat inside
 no shutdown
 exit

! ===== ROUTING =====

! Default route ra R2
ip route 0.0.0.0 0.0.0.0 10.100.4.5

! Route nội bộ
ip route 10.1.0.0 255.255.0.0 10.100.20.1
ip route 10.2.0.0 255.255.0.0 10.100.20.1
ip route 10.8.0.0 255.248.0.0 10.100.20.1
ip route 10.99.99.0 255.255.255.224 10.100.20.1
ip route 10.200.0.0 255.255.0.0 10.100.20.1

! ===== ACL =====

ip access-list extended INSIDE_IN
 permit ip 10.0.0.0 0.255.255.255 any
 deny ip any any log
 exit

ip access-list extended OUTSIDE_IN
 permit tcp any 10.200.10.0 0.0.0.255 eq 443
 permit tcp any 10.200.10.0 0.0.0.255 eq 80
 permit icmp any any echo-reply
 deny ip any any log
 exit

! ===== NAT/PAT =====

access-list 1 permit 10.0.0.0 0.255.255.255

ip nat inside source list 1 interface FastEthernet2/0 overload

! ===== SSH =====

aaa new-model
aaa authentication login default local

username admin privilege 15 secret VinHealth@FW2

ip domain-name vinhealth.local

crypto key generate rsa modulus 2048

ip ssh version 2

line vty 0 4
 login authentication default
 transport input ssh
 exit

! ===== LOGGING =====

logging buffered 16384 informational
service timestamps log datetime msec localtime

no ip http server
no ip http secure-server

end
write memory
===
```
hostname Firewall2
domain-name vinhealth.local
enable password VinHealth@FW2 encrypted
!
interface GigabitEthernet0/1
 nameif outside
 security-level 0
 ip address 10.100.4.6 255.255.255.252
 no shutdown
!
interface GigabitEthernet0/0
 nameif inside
 security-level 100
 ip address 10.100.20.2 255.255.255.252
 no shutdown
!
route outside 0.0.0.0 0.0.0.0 10.100.4.5 1
route inside 10.1.0.0 255.255.0.0 10.100.20.1 1
route inside 10.8.0.0 255.248.0.0 10.100.20.1 1
route inside 10.100.0.0 255.255.0.0 10.100.20.1 1
route inside 10.99.99.0 255.255.255.224 10.100.20.1 1
route inside 10.2.0.0 255.255.0.0 10.100.20.1 1
route inside 10.200.0.0 255.255.0.0 10.100.20.1 1
!
access-list INSIDE_IN extended permit ip 10.0.0.0 255.0.0.0 any
access-list INSIDE_IN extended deny ip any any log
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 443
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 80
access-list OUTSIDE_IN extended permit icmp any any echo-reply
access-list OUTSIDE_IN extended deny ip any any log
!
access-group INSIDE_IN in interface inside
access-group OUTSIDE_IN in interface outside
!
object network INTERNAL_NETWORKS
 subnet 10.0.0.0 255.0.0.0
 nat (inside,outside) dynamic interface
!
logging enable
logging host inside 10.100.32.10
!
ssh 10.99.99.0 255.255.255.224 inside
ssh timeout 10
ssh version 2
aaa authentication ssh console LOCAL
username admin password VinHealth@FW2 privilege 15
!
end
```

---

## 5. SWL3\_1 – Core ACTIVE (Cisco Catalyst 9500)

**HSRP Priority 110 | OSPF Router-ID 1.1.1.1 | SVI IP = .252/mask**
Firewall1 ↔ SWL3_1 dùng Fa0/0 ↔ Fa0/0
SWL3_1 ↔ SWL3_2 dùng Fa3/0 ↔ Fa3/0
SWL3_1 ↔ SWL3_3 dùng Fa1/0 ↔ Fa1/0
SWL3_1 ↔ SWL3_4 dùng Fa2/0 (cross)
```
hostname SWL3_1
!
ip routing
spanning-tree mode rapid-pvst
!
! ===== VTP =====
vtp mode server
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== VLAN DATABASE (Tòa A) =====
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
! ===== VLAN DATABASE (Tòa E) =====
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
! ===== VLAN DATABASE (Infrastructure) =====
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
! ===== TO FIREWALL  =====
interface FastEthernet0/0
 description TO_FIREWALL1_INSIDE
 no switchport
 ip address 10.100.10.1 255.255.255.252
 no shutdown
!
! ===== INTER-CORE LINK sang SWL3_2 =====
interface FastEthernet3/0
 description TO_SWL3_2_INTER_CORE
 no switchport
 ip address 10.100.30.1 255.255.255.252
 no shutdown
!
! ===== TRUNK TO SWL3_3 (Distribution – Primary path Tòa A) =====
interface FastEthernet1/0
 description TO_SWL3_3_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK TO SWL3_4 (Distribution – Cross-backup) =====
interface FastEthernet2/0
 description TO_SWL3_4_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – TÒA A (VLAN 10-13 – Tầng G) =====
interface Vlan10
 description A-G-STAFF 10.1.0.0/24
 ip address 10.1.0.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 110
 standby 10 preempt
 standby 10 track FastEthernet0/0 20
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
 standby 11 track FastEthernet0/0 20
 no shutdown
!
interface Vlan12
 description A-G-DEVICES 10.1.3.0/24
 ip address 10.1.3.252 255.255.255.0
 standby version 2
 standby 12 ip 10.1.3.254
 standby 12 priority 110
 standby 12 preempt
 standby 12 track FastEthernet0/0 20
 no shutdown
!
interface Vlan13
 description A-G-CCTV 10.1.4.0/25
 ip address 10.1.4.124 255.255.255.128
 standby version 2
 standby 13 ip 10.1.4.126
 standby 13 priority 110
 standby 13 preempt
 standby 13 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-1 ---
interface Vlan20
 description A-1-STAFF 10.1.10.0/24
 ip address 10.1.10.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 20 ip 10.1.10.254
 standby 20 priority 110
 standby 20 preempt
 standby 20 track FastEthernet0/0 20
 no shutdown
!
interface Vlan21
 description A-1-PACS-DICOM 10.1.11.0/23
 ip address 10.1.11.252 255.255.254.0
 standby version 2
 standby 21 ip 10.1.11.254
 standby 21 priority 110
 standby 21 preempt
 standby 21 track FastEthernet0/0 20
 no shutdown
!
interface Vlan22
 description A-1-DEVICES 10.1.13.0/24
 ip address 10.1.13.252 255.255.255.0
 standby version 2
 standby 22 ip 10.1.13.254
 standby 22 priority 110
 standby 22 preempt
 standby 22 track FastEthernet0/0 20
 no shutdown
!
interface Vlan23
 description A-1-CCTV 10.1.14.0/25
 ip address 10.1.14.124 255.255.255.128
 standby version 2
 standby 23 ip 10.1.14.126
 standby 23 priority 110
 standby 23 preempt
 standby 23 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-2 ---
interface Vlan30
 ip address 10.1.20.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 30 ip 10.1.20.254
 standby 30 priority 110
 standby 30 preempt
 standby 30 track FastEthernet0/0 20
 no shutdown
!
interface Vlan31
 ip address 10.1.21.252 255.255.254.0
 standby version 2
 standby 31 ip 10.1.21.254
 standby 31 priority 110
 standby 31 preempt
 standby 31 track FastEthernet0/0 20
 no shutdown
!
interface Vlan32
 ip address 10.1.23.252 255.255.255.0
 standby version 2
 standby 32 ip 10.1.23.254
 standby 32 priority 110
 standby 32 preempt
 standby 32 track FastEthernet0/0 20
 no shutdown
!
interface Vlan33
 ip address 10.1.24.124 255.255.255.128
 standby version 2
 standby 33 ip 10.1.24.126
 standby 33 priority 110
 standby 33 preempt
 standby 33 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-3 (CRITICAL) ---
interface Vlan40
 ip address 10.1.30.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 40 ip 10.1.30.254
 standby 40 priority 110
 standby 40 preempt
 standby 40 track FastEthernet0/0 20
 no shutdown
!
interface Vlan41
 ip address 10.1.31.252 255.255.254.0
 standby version 2
 standby 41 ip 10.1.31.254
 standby 41 priority 110
 standby 41 preempt
 standby 41 track FastEthernet0/0 20
 no shutdown
!
interface Vlan42
 ip address 10.1.33.252 255.255.255.0
 standby version 2
 standby 42 ip 10.1.33.254
 standby 42 priority 110
 standby 42 preempt
 standby 42 track FastEthernet0/0 20
 no shutdown
!
interface Vlan43
 ip address 10.1.34.124 255.255.255.128
 standby version 2
 standby 43 ip 10.1.34.126
 standby 43 priority 110
 standby 43 preempt
 standby 43 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-4 (ICU) ---
interface Vlan50
 ip address 10.1.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 50 ip 10.1.40.254
 standby 50 priority 110
 standby 50 preempt
 standby 50 track FastEthernet0/0 20
 no shutdown
!
interface Vlan51
 ip address 10.1.41.252 255.255.254.0
 standby version 2
 standby 51 ip 10.1.41.254
 standby 51 priority 110
 standby 51 preempt
 standby 51 track FastEthernet0/0 20
 no shutdown
!
interface Vlan52
 ip address 10.1.43.252 255.255.255.0
 standby version 2
 standby 52 ip 10.1.43.254
 standby 52 priority 110
 standby 52 preempt
 standby 52 track FastEthernet0/0 20
 no shutdown
!
interface Vlan53
 ip address 10.1.44.124 255.255.255.128
 standby version 2
 standby 53 ip 10.1.44.126
 standby 53 priority 110
 standby 53 preempt
 standby 53 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-5 ---
interface Vlan60
 ip address 10.1.50.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 60 ip 10.1.50.254
 standby 60 priority 110
 standby 60 preempt
 standby 60 track FastEthernet0/0 20
 no shutdown
!
interface Vlan61
 ip address 10.1.51.252 255.255.255.0
 standby version 2
 standby 61 ip 10.1.51.254
 standby 61 priority 110
 standby 61 preempt
 standby 61 track FastEthernet0/0 20
 no shutdown
!
interface Vlan62
 ip address 10.1.52.252 255.255.255.0
 standby version 2
 standby 62 ip 10.1.52.254
 standby 62 priority 110
 standby 62 preempt
 standby 62 track FastEthernet0/0 20
 no shutdown
!
interface Vlan63
 ip address 10.1.53.124 255.255.255.128
 standby version 2
 standby 63 ip 10.1.53.126
 standby 63 priority 110
 standby 63 preempt
 standby 63 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-6 ---
interface Vlan70
 ip address 10.1.60.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 70 ip 10.1.60.254
 standby 70 priority 110
 standby 70 preempt
 standby 70 track FastEthernet0/0 20
 no shutdown
!
interface Vlan71
 ip address 10.1.61.252 255.255.255.0
 standby version 2
 standby 71 ip 10.1.61.254
 standby 71 priority 110
 standby 71 preempt
 standby 71 track FastEthernet0/0 20
 no shutdown
!
interface Vlan72
 ip address 10.1.62.252 255.255.255.0
 standby version 2
 standby 72 ip 10.1.62.254
 standby 72 priority 110
 standby 72 preempt
 standby 72 track FastEthernet0/0 20
 no shutdown
!
interface Vlan73
 ip address 10.1.63.124 255.255.255.128
 standby version 2
 standby 73 ip 10.1.63.126
 standby 73 priority 110
 standby 73 preempt
 standby 73 track FastEthernet0/0 20
 no shutdown
!
! --- Tầng A-7 (VIP) ---
interface Vlan76
 ip address 10.1.73.124 255.255.255.128
 standby version 2
 standby 76 ip 10.1.73.126
 standby 76 priority 110
 standby 76 preempt
 standby 76 track FastEthernet0/0 20
 no shutdown
!
interface Vlan77
 ip address 10.1.72.252 255.255.255.0
 standby version 2
 standby 77 ip 10.1.72.254
 standby 77 priority 110
 standby 77 preempt
 standby 77 track FastEthernet0/0 20
 no shutdown
!
interface Vlan78
 ip address 10.1.70.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 78 ip 10.1.70.254
 standby 78 priority 110
 standby 78 preempt
 standby 78 track FastEthernet0/0 20
 no shutdown
!
interface Vlan79
 ip address 10.1.71.252 255.255.255.0
 standby version 2
 standby 79 ip 10.1.71.254
 standby 79 priority 110
 standby 79 preempt
 standby 79 track FastEthernet0/0 20
 no shutdown
!
! ===== SVI – TÒA E =====
interface Vlan82
 description E-G-EXECUTIVE-STAFF 10.8.40.0/24
 ip address 10.8.40.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 82 ip 10.8.40.254
 standby 82 priority 110
 standby 82 preempt
 standby 82 track FastEthernet0/0 20
 no shutdown
!
interface Vlan85
 description E-G-CCTV 10.8.50.0/25
 ip address 10.8.50.124 255.255.255.128
 standby version 2
 standby 85 ip 10.8.50.126
 standby 85 priority 110
 standby 85 preempt
 standby 85 track FastEthernet0/0 20
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
 standby 92 track FastEthernet0/0 20
 no shutdown
!
interface Vlan95
 description E-1-CCTV 10.9.50.0/25
 ip address 10.9.50.124 255.255.255.128
 standby version 2
 standby 95 ip 10.9.50.126
 standby 95 priority 110
 standby 95 preempt
 standby 95 track FastEthernet0/0 20
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
 standby 102 track FastEthernet0/0 20
 no shutdown
!
interface Vlan105
 description E-2-CCTV 10.10.50.0/25
 ip address 10.10.50.124 255.255.255.128
 standby version 2
 standby 105 ip 10.10.50.126
 standby 105 priority 110
 standby 105 preempt
 standby 105 track FastEthernet0/0 20
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
 standby 112 track FastEthernet0/0 20
 no shutdown
!
interface Vlan113
 description E-3-SERVER-FARM 10.11.50.0/24
 ip address 10.11.50.252 255.255.255.0
 standby version 2
 standby 113 ip 10.11.50.254
 standby 113 priority 110
 standby 113 preempt
 standby 113 track FastEthernet0/0 20
 no shutdown
!
interface Vlan115
 description E-3-CCTV 10.11.60.0/25
 ip address 10.11.60.124 255.255.255.128
 standby version 2
 standby 115 ip 10.11.60.126
 standby 115 priority 110
 standby 115 preempt
 standby 115 track FastEthernet0/0 20
 no shutdown
!
! ===== SVI – MANAGEMENT =====
interface Vlan999
 description OOB-MANAGEMENT 10.99.99.0/27
 ip address 10.99.99.2 255.255.255.224
 no shutdown
!
interface Vlan1040
 description INBAND-MGMT
 ip address 10.100.40.252 255.255.255.0
 standby version 2
 standby 1040 ip 10.100.40.254
 standby 1040 priority 110
 standby 1040 preempt
 standby 1040 track FastEthernet0/0 20
 no shutdown
!
interface Vlan1041
 description RADIUS-AAA
 ip address 10.100.31.62 255.255.255.192
 no shutdown
!
interface Vlan1042
 description SYSLOG-MONITORING
 ip address 10.100.32.62 255.255.255.192
 no shutdown
!
interface Vlan1043
 description NTP-SERVERS
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
 no passive-interface FastEthernet0/0
 no passive-interface FastEthernet3/0
!
! ===== DEFAULT ROUTE ra Firewall =====
ip route 0.0.0.0 0.0.0.0 10.100.10.2
!
! ===== SPANNING TREE – CORE ACTIVE =====
spanning-tree vlan 1-4094 priority 4096
!
! ===== MGMT SECURITY =====
username admin privilege 15 secret VinHealth@Core
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
```

---

## 6. SWL3\_2 – Core STANDBY (Cisco Catalyst 9500)

**HSRP Priority 100 | OSPF Router-ID 2.2.2.2 | SVI IP = .253/mask**

> Cấu hình tương tự SWL3\_1 nhưng thay đổi các phần sau:

```
hostname SWL3_2
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== UPLINK KẾT NỐI FIREWALL2 =====
interface GigabitEthernet1/0/1
 description TO_FIREWALL2_INSIDE
 no switchport
 ip address 10.100.20.1 255.255.255.252
 ip ospf 1 area 0
 no shutdown
!
! ===== INTER-CORE LINK sang SWL3_1 =====
interface GigabitEthernet1/0/2
 description TO_SWL3_1_INTER_CORE
 no switchport
 ip address 10.100.30.2 255.255.255.252
 ip ospf 1 area 0
 no shutdown
!
! ===== TRUNK XUỐNG SWL3_4 (Primary path Tòa E) =====
interface GigabitEthernet1/0/3
 description TO_SWL3_4_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK XUỐNG SWL3_3 (Cross-backup) =====
interface GigabitEthernet1/0/4
 description TO_SWL3_3_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – SWL3_2 dùng .253/mask, HSRP priority 100 =====
! (Chỉ ví dụ VLAN 10 – lặp lại mẫu tương tự SWL3_1 cho toàn bộ VLAN)
interface Vlan10
 ip address 10.1.0.253 255.255.255.0
 ip helper-address 10.100.31.10
 ip ospf 1 area 0
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 100
 standby 10 preempt
 standby 10 track GigabitEthernet1/0/1 20
 no shutdown
!
! ... (Lặp lại cho tất cả VLAN, .253 thay cho .252, priority 100)
!
interface Vlan999
 ip address 10.99.99.3 255.255.255.224
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
 network 10.100.0.0 0.0.255.255 area 0
 default-information originate
 passive-interface default
 no passive-interface GigabitEthernet1/0/1
 no passive-interface GigabitEthernet1/0/2
!
ip route 0.0.0.0 0.0.0.0 10.100.20.2
!
! ===== SPANNING TREE – CORE STANDBY =====
spanning-tree vlan 1-4094 priority 8192
!
username admin privilege 15 secret VinHealth@Core
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
```

---

## 7. SWL3\_3 – Distribution (Cisco Catalyst 9300)

**OSPF Router-ID 3.3.3.3 | Primary uplink → SWL3\_1 | Cross-backup → SWL3\_2**

```
hostname SWL3_3
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== UPLINK TRUNK LÊN CORE =====
interface GigabitEthernet1/0/47
 description TO_SWL3_1_PRIMARY_UPLINK
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 100
 no shutdown
!
interface GigabitEthernet1/0/48
 description TO_SWL3_2_CROSS_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 200
 no shutdown
!
! ===== DOWNLINK TRUNK XUỐNG ACCESS SWITCHES – TÒA A =====
interface GigabitEthernet1/0/1
 description TO_A-G-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/2
 description TO_A-1-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/3
 description TO_A-2-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/4
 description TO_A-3-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/5
 description TO_A-4-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/6
 description TO_A-5-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/7
 description TO_A-6-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/8
 description TO_A-7-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree portfast trunk
 no shutdown
!
! ===== DOWNLINK TRUNK XUỐNG ACCESS SWITCHES – TÒA E =====
interface GigabitEthernet1/0/9
 description TO_E-G-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/10
 description TO_E-1-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/11
 description TO_E-2-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet1/0/12
 description TO_E-3-SW-01_ACCESS
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI – DISTRIBUTION (IP .250/mask, chỉ OSPF, không HSRP) =====
interface Vlan10
 ip address 10.1.0.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan20
 ip address 10.1.10.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan30
 ip address 10.1.20.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan40
 ip address 10.1.30.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan50
 ip address 10.1.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan60
 ip address 10.1.50.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan70
 ip address 10.1.60.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan78
 ip address 10.1.70.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan82
 ip address 10.8.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan92
 ip address 10.9.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan102
 ip address 10.10.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan112
 ip address 10.11.40.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan113
 ip address 10.11.50.250 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
interface Vlan999
 ip address 10.99.99.4 255.255.255.224
 no shutdown
!
interface Vlan1040
 description INBAND-MGMT
 ip address 10.100.30.250 255.255.255.0
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
 network 10.100.30.0 0.0.0.255 area 0
 passive-interface default
 no passive-interface GigabitEthernet1/0/47
 no passive-interface GigabitEthernet1/0/48
!
! ===== SPANNING TREE – DISTRIBUTION =====
spanning-tree vlan 10-79 priority 16384
spanning-tree vlan 82-999 priority 24576
!
username admin privilege 15 secret VinHealth@Dist
ip ssh version 2
crypto key generate rsa modulus 2048
!
line vty 0 15
 login local
 transport input ssh
!
logging host 10.100.32.10
ntp server 10.100.33.1
!
end
```

---

## 8. SWL3\_4 – Distribution (Cisco Catalyst 9300)

**OSPF Router-ID 4.4.4.4 | Primary uplink → SWL3\_2 | Cross-backup → SWL3\_1**

> Cấu hình giống SWL3\_3, thay đổi:

```
hostname SWL3_4
!
! SVI dùng .251 thay .250
! router-id 4.4.4.4
! Primary uplink: GigabitEthernet1/0/47 → SWL3_2 (spanning-tree cost 100)
! Cross-backup:  GigabitEthernet1/0/48 → SWL3_1 (spanning-tree cost 200)
! spanning-tree vlan 10-79 priority 20480 (backup cho SWL3_3)
! spanning-tree vlan 82-999 priority 16384 (primary cho Tòa E)
!
router ospf 1
 router-id 4.4.4.4
 network 10.1.0.0 0.0.255.255 area 0
 network 10.8.0.0 0.7.255.255 area 0
 network 10.9.0.0 0.0.255.255 area 0
 network 10.10.0.0 0.0.255.255 area 0
 network 10.11.0.0 0.0.255.255 area 0
 network 10.99.99.0 0.0.0.31 area 0
 network 10.100.30.0 0.0.0.255 area 0
 passive-interface default
 no passive-interface GigabitEthernet1/0/47
 no passive-interface GigabitEthernet1/0/48
!
end
```

---

## 9. Access Switches – Tòa A

> **Tất cả access switch Tòa A:** L2 only (Cisco 9200L PoE+), trunk dual uplink lên SWL3\_3 (primary) và SWL3\_4 (backup).

### 9.1 A-G-SW-01 – Tầng G (Tiếp nhận) — Cấu hình đầy đủ mẫu

```
hostname A-G-SW-01
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== UPLINK TRUNK =====
interface GigabitEthernet0/1
 description UPLINK_TO_SWL3_3_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 description UPLINK_TO_SWL3_4_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree cost 20
 no shutdown
!
! ===== ACCESS PORTS =====
! VLAN 10 – Staff (PC nhân viên)
interface range GigabitEthernet0/3 - 10
 description STAFF_WORKSTATIONS
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 11 – Patient WiFi (AP)
interface range GigabitEthernet0/11 - 14
 description PATIENT_WIFI_APs
 switchport mode access
 switchport access vlan 11
 spanning-tree portfast
 no shutdown
!
! VLAN 12 – Devices (máy in, thiết bị y tế)
interface range GigabitEthernet0/15 - 20
 description MEDICAL_DEVICES
 switchport mode access
 switchport access vlan 12
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 13 – CCTV
interface range GigabitEthernet0/21 - 24
 description CCTV_CAMERAS
 switchport mode access
 switchport access vlan 13
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! ===== MANAGEMENT =====
interface Vlan10
 ip address 10.1.0.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.0.254
!
username admin privilege 15 secret VinHealth@Access
ip ssh version 2
crypto key generate rsa modulus 2048
!
line vty 0 4
 login local
 transport input ssh
!
service timestamps log datetime msec
logging host 10.100.32.10
ntp server 10.100.33.1
!
end
```

### 9.2 A-1-SW-01 – Tầng 1 (Kỹ thuật hình ảnh)

```
hostname A-1-SW-01
! VLAN 20 Staff | 21 PACS-DICOM | 22 Devices | 23 CCTV
!
interface GigabitEthernet0/1
 description UPLINK_TO_SWL3_3_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 description UPLINK_TO_SWL3_4_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 10
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/11 - 16
 description PACS_DICOM_WORKSTATIONS
 switchport mode access
 switchport access vlan 21
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/17 - 20
 switchport mode access
 switchport access vlan 22
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 23
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Vlan20
 ip address 10.1.10.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.10.254
!
username admin privilege 15 secret VinHealth@Access
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
end
```

### 9.3 A-2-SW-01 – Tầng 2 (Xét nghiệm chuyên sâu)

```
hostname A-2-SW-01
! VLAN 30 Staff | 31 LIS-IOT | 32 Devices | 33 CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 10
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/11 - 16
 description LIS_IOT_DEVICES
 switchport mode access
 switchport access vlan 31
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/17 - 20
 switchport mode access
 switchport access vlan 32
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 33
 spanning-tree portfast
 no shutdown
!
interface Vlan30
 ip address 10.1.20.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.20.254
end
```

### 9.4 A-3-SW-01 – Tầng 3 (Phẫu thuật & Hồi sức) — CRITICAL ZONE

```
hostname A-3-SW-01
! VLAN 40 Staff | 41 Critical-Devices | 42 Monitoring | 43 CCTV
! !! CRITICAL ZONE – Không có Guest/Patient-WiFi !!
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 8
 description SURGICAL_STAFF
 switchport mode access
 switchport access vlan 40
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 16
 description CRITICAL_MEDICAL_DEVICES
 switchport mode access
 switchport access vlan 41
 spanning-tree portfast
 spanning-tree bpduguard enable
 storm-control broadcast level 20
 no shutdown
!
interface range GigabitEthernet0/17 - 20
 description PATIENT_MONITORING
 switchport mode access
 switchport access vlan 42
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 43
 spanning-tree portfast
 no shutdown
!
interface Vlan40
 ip address 10.1.30.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.30.254
end
```

### 9.5 A-4-SW-01 – Tầng 4 (ICU chuyên sâu) — CRITICAL ZONE

```
hostname A-4-SW-01
! VLAN 50 Staff | 51 Critical-Devices | 52 Monitoring | 53 CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 8
 switchport mode access
 switchport access vlan 50
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 16
 description ICU_CRITICAL_DEVICES
 switchport mode access
 switchport access vlan 51
 spanning-tree portfast
 spanning-tree bpduguard enable
 storm-control broadcast level 20
 no shutdown
!
interface range GigabitEthernet0/17 - 20
 switchport mode access
 switchport access vlan 52
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 53
 spanning-tree portfast
 no shutdown
!
interface Vlan50
 ip address 10.1.40.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.40.254
end
```

### 9.6 A-5-SW-01 – Tầng 5 (Nội trú A)

```
hostname A-5-SW-01
! VLAN 60 Staff | 61 Patient-WiFi | 62 Nurse-Call | 63 CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 8
 switchport mode access
 switchport access vlan 60
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 14
 description PATIENT_WIFI_APs
 switchport mode access
 switchport access vlan 61
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/15 - 20
 description NURSE_CALL_SYSTEM
 switchport mode access
 switchport access vlan 62
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 63
 spanning-tree portfast
 no shutdown
!
interface Vlan60
 ip address 10.1.50.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.50.254
end
```

### 9.7 A-6-SW-01 – Tầng 6 (Nội trú B)

```
hostname A-6-SW-01
! VLAN 70 Staff | 71 Patient-WiFi | 72 Nurse-Call | 73 CCTV
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 8
 switchport mode access
 switchport access vlan 70
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 14
 switchport mode access
 switchport access vlan 71
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/15 - 20
 switchport mode access
 switchport access vlan 72
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 24
 switchport mode access
 switchport access vlan 73
 spanning-tree portfast
 no shutdown
!
interface Vlan70
 ip address 10.1.60.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.60.254
end
```

### 9.8 A-7-SW-01 – Tầng 7 (Nội trú C + VIP)

```
hostname A-7-SW-01
! VLAN 76 CCTV | 77 Nurse-Call | 78 Staff | 79 Patient-WiFi-VIP
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 8
 description VIP_STAFF
 switchport mode access
 switchport access vlan 78
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/9 - 14
 description VIP_PATIENT_WIFI
 switchport mode access
 switchport access vlan 79
 spanning-tree portfast
 no shutdown
!
interface range GigabitEthernet0/15 - 18
 description NURSE_CALL
 switchport mode access
 switchport access vlan 77
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/19 - 24
 description VIP_CCTV
 switchport mode access
 switchport access vlan 76
 spanning-tree portfast
 no shutdown
!
interface Vlan78
 ip address 10.1.70.254 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.70.254
end
```

---

## 10. Access Switches – Tòa E

### 10.1 E-G-SW-01 – Tầng G (Ban Giám đốc) — Executive Zone

```
hostname E-G-SW-01
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
interface GigabitEthernet0/1
 description UPLINK_TO_SWL3_3_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 description UPLINK_TO_SWL3_4_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree cost 20
 no shutdown
!
! VLAN 82 – Executive Staff
interface range GigabitEthernet0/3 - 16
 description EXECUTIVE_STAFF
 switchport mode access
 switchport access vlan 82
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 85 – CCTV
interface range GigabitEthernet0/17 - 20
 description CCTV_CAMERAS
 switchport mode access
 switchport access vlan 85
 spanning-tree portfast
 no shutdown
!
! VLAN 86 – Management (switch mgmt)
interface GigabitEthernet0/24
 description MGMT_PORT
 switchport mode access
 switchport access vlan 86
 spanning-tree portfast
 no shutdown
!
interface Vlan86
 description SWITCH_MGMT
 ip address 10.8.60.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.8.60.6
!
username admin privilege 15 secret VinHealth@ExecFloor
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
end
```

### 10.2 E-1-SW-01 – Tầng 1 (Kế toán & Tài chính)

```
hostname E-1-SW-01
! VLAN 92 Finance-Staff | 95 CCTV | 96 Switch-Mgmt
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 20
 switchport mode access
 switchport access vlan 92
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 23
 switchport mode access
 switchport access vlan 95
 spanning-tree portfast
 no shutdown
!
interface Vlan96
 ip address 10.9.60.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.9.60.6
end
```

### 10.3 E-2-SW-01 – Tầng 2 (Nhân sự & Hành chính)

```
hostname E-2-SW-01
! VLAN 102 HR-Staff | 105 CCTV | 106 Switch-Mgmt
!
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree cost 20
 no shutdown
!
interface range GigabitEthernet0/3 - 20
 switchport mode access
 switchport access vlan 102
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface range GigabitEthernet0/21 - 23
 switchport mode access
 switchport access vlan 105
 spanning-tree portfast
 no shutdown
!
interface Vlan106
 ip address 10.10.60.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.10.60.6
end
```

### 10.4 E-3-SW-01 – Tầng 3 (Phòng IT & Data Center)

```
hostname E-3-SW-01
! VLAN 112 IT-Staff | 113 Server-Farm | 115 CCTV | 116 Access-SW | 999 OOB-Mgmt
!
interface GigabitEthernet0/1
 description UPLINK_TO_SWL3_3_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree cost 10
 no shutdown
!
interface GigabitEthernet0/2
 description UPLINK_TO_SWL3_4_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree cost 20
 no shutdown
!
! VLAN 112 – IT Staff
interface range GigabitEthernet0/3 - 8
 switchport mode access
 switchport access vlan 112
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 113 – Server Farm (EHR, PACS, RADIUS, Syslog servers)
interface range GigabitEthernet0/9 - 16
 description SERVER_FARM_PORTS
 switchport mode access
 switchport access vlan 113
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 115 – CCTV
interface range GigabitEthernet0/17 - 20
 switchport mode access
 switchport access vlan 115
 spanning-tree portfast
 no shutdown
!
! VLAN 999 – OOB Management (console server)
interface range GigabitEthernet0/21 - 22
 description OOB_CONSOLE_SERVER
 switchport mode access
 switchport access vlan 999
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 116 – Switch Mgmt
interface Vlan116
 ip address 10.11.70.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.11.70.6
!
username admin privilege 15 secret VinHealth@ITFloor
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
end
```

---

## 11. Satellite Clinic

> Cụm Satellite Clinic kết nối về Central Hospital qua **WireGuard VPN tunnel** chạy trên R3+Firewall3 (Linux router).

### 11.1 R3 + Firewall3 – WireGuard Client (Linux)

#### 11.1.1 Cài đặt & sinh key

```bash
# Cài WireGuard (Ubuntu/Debian)
apt-get update && apt-get install -y wireguard

# Sinh key pair cho Satellite Clinic
wg genkey | tee /etc/wireguard/satellite_private.key | wg pubkey > /etc/wireguard/satellite_public.key

chmod 600 /etc/wireguard/satellite_private.key
cat /etc/wireguard/satellite_public.key
# → Gửi public key này cho admin Central Hospital để thêm vào peer config server
```

#### 11.1.2 File cấu hình WireGuard `/etc/wireguard/wg0.conf`

```ini
[Interface]
# IP tunnel phía Satellite Clinic
Address = 10.2.42.2/30
PrivateKey = <satellite_private_key_tại_đây>
ListenPort = 51820
# Kích hoạt IP forwarding để routing
PostUp   = sysctl -w net.ipv4.ip_forward=1 ; iptables -A FORWARD -i wg0 -j ACCEPT ; iptables -A FORWARD -o wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT ; iptables -D FORWARD -o wg0 -j ACCEPT

[Peer]
# Central Hospital WireGuard Server
PublicKey  = <central_hospital_server_public_key>
Endpoint   = <PUBLIC_IP_CENTRAL_HOSPITAL>:51820
# Cho phép traffic về mạng nội bộ Central Hospital
AllowedIPs = 10.1.0.0/16, 10.8.0.0/13, 10.100.0.0/16, 10.99.99.0/27
PersistentKeepalive = 25
```

#### 11.1.3 Kích hoạt WireGuard

```bash
# Enable và start service
systemctl enable wg-quick@wg0
systemctl start  wg-quick@wg0

# Kiểm tra trạng thái tunnel
wg show wg0
```

#### 11.1.4 Định tuyến nội bộ Satellite Clinic

```bash
# Route traffic Clinic (10.2.0.0/16) ra WireGuard tunnel về Central
ip route add 10.1.0.0/16 dev wg0
ip route add 10.8.0.0/13 dev wg0
ip route add 10.100.0.0/16 dev wg0

# Default route ra ISP Clinic (NAT)
ip route add default via <ISP_CLINIC_GATEWAY>

# NAT cho traffic Clinic ra Internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### 11.1.5 Firewall Rules (iptables)

```bash
# Cho phép WireGuard port
iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Cho phép traffic từ Clinic LAN qua WireGuard về Central
iptables -A FORWARD -s 10.2.0.0/16 -d 10.1.0.0/16 -j ACCEPT
iptables -A FORWARD -s 10.2.0.0/16 -d 10.8.0.0/13 -j ACCEPT
iptables -A FORWARD -s 10.1.0.0/8 -d 10.2.0.0/16 -j ACCEPT

# Block traffic từ Patient-WiFi trực tiếp đến mạng nội bộ
iptables -A FORWARD -s 10.2.1.0/24 -d 10.1.0.0/16 -j DROP

# Lưu rules
iptables-save > /etc/iptables/rules.v4
```

---

### 11.2 SWL3\_Clinic – Distribution Switch Satellite (Cisco Catalyst 9300)

```
hostname SWL3_Clinic
!
ip routing
!
! ===== VLAN DATABASE =====
vlan 200
 name SAT-G-RECEPTION
vlan 201
 name SAT-G-EMERGENCY
vlan 202
 name SAT-G-CCTV
vlan 210
 name SAT-1-CLINIC
vlan 211
 name SAT-1-DIAGNOSTIC
vlan 212
 name SAT-1-CCTV
vlan 220
 name SAT-2-SERVER-ROOM
vlan 221
 name SAT-2-FIREWALL-ASA
vlan 222
 name SAT-2-VPN-TUNNEL
vlan 223
 name SAT-2-CCTV
!
! ===== UPLINK KẾT NỐI R3/Firewall3 (Linux Router) =====
interface GigabitEthernet0/1
 description TO_R3_FIREWALL3_WIREGUARD
 no switchport
 ip address 10.2.41.2 255.255.255.248
 ip ospf 1 area 1
 no shutdown
!
! ===== DOWNLINK TRUNK XUỐNG FLOOR SWITCHES =====
interface GigabitEthernet0/2
 description TO_FLOOR1_SAT-G-SW-01
 switchport mode trunk
 switchport trunk allowed vlan 200,201,202
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet0/3
 description TO_FLOOR2_SAT-1-SW-01
 switchport mode trunk
 switchport trunk allowed vlan 210,211,212
 spanning-tree portfast trunk
 no shutdown
!
interface GigabitEthernet0/4
 description TO_FLOOR3_MDF
 switchport mode trunk
 switchport trunk allowed vlan 220,221,222,223
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI =====
interface Vlan200
 description SAT-G-RECEPTION 10.2.0.0/24
 ip address 10.2.0.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 200 ip 10.2.0.254
 standby 200 priority 110
 standby 200 preempt
 no shutdown
!
interface Vlan201
 description SAT-G-EMERGENCY 10.2.1.0/24
 ip address 10.2.1.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 201 ip 10.2.1.254
 standby 201 priority 110
 standby 201 preempt
 no shutdown
!
interface Vlan202
 description SAT-G-CCTV 10.2.2.0/25
 ip address 10.2.2.124 255.255.255.128
 no shutdown
!
interface Vlan210
 description SAT-1-CLINIC 10.2.20.0/24
 ip address 10.2.20.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 210 ip 10.2.20.254
 standby 210 priority 110
 standby 210 preempt
 no shutdown
!
interface Vlan211
 description SAT-1-DIAGNOSTIC 10.2.21.0/24
 ip address 10.2.21.252 255.255.255.0
 standby version 2
 standby 211 ip 10.2.21.254
 standby 211 priority 110
 standby 211 preempt
 no shutdown
!
interface Vlan212
 description SAT-1-CCTV 10.2.22.0/25
 ip address 10.2.22.124 255.255.255.128
 no shutdown
!
interface Vlan220
 description SAT-2-SERVER-ROOM 10.2.40.0/25
 ip address 10.2.40.124 255.255.255.128
 no shutdown
!
interface Vlan221
 description SAT-2-FIREWALL-ASA 10.2.41.0/29
 ip address 10.2.41.1 255.255.255.248
 no shutdown
!
interface Vlan223
 description SAT-2-CCTV 10.2.43.0/25
 ip address 10.2.43.124 255.255.255.128
 no shutdown
!
! ===== ROUTING =====
! Static route về Central Hospital qua WireGuard tunnel (R3)
ip route 10.1.0.0 255.255.0.0 10.2.41.2
ip route 10.8.0.0 255.248.0.0 10.2.41.2
ip route 10.100.0.0 255.255.0.0 10.2.41.2
! Default ra Internet qua R3
ip route 0.0.0.0 0.0.0.0 10.2.41.2
!
! ===== OSPF (chỉ nội bộ Clinic) =====
router ospf 1
 router-id 10.10.10.1
 network 10.2.0.0 0.0.255.255 area 1
 passive-interface default
 no passive-interface GigabitEthernet0/1
!
username admin privilege 15 secret VinHealth@Clinic
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 4
 login local
 transport input ssh
!
ntp server 10.100.33.1
logging host 10.100.32.10
end
```

---

### 11.3 SAT-G-SW-01 – Floor 1 Clinic (Tầng G – Tiếp nhận & Cấp cứu)

```
hostname SAT-G-SW-01
!
! ===== VLAN =====
vlan 200
 name SAT-G-RECEPTION
vlan 201
 name SAT-G-EMERGENCY
vlan 202
 name SAT-G-CCTV
!
! ===== UPLINK TRUNK LÊN SWL3_Clinic =====
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 200,201,202
 no shutdown
!
! VLAN 200 – Reception (PC tiếp nhận)
interface range GigabitEthernet0/2 - 12
 description RECEPTION_STAFF
 switchport mode access
 switchport access vlan 200
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 201 – Emergency (thiết bị cấp cứu)
interface range GigabitEthernet0/13 - 18
 description EMERGENCY_DEVICES
 switchport mode access
 switchport access vlan 201
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
! VLAN 202 – CCTV
interface range GigabitEthernet0/19 - 24
 switchport mode access
 switchport access vlan 202
 spanning-tree portfast
 no shutdown
!
interface Vlan200
 ip address 10.2.0.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.2.0.254
end
```

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
```

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
```

---

## 12. WireGuard Server – Central Hospital (cấu hình thêm vào server tại Data Center)

> Phần này cấu hình **phía server** tại Central Hospital để nhận kết nối từ Satellite Clinic.

```ini
# /etc/wireguard/wg0.conf tại Central Hospital (server)
[Interface]
Address    = 10.2.42.1/30
PrivateKey = <central_hospital_server_private_key>
ListenPort = 51820
PostUp     = sysctl -w net.ipv4.ip_forward=1
PostUp     = iptables -A FORWARD -i wg0 -j ACCEPT ; iptables -A FORWARD -o wg0 -j ACCEPT
PostDown   = iptables -D FORWARD -i wg0 -j ACCEPT ; iptables -D FORWARD -o wg0 -j ACCEPT

[Peer]
# Satellite Clinic
PublicKey  = <satellite_clinic_public_key>
AllowedIPs = 10.2.0.0/16, 10.2.42.2/32
PersistentKeepalive = 25
```

```bash
# Thêm route trên core router/firewall về Clinic qua WireGuard
ip route add 10.2.0.0/16 dev wg0

# Enable service
systemctl enable wg-quick@wg0
systemctl start  wg-quick@wg0
```

---

## Phụ lục – Bảng tóm tắt IP quan trọng

| Thiết bị | Interface | IP | Vai trò |
|---|---|---|---|
| R1 | fa0/0 | 100.100.100.2/30 | ISP1 (primary) |
| R1 | fa2/0 | 10.100.0.1/30 | → FW1 outside |
| R2 | fa0/0 | 100.100.101.2/30 | ISP2 (backup) |
| R2 | fa2/0 | 10.100.4.5/30 | → FW2 outside |
| FW1 | outside | 10.100.0.2/30 | ← R1 |
| FW1 | inside | 10.100.10.2/30 | → SWL3\_1 |
| FW2 | outside | 10.100.4.6/30 | ← R2 |
| FW2 | inside | 10.100.20.2/30 | → SWL3\_2 |
| SWL3\_1 | Gi1/0/1 | 10.100.10.1/30 | ← FW1 |
| SWL3\_1 | Gi1/0/2 | 10.100.30.1/30 | ↔ SWL3\_2 inter-core |
| SWL3\_2 | Gi1/0/1 | 10.100.20.1/30 | ← FW2 |
| SWL3\_2 | Gi1/0/2 | 10.100.30.2/30 | ↔ SWL3\_1 inter-core |
| SWL3\_Clinic | Gi0/1 | 10.2.41.2/29 | ← R3/FW3 |
| R3/FW3 (wg0) | tunnel | 10.2.42.2/30 | WireGuard Clinic end |
| WG Server | wg0 | 10.2.42.1/30 | WireGuard Central end |
| RADIUS-SRV-01 | — | 10.100.31.10 | RADIUS/AAA |
| SYSLOG-SRV-01 | — | 10.100.32.10 | Syslog SIEM |
| MONITOR-SRV-01 | — | 10.100.32.11 | Prometheus/Grafana |
| NTP Server | — | 10.100.33.1 | NTP |

---

*Tài liệu: VinHealth Network Configuration v1.0 – Bệnh viện VinHealth Hybrid Cloud Infrastructure*
