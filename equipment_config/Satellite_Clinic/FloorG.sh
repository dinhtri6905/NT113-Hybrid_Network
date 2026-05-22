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