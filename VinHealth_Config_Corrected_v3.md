# VinHealth – Kiểm tra & Sửa lỗi Cấu hình Mạng (v3)

> **Phương pháp:** So sánh sơ đồ Packet Tracer (ảnh topology) với file `VinHealth_Complete_v2.md`  
> **Chuẩn đặt tên cổng theo sơ đồ:** Ethernet**X/Y** (e.g. `Ethernet0/0`, `Ethernet1/0`)

---

## ⚠️ TỔNG HỢP LỖI TÌM THẤY

| # | Thiết bị | Loại lỗi | Mô tả |
|---|---------|----------|-------|
| 1 | **SWL3_1** | Tên cổng sai | Dùng `FastEthernet0/0`, `Fa1/0`, `Fa2/0`, `Fa3/0` – sơ đồ hiển thị `Ethernet0/0`–`0/5` |
| 2 | **SWL3_2** | Tên cổng sai | Dùng `GigabitEthernet1/0/1`–`1/0/4` – không khớp sơ đồ lẫn SWL3_1 |
| 3 | **SWL3_2** | HSRP track sai | `track GigabitEthernet1/0/1` phải là uplink `Ethernet0/0` (lên FW2) |
| 4 | **SWL3_3** | Tên cổng sai | Uplink dùng `GigabitEthernet1/0/47`–`48`; downlink `Gi1/0/1`–`12` – sơ đồ dùng `Ethernet0/x` và `Ethernet2/x` |
| 5 | **SWL3_4** | Tên cổng sai | Tương tự SWL3_3; uplink và downlink không khớp sơ đồ |
| 6 | **SWL3_Clinic** | Tên cổng sai | `GigabitEthernet0/1`–`0/4` – sơ đồ dùng `Ethernet0/0`, `Ethernet3/0`–`3/2` |
| 7 | **SWL3_Clinic** | Routing loop | Static route `ip route ... 10.2.41.2` trỏ về chính IP của interface mình |
| 8 | **SWL3_Clinic** | OSPF area sai | Khai báo `area 1` trong khi toàn bộ Central Hospital dùng `area 0` |
| 9 | **Section 9.x (Tòa A)** | Tên cổng sai | Access switches dùng `GigabitEthernet0/1`–`0/2` (uplink) và `Gi0/3`–`Gi0/24` (access) – sơ đồ dùng `Ethernet1/0`–`1/1` và `Ethernet0/x` |
| 10 | **Satellite Floor switches (Section 11)** | Tên cổng sai | `GigabitEthernet0/1` uplink – sơ đồ dùng `Ethernet1/0` |
| 11 | **Cấu hình trùng lặp** | Cấu trúc | Tòa A có 2 phiên bản cấu hình (Section 9.x = GigabitEthernet style; TOAA_Floorx = Ethernet style). Giữ bản Ethernet (TOAA/TOAE) là đúng; xóa Section 9.x |
| 12 | **SWL3_Clinic OSPF** | Thiếu ABR | area 1 ↔ area 0 cần ABR hoặc redistribute – hiện không có |
| 13 | **SWL3_Clinic IP** | IP conflict | `GigabitEthernet0/1` IP=`10.2.41.2/29` trùng subnet với `Vlan221` IP=`10.2.41.1/29` |

---

## BẢNG ĐỐI CHIẾU CỔNG (SƠ ĐỒ → CONFIG CŨ → CONFIG MỚI)

### SWL3_1 (Core ACTIVE)

| Kết nối | Sơ đồ (đầu SWL3_1) | Config cũ | Config mới (đúng) |
|---------|-------------------|-----------|------------------|
| → FW1 inside | `Ethernet0/0` | `FastEthernet0/0` | `Ethernet0/0` |
| ↔ SWL3_2 inter-core | `Ethernet0/1` | `FastEthernet3/0` | `Ethernet0/1` |
| → SWL3_3 (primary) | `Ethernet0/2` | `FastEthernet1/0` | `Ethernet0/2` |
| → SWL3_4 (cross) | `Ethernet0/5` | `FastEthernet2/0` | `Ethernet0/5` |

### SWL3_2 (Core STANDBY)

