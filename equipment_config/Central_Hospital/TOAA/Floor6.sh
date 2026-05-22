hostname TOAA_Floor6
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
vlan 70
 name A-6-STAFF
vlan 71
 name A-6-PATIENT-WIFI
vlan 72
 name A-6-NURSE-CALL
vlan 73
 name A-6-CCTV
!
interface Vlan70
 description MANAGEMENT
 ip address 10.1.60.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.60.254
!
! Uplink Primary
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
! Uplink Backup
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 70,71,72,73
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN70-STAFF
 switchport mode access
 switchport access vlan 70
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN71-PATIENT-WIFI
 switchport mode access
 switchport access vlan 71
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN72-NURSE-CALL
 switchport mode access
 switchport access vlan 72
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN73-CCTV
 switchport mode access
 switchport access vlan 73
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