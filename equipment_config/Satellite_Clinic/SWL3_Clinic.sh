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
! [SỬA] GigabitEthernet0/2 → Ethernet3/2
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