| Kết nối | Sơ đồ (đầu SWL3_2) | Config cũ | Config mới (đúng) |
|---------|-------------------|-----------|------------------|
| → FW2 inside | `Ethernet0/0` | `GigabitEthernet1/0/1` | `Ethernet0/0` |
| ↔ SWL3_1 inter-core | `Ethernet0/1` | `GigabitEthernet1/0/2` | `Ethernet0/1` |
| → SWL3_4 (primary) | `Ethernet0/2` | `GigabitEthernet1/0/3` | `Ethernet0/2` |
| → SWL3_3 (cross) | `Ethernet0/5` | `GigabitEthernet1/0/4` | `Ethernet0/5` |

### SWL3_3 (Distribution)

| Kết nối | Sơ đồ | Config cũ | Config mới |
|---------|-------|-----------|-----------|
| Uplink → SWL3_1 (primary) | `Ethernet0/2` | `GigabitEthernet1/0/47` | `Ethernet0/2` |
| Uplink → SWL3_2 (cross) | `Ethernet0/0` | `GigabitEthernet1/0/48` | `Ethernet0/0` |
| Downlink A-G (Floor 1) | `Ethernet2/0` | `GigabitEthernet1/0/1` | `Ethernet2/0` |
| Downlink A-1 (Floor 2) | `Ethernet2/1` | `GigabitEthernet1/0/2` | `Ethernet2/1` |
| Downlink A-2 (Floor 3) | `Ethernet2/2` | `GigabitEthernet1/0/3` | `Ethernet2/2` |
| Downlink A-3 (Floor 4) | `Ethernet2/3` | `GigabitEthernet1/0/4` | `Ethernet2/3` |
| Downlink A-4 (Floor 5) | `Ethernet2/4` | `GigabitEthernet1/0/5` | `Ethernet2/4` |
| Downlink A-5 (Floor 6) | `Ethernet2/5` | `GigabitEthernet1/0/6` | `Ethernet2/5` |
| Downlink A-6 (Floor 7) | `Ethernet2/6` | `GigabitEthernet1/0/7` | `Ethernet2/6` |
| Downlink A-7 (Floor 8) | `Ethernet2/7` | `GigabitEthernet1/0/8` | `Ethernet2/7` |
| Downlink E-G | `Ethernet3/0` | `GigabitEthernet1/0/9` | `Ethernet3/0` |
| Downlink E-1 | `Ethernet3/1` | `GigabitEthernet1/0/10` | `Ethernet3/1` |
| Downlink E-2 | `Ethernet3/2` | `GigabitEthernet1/0/11` | `Ethernet3/2` |
| Downlink E-3 | `Ethernet3/3` | `GigabitEthernet1/0/12` | `Ethernet3/3` |

### SWL3_4 (Distribution)

| Kết nối | Sơ đồ | Config mới |
|---------|-------|-----------|
| Uplink → SWL3_2 (primary) | `Ethernet0/2` | `Ethernet0/2` |
| Uplink → SWL3_1 (cross) | `Ethernet0/0` | `Ethernet0/0` |
| Downlinks Tòa A (Floor 1–8) | `Ethernet2/0`–`2/7` | `Ethernet2/0`–`2/7` |
| Downlinks Tòa E (Floor G–3) | `Ethernet3/0`–`3/3` | `Ethernet3/0`–`3/3` |

### SWL3_Clinic

| Kết nối | Sơ đồ | Config cũ | Config mới |
|---------|-------|-----------|-----------|
| → R3/FW3 Linux | `Ethernet0/0` | `GigabitEthernet0/1` | `Ethernet0/0` |
| → SAT_FloorG (Floor 1) | `Ethernet3/2` | `GigabitEthernet0/2` | `Ethernet3/2` |
| → SAT_Floor1 (Floor 2) | `Ethernet3/1` | `GigabitEthernet0/3` | `Ethernet3/1` |
| → SAT_Floor2 (Floor 3) | `Ethernet3/0` | `GigabitEthernet0/4` | `Ethernet3/0` |

### Access Switches – Uplinks (tất cả Tòa A, Tòa E, Satellite)

