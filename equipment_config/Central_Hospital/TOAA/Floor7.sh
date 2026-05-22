hostname TOAA_Floor7
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
interface Vlan78
 description MANAGEMENT
 ip address 10.1.70.2 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.70.254
!
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree cost 10
 no shutdown
!
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 76,77,78,79
 spanning-tree cost 20
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN78-STAFF
 switchport mode access
 switchport access vlan 78
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN79-PATIENT-WIFI-VIP
 switchport mode access
 switchport access vlan 79
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN77-NURSE-CALL
 switchport mode access
 switchport access vlan 77
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN76-CCTV
 switchport mode access
 switchport access vlan 76
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
 exec-timeout 10 0
!
ip ssh version 2
crypto key generate rsa modulus 2048
!
ntp server 10.100.33.1
logging host 10.100.32.10
logging trap informational
snmp-server community VinHealth_RO RO
snmp-server contact noc@vinhealth.vn
!
end
write memory