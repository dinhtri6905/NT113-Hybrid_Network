hostname TOAE_Floor2
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
vlan 102
 name E-2-HR-STAFF
vlan 105
 name E-2-CCTV
vlan 106
 name E-2-MANAGEMENT
!
interface Vlan106
 description MANAGEMENT
 ip address 10.10.60.1 255.255.255.248
 no shutdown
!
ip default-gateway 10.10.60.6
!
! Uplink Primary
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
! Uplink Backup
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 102,105,106
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN102-HR-STAFF
 switchport mode access
 switchport access vlan 102
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN105-CCTV
 switchport mode access
 switchport access vlan 105
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN106-MANAGEMENT
 switchport mode access
 switchport access vlan 106
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