| | Sơ đồ | Config cũ (Sec 9.x) | Config mới |
|--|-------|---------------------|-----------|
| Uplink PRIMARY | `Ethernet1/0` | `GigabitEthernet0/1` | `Ethernet1/0` ✓ (đã đúng trong TOAA/TOAE) |
| Uplink BACKUP | `Ethernet1/1` | `GigabitEthernet0/2` | `Ethernet1/1` ✓ |
| Access ports | `Ethernet0/0`–`0/3` | `GigabitEthernet0/3`–`0/24` | `Ethernet0/0`–`0/3` ✓ |

---

## CẤU HÌNH ĐÃ SỬA

---

### 1. R1 – Edge Router Primary ✅ (Không thay đổi – Đúng)

```
hostname R1
ip cef
!
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
 description TO_FIREWALL1_OUTSIDE
 ip address 10.100.0.1 255.255.255.252
 no shutdown
!
ip sla 1
 icmp-echo 100.100.100.1 source-interface FastEthernet0/0
 threshold 5000
 timeout 5000
 frequency 10
ip sla schedule 1 life forever start-time now
!
track 1 ip sla 1 reachability
!
ip route 0.0.0.0 0.0.0.0 100.100.100.1 10 track 1
ip route 0.0.0.0 0.0.0.0 100.100.200.1 20
ip route 10.0.0.0 255.0.0.0 10.100.0.2
!
username admin privilege 15 secret 0 VinHealth@2024
crypto key generate rsa modulus 2048
ip ssh version 2
!
line con 0
 logging synchronous
line vty 0 4
 login local
 transport input ssh
end
```

---

### 2. R2 – Edge Router Backup ✅ (Không thay đổi – Đúng)

```
hostname R2
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
 description TO_FIREWALL2_OUTSIDE
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
username admin privilege 15 secret 0 VinHealth@2024
crypto key generate rsa modulus 2048
ip ssh version 2
!
line vty 0 4
 login local
 transport input ssh
end
```

---

### 3. Firewall1 – Primary (Cisco ASA 5516-X) ✅ (Không thay đổi – Đúng)

> Kết nối: `GigabitEthernet0/1` (outside) → R1 `fa2/0` | `GigabitEthernet0/0` (inside) → SWL3_1 `Ethernet0/0`

```
hostname Firewall1
domain-name vinhealth.local
enable password VinHealth@FW1 encrypted
!
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
route outside 0.0.0.0 0.0.0.0 10.100.0.1 1
route inside 10.1.0.0 255.255.0.0 10.100.10.1 1
route inside 10.8.0.0 255.248.0.0 10.100.10.1 1
route inside 10.100.0.0 255.255.0.0 10.100.10.1 1
route inside 10.99.99.0 255.255.255.224 10.100.10.1 1
route inside 10.2.0.0 255.255.0.0 10.100.10.1 1
route inside 10.200.0.0 255.255.0.0 10.100.10.1 1
!
access-list INSIDE_IN extended permit ip 10.0.0.0 255.0.0.0 any
access-list INSIDE_IN extended permit ip any 10.0.0.0 255.0.0.0
access-list INSIDE_IN extended deny ip any any log
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 443
access-list OUTSIDE_IN extended permit tcp any 10.200.10.0 255.255.255.0 eq 80
access-list OUTSIDE_IN extended permit icmp any any echo-reply
access-list OUTSIDE_IN extended deny ip any any log
!
access-group INSIDE_IN in interface inside
access-group OUTSIDE_IN in interface outside
!
nat (inside,outside) 1 source static any any destination static any any
object network INTERNAL_NETWORKS
 subnet 10.0.0.0 255.0.0.0
 nat (inside,outside) dynamic interface
!
logging enable
logging buffered informational
logging host inside 10.100.32.10
ssh 10.99.99.0 255.255.255.224 inside
ssh timeout 10
ssh version 2
aaa authentication ssh console LOCAL
username admin password VinHealth@FW1 privilege 15
!
end
```

---

### 4. Firewall2 – Standby (Cisco ASA 5516-X) ✅ (Không thay đổi – Đúng)

