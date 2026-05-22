hostname TOAA_Floor5
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
vlan 60
 name A-5-STAFF
vlan 61
 name A-5-PATIENT-WIFI
vlan 62
 name A-5-NURSE-CALL
vlan 63
 name A-5-CCTV
!
interface Vlan60
 description MANAGEMENT
 ip address 10.1.50.1 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.50.254
!
! Uplink Primary
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
! Uplink Backup
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 60,61,62,63
 switchport trunk native vlan 1
 spanning-tree portfast trunk
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN60-STAFF
 switchport mode access
 switchport access vlan 60
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN61-PATIENT-WIFI
 switchport mode access
 switchport access vlan 61
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN62-NURSE-CALL
 switchport mode access
 switchport access vlan 62
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN63-CCTV
 switchport mode access
 switchport access vlan 63
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