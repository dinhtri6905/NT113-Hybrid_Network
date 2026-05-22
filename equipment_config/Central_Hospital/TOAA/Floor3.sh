hostname TOAA_Floor3
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
! CRITICAL ZONE – Không có Guest/Patient-WiFi
!
vlan 40
 name A-3-STAFF
vlan 41
 name A-3-CRITICAL-DEVICES
vlan 42
 name A-3-MONITORING
vlan 43
 name A-3-CCTV
!
interface Vlan40
 description MANAGEMENT
 ip address 10.1.30.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.30.254
!
! Uplink Primary
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
! Uplink Backup
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 40,41,42,43
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN40-STAFF
 switchport mode access
 switchport access vlan 40
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN41-CRITICAL-DEVICES
 switchport mode access
 switchport access vlan 41
 spanning-tree portfast
 spanning-tree bpduguard enable
 storm-control broadcast level 20
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN42-MONITORING
 switchport mode access
 switchport access vlan 42
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN43-CCTV
 switchport mode access
 switchport access vlan 43
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
service password-encryption
enable secret nt113-project
username admin privilege 15 secret nt113-project
!
line console 0
 login local
 logging synchronous
!
line vty 0 4
 login local
 transport input ssh
!
ip ssh version 2
crypto key generate rsa modulus 2048
!
ntp server 10.100.33.10
logging host 10.100.32.10
logging trap informational
snmp-server community VinHealth_RO RO
snmp-server contact noc@vinhealth.vn
!
end
write memory