> Kết nối: `GigabitEthernet0/1` (outside) → R2 `fa2/0` | `GigabitEthernet0/0` (inside) → SWL3_2 `Ethernet0/0`

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
ssh 10.99.99.0 255.255.255.224 inside
ssh timeout 10
ssh version 2
aaa authentication ssh console LOCAL
username admin password VinHealth@FW2 privilege 15
!
end
```

---

### 5. SWL3_1 – Core ACTIVE 🔧 (ĐÃ SỬA CỔNG)

> **Sửa:** `FastEthernet0/0→Eth0/0`, `Fa3/0→Eth0/1`, `Fa1/0→Eth0/2`, `Fa2/0→Eth0/5`  
> **Kết nối:** `Eth0/0`↔FW1 Gi0/0 | `Eth0/1`↔SWL3_2 Eth0/1 | `Eth0/2`↔SWL3_3 Eth0/2 | `Eth0/5`↔SWL3_4 Eth0/0

```
hostname SWL3_1
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode server
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== VLAN DATABASE =====
! (Giữ nguyên toàn bộ VLAN 10-1043 như file gốc)
!
! ===== TO FIREWALL1 (routed port) =====
! [SỬA] FastEthernet0/0 → Ethernet0/0
interface Ethernet0/0
 description TO_FIREWALL1_INSIDE
 no switchport
 ip address 10.100.10.1 255.255.255.252
 no shutdown
!
! ===== INTER-CORE LINK → SWL3_2 =====
! [SỬA] FastEthernet3/0 → Ethernet0/1
interface Ethernet0/1
 description TO_SWL3_2_INTER_CORE
 no switchport
 ip address 10.100.30.1 255.255.255.252
 no shutdown
!
! ===== TRUNK → SWL3_3 (Distribution – Primary path Tòa A) =====
! [SỬA] FastEthernet1/0 → Ethernet0/2
interface Ethernet0/2
 description TO_SWL3_3_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK → SWL3_4 (Distribution – Cross-backup) =====
! [SỬA] FastEthernet2/0 → Ethernet0/5
interface Ethernet0/5
 description TO_SWL3_4_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – TÒA A (Giữ nguyên toàn bộ Vlan10–Vlan1043) =====
! [SỬA] Tất cả `standby X track FastEthernet0/0` → `standby X track Ethernet0/0`
interface Vlan10
 description A-G-STAFF 10.1.0.0/24
 ip address 10.1.0.252 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 110
 standby 10 preempt
 standby 10 track Ethernet0/0 20
 no shutdown
!
! ... (lặp lại mẫu cho tất cả SVI, thay FastEthernet0/0 → Ethernet0/0 trong track)
!
interface Vlan1040
 description INBAND-MGMT
 ip address 10.100.40.252 255.255.255.0
 standby version 2
 standby 1040 ip 10.100.40.254
 standby 1040 priority 110
 standby 1040 preempt
 standby 1040 track Ethernet0/0 20
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
 ! [SỬA] passive-interface FastEthernet0/0 → Ethernet0/0
 passive-interface Ethernet0/0
!
ip route 0.0.0.0 0.0.0.0 10.100.10.2
!
spanning-tree vlan 1-4094 priority 4096
!
username admin privilege 15 secret VinHealth@Core
ip ssh version 2
crypto key generate rsa modulus 2048
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

### 6. SWL3_2 – Core STANDBY 🔧 (ĐÃ SỬA CỔNG + TRACK)

> **Sửa:** Toàn bộ `GigabitEthernet1/0/x` → `Ethernet0/x`  
> **Kết nối:** `Eth0/0`↔FW2 Gi0/0 | `Eth0/1`↔SWL3_1 Eth0/1 | `Eth0/2`↔SWL3_4 Eth0/2 | `Eth0/5`↔SWL3_3 Eth0/0

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
! [SỬA] GigabitEthernet1/0/1 → Ethernet0/0
interface Ethernet0/0
 description TO_FIREWALL2_INSIDE
 no switchport
 ip address 10.100.20.1 255.255.255.252
 no shutdown
!
! ===== INTER-CORE LINK → SWL3_1 =====
! [SỬA] GigabitEthernet1/0/2 → Ethernet0/1
interface Ethernet0/1
 description TO_SWL3_1_INTER_CORE
 no switchport
 ip address 10.100.30.2 255.255.255.252
 no shutdown
!
! ===== TRUNK → SWL3_4 (Primary path Tòa E) =====
! [SỬA] GigabitEthernet1/0/3 → Ethernet0/2
interface Ethernet0/2
 description TO_SWL3_4_DIST_PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== TRUNK → SWL3_3 (Cross-backup) =====
! [SỬA] GigabitEthernet1/0/4 → Ethernet0/5
interface Ethernet0/5
 description TO_SWL3_3_DIST_CROSS
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 no shutdown
!
! ===== SVI – SWL3_2 (.253/mask, HSRP priority 100) =====
! [SỬA] track GigabitEthernet1/0/1 → track Ethernet0/0
interface Vlan10
 ip address 10.1.0.253 255.255.255.0
 ip helper-address 10.100.31.10
 standby version 2
 standby 10 ip 10.1.0.254
 standby 10 priority 100
 standby 10 preempt
 standby 10 track Ethernet0/0 20
 no shutdown
!
! ... (lặp lại cho tất cả VLAN, .253 thay .252, priority 100, track Ethernet0/0)
!
interface Vlan999
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
 standby 1040 track Ethernet0/0 20
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
 network 10.100.40.0 0.0.0.255 area 0
 default-information originate
 ! [SỬA] passive-interface GigabitEthernet1/0/1 → Ethernet0/0
 passive-interface Ethernet0/0
 ! Ethernet0/1 (inter-core) cần active để form adjacency
!
ip route 0.0.0.0 0.0.0.0 10.100.20.2
!
spanning-tree vlan 1-4094 priority 8192
!
username admin privilege 15 secret VinHealth@Core
ip ssh version 2
crypto key generate rsa modulus 2048
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

### 7. SWL3_3 – Distribution 🔧 (ĐÃ SỬA CỔNG)

> **Kết nối:** `Eth0/2`↑SWL3_1 (primary) | `Eth0/0`↑SWL3_2 (cross)  
> Downlinks Tòa A: `Eth2/0`–`2/7` | Downlinks Tòa E: `Eth3/0`–`3/3`

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
! [SỬA] GigabitEthernet1/0/47 → Ethernet0/2
interface Ethernet0/2
 description TO_SWL3_1_PRIMARY_UPLINK
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 100
 no shutdown
!
! [SỬA] GigabitEthernet1/0/48 → Ethernet0/0
interface Ethernet0/0
 description TO_SWL3_2_CROSS_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 200
 no shutdown
!
! ===== DOWNLINK TRUNK – TÒA A =====
! [SỬA] GigabitEthernet1/0/1 → Ethernet2/0
interface Ethernet2/0
 description TO_TOAA_Floor1_ACCESS [A-G]
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/1
 description TO_TOAA_Floor2_ACCESS [A-1]
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/2
 description TO_TOAA_Floor3_ACCESS [A-2]
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/3
 description TO_TOAA_Floor4_ACCESS [A-3 CRITICAL]
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/4
 description TO_TOAA_Floor5_ACCESS [A-4 ICU]
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/5
 description TO_TOAA_Floor6_ACCESS [A-5]
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/6
 description TO_TOAA_Floor7_ACCESS [A-6]
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/7
 description TO_TOAA_Floor8_ACCESS [A-7 VIP]
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree portfast trunk
 no shutdown
!
! ===== DOWNLINK TRUNK – TÒA E =====
! [SỬA] GigabitEthernet1/0/9 → Ethernet3/0
interface Ethernet3/0
 description TO_TOAE_Floor1_ACCESS [E-G]
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/1
 description TO_TOAE_Floor2_ACCESS [E-1]
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/2
 description TO_TOAE_Floor3_ACCESS [E-2]
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/3
 description TO_TOAE_Floor4_ACCESS [E-3]
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI – DISTRIBUTION (.250/mask) =====
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
! ... (giữ nguyên toàn bộ SVI như file gốc – địa chỉ IP đúng)
!
interface Vlan999
 ip address 10.99.99.4 255.255.255.224
 no shutdown
!
interface Vlan1040
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
!
spanning-tree vlan 10-79 priority 16384
spanning-tree vlan 82-999 priority 24576
!
username admin privilege 15 secret VinHealth@Dist
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 15
 login local
 transport input ssh
!
logging host 10.100.32.10
ntp server 10.100.33.1
end
```

---

### 8. SWL3_4 – Distribution 🔧 (ĐÃ SỬA CỔNG)

> **Kết nối:** `Eth0/2`↑SWL3_2 (primary) | `Eth0/0`↑SWL3_1 (cross)

```
hostname SWL3_4
!
ip routing
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
! ===== UPLINK =====
interface Ethernet0/2
 description TO_SWL3_2_PRIMARY_UPLINK
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 100
 no shutdown
!
interface Ethernet0/0
 description TO_SWL3_1_CROSS_BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10-13,20-23,30-33,40-43,50-53,60-63,70-73,76-79
 switchport trunk allowed vlan add 82,85,86,92,95,96,102,105,106,112,113,115,116,999
 switchport trunk allowed vlan add 1000,1010,1040-1043
 spanning-tree cost 200
 no shutdown
!
! ===== DOWNLINK TÒA A =====
interface Ethernet2/0
 description TO_TOAA_Floor1_ACCESS [A-G] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/1
 description TO_TOAA_Floor2_ACCESS [A-1] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 20,21,22,23
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/2
 description TO_TOAA_Floor3_ACCESS [A-2] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/3
 description TO_TOAA_Floor4_ACCESS [A-3] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/4
 description TO_TOAA_Floor5_ACCESS [A-4] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/5
 description TO_TOAA_Floor6_ACCESS [A-5] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/6
 description TO_TOAA_Floor7_ACCESS [A-6] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/7
 description TO_TOAA_Floor8_ACCESS [A-7] BACKUP
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree portfast trunk
 no shutdown
!
! ===== DOWNLINK TÒA E =====
interface Ethernet3/0
 description TO_TOAE_Floor1_ACCESS [E-G] PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 82,85,86
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/1
 description TO_TOAE_Floor2_ACCESS [E-1] PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 92,95,96
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/2
 description TO_TOAE_Floor3_ACCESS [E-2] PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet3/3
 description TO_TOAE_Floor4_ACCESS [E-3] PRIMARY
 switchport mode trunk
 switchport trunk allowed vlan 112,113,115,116,999
 spanning-tree portfast trunk
 no shutdown
!
! ===== SVI – DISTRIBUTION (.251/mask) =====
interface Vlan10
 ip address 10.1.0.251 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
! ... (lặp lại .251 cho toàn bộ VLAN như SWL3_3 nhưng dùng .251)
!
interface Vlan999
 ip address 10.99.99.5 255.255.255.224
 no shutdown
!
interface Vlan1040
 ip address 10.100.40.251 255.255.255.0
 ip ospf 1 area 0
 no shutdown
!
! ===== OSPF =====
router ospf 1
 router-id 4.4.4.4
 network 10.1.0.0 0.0.255.255 area 0
 network 10.8.0.0 0.7.255.255 area 0
 network 10.9.0.0 0.0.255.255 area 0
 network 10.10.0.0 0.0.255.255 area 0
 network 10.11.0.0 0.0.255.255 area 0
 network 10.99.99.0 0.0.0.31 area 0
 network 10.100.40.0 0.0.0.255 area 0
!
spanning-tree vlan 10-79 priority 20480
spanning-tree vlan 82-999 priority 16384
!
username admin privilege 15 secret VinHealth@Dist
ip ssh version 2
crypto key generate rsa modulus 2048
line vty 0 15
 login local
 transport input ssh
!
logging host 10.100.32.10
ntp server 10.100.33.1
end
```

---

### 9. Access Switches – Tòa A ✅ (Dùng bản TOAA_Floorx – Đúng)

> **Lưu ý:** Xóa Section 9.x (GigabitEthernet style). Chỉ giữ bản `TOAA_Floorx` dùng `Ethernet1/0`/`1/1`.  
> Dưới đây là mẫu hoàn chỉnh cho tất cả 8 tầng – uplink đã đúng theo sơ đồ.

**Mẫu đúng (lặp lại cho Floor1–Floor8, thay VLAN và IP tương ứng):**

```
! Ví dụ: TOAA_Floor1 (Tầng G – Tiếp nhận)
hostname TOAA_Floor1
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
vlan 10
 name A-G-STAFF
vlan 11
 name A-G-PATIENT-WIFI
vlan 12
 name A-G-DEVICES
vlan 13
 name A-G-CCTV
!
interface Vlan10
 description MANAGEMENT
 ip address 10.1.0.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.0.254
!
! Uplink Primary
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
! Uplink Backup
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,11,12,13
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN10-STAFF
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN11-PATIENT-WIFI
 switchport mode access
 switchport access vlan 11
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN12-DEVICES
 switchport mode access
 switchport access vlan 12
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN13-CCTV
 switchport mode access
 switchport access vlan 13
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
service password-encryption
enable secret 0 VinHealth@2025!
username admin privilege 15 secret VinHealth@2025!

service password-encryption
enable secret nt113-project
username admin privilege 15 secret nt113-project

line console 0
 login local
 logging synchronous
line vty 0 4
 login local
 transport input ssh
ip ssh version 2
crypto key generate rsa modulus 2048
!
ntp server 10.100.33.10
logging host 10.100.32.10
logging trap informational
snmp-server community VinHealth_RO RO
snmp-server contact noc@vinhealth.vn
end
write memory
```

---

### 10. Access Switches – Tòa E ✅ (Bản TOAE_Floorx – Đúng)

> Giữ nguyên bản TOAE_Floor1–Floor3 đã có trong file gốc. Uplink `Ethernet1/0`/`1/1` đúng.

---

### 11. SWL3_Clinic – Satellite Clinic 🔧 (ĐÃ SỬA CỔNG + ROUTING + OSPF)

> **Sửa:**
> 1. `GigabitEthernet0/1`–`0/4` → `Ethernet0/0`, `Ethernet3/2`–`3/0`  
> 2. Routing loop: static route via `10.2.41.2` (chính nó) → sửa via `10.2.41.3` (IP của R3/FW3)  
> 3. Xóa OSPF area 1 (không cần thiết nếu dùng static routing về Central)  
> 4. Tách IP conflict: bỏ `Vlan221` khỏi subnet `10.2.41.0/29` (đã dùng cho physical port)

```
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
vlan 210
 name SAT-1-CLINIC
vlan 211
 name SAT-1-DIAGNOSTIC
vlan 212
 name SAT-1-CCTV
vlan 220
 name SAT-2-SERVER-ROOM
vlan 221
 name SAT-2-FIREWALL-MGMT
vlan 222
 name SAT-2-VPN-TUNNEL
vlan 223
 name SAT-2-CCTV
!
! ===== UPLINK KẾT NỐI R3/FW3 (Linux Router) =====
! [SỬA] GigabitEthernet0/1 → Ethernet0/0
! [SỬA] IP: phần này kết nối vật lý với R3, IP của SWL3_Clinic = .1, R3 = .2
interface Ethernet0/0
 description TO_R3_FIREWALL3_WIREGUARD
 no switchport
 ip address 10.2.41.1 255.255.255.248
 no shutdown
!
! ===== DOWNLINK TRUNK XUỐNG FLOOR SWITCHES =====
! [SỬA] GigabitEthernet0/2 → Ethernet3/2 (Floor1 = SAT_FloorG)
interface Ethernet3/2
 description TO_SAT_FloorG [Tầng G - Tiếp nhận]
 switchport mode trunk
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 200,201,202,203
 spanning-tree portfast trunk
 no shutdown
!
! [SỬA] GigabitEthernet0/3 → Ethernet3/1 (Floor2 = SAT_Floor1)
interface Ethernet3/1
 description TO_SAT_Floor1 [Tầng 1 - Khám chuyên khoa]
 switchport mode trunk
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 210,211,212,213
 spanning-tree portfast trunk
 no shutdown
!
! [SỬA] GigabitEthernet0/4 → Ethernet3/0 (Floor3 = SAT_Floor2/MDF)
interface Ethernet3/0
 description TO_SAT_Floor2_MDF [Tầng 2 - Server Room]
 switchport mode trunk
 switchport trunk encapsulation dot1q
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
! [SỬA] Vlan221 đổi sang subnet khác để tránh conflict với Ethernet0/0 (10.2.41.0/29)
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
! [SỬA] Gateway là R3/FW3 Linux = 10.2.41.2 (đầu bên kia của Ethernet0/0 /29)
ip route 10.1.0.0 255.255.0.0 10.2.41.2
ip route 10.8.0.0 255.248.0.0 10.2.41.2
ip route 10.100.0.0 255.255.0.0 10.2.41.2
ip route 0.0.0.0 0.0.0.0 10.2.41.2
!
! ===== OSPF – CHỈ NỘI BỘ CLINIC, KHÔNG CẦN KẾT NỐI AREA 0 =====
! [SỬA] Đổi area 1 → area 0 nếu muốn tương lai mở rộng OSPF về Central
! Hiện tại: dùng static routing về Central (qua WireGuard) = đủ
! Không dùng OSPF (xóa router ospf 1 nếu chỉ dùng static)
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

### 12. SAT_FloorG / SAT_Floor1 / SAT_Floor2 – Satellite Floor Switches 🔧 (SỬA UPLINK)

> **Sửa:** `GigabitEthernet0/1` → `Ethernet1/0` cho uplink lên SWL3_Clinic

```
! === SAT_FloorG (Tầng G – Tiếp nhận & Cấp cứu) ===
hostname SAT_FloorG
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
! [SỬA] GigabitEthernet0/1 → Ethernet1/0
interface Ethernet1/0
 description TRUNK-TO-SWL3_Clinic [UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 200,201,202,203
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet0/0
 description ACCESS-VLAN200-RECEPTION
 switchport mode access
 switchport access vlan 200
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet0/1
 description ACCESS-VLAN201-EMERGENCY
 switchport mode access
 switchport access vlan 201
 ! CRITICAL: Không PortFast/BPDUGuard – thiết bị y tế
 no shutdown
!
interface Ethernet0/2
 description ACCESS-VLAN202-CCTV
 switchport mode access
 switchport access vlan 202
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
service password-encryption
enable secret 0 VinHealth@2025!
username admin privilege 15 secret VinHealth@2025!
line console 0
 login local
line vty 0 4
 login local
 transport input ssh
ip ssh version 2
crypto key generate rsa modulus 2048
ntp server 10.100.33.10
logging host 10.100.32.10
end
write memory
```

---

## TÓM TẮT THAY ĐỔI THEO THIẾT BỊ

| Thiết bị | Thay đổi chính | Trạng thái |
|---------|---------------|-----------|
| R1 | Không thay đổi | ✅ Đúng |
| R2 | Không thay đổi | ✅ Đúng |
| Firewall1 | Không thay đổi | ✅ Đúng |
| Firewall2 | Không thay đổi | ✅ Đúng |
| **SWL3_1** | FastEthernet→Ethernet; sửa OSPF passive; sửa HSRP track | 🔧 Sửa |
| **SWL3_2** | GigabitEthernet1/0/x→Ethernet0/x; sửa HSRP track | 🔧 Sửa |
| **SWL3_3** | Gi1/0/47-48→Eth0/2,0/0; Gi1/0/1-12→Eth2/x,3/x | 🔧 Sửa |
| **SWL3_4** | Tương tự SWL3_3 | 🔧 Sửa |
| Access Tòa A (Sec 9.x) | **Xóa** – giữ bản TOAA_Floorx | 🗑️ Xóa |
| TOAA_Floor1–8 | Đúng (Ethernet1/0, 1/1, 0/x) | ✅ Đúng |
| TOAE_Floor1–3 | Đúng | ✅ Đúng |
| **SWL3_Clinic** | Gi0/x→Eth0/0,3/x; sửa routing loop; sửa IP conflict | 🔧 Sửa |
| **SAT Floor Switches** | GigabitEthernet0/1→Ethernet1/0 | 🔧 Sửa |
