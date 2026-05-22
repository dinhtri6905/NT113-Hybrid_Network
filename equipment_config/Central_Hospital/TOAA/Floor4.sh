hostname TOAA_Floor4
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
! CRITICAL ZONE
!
interface Vlan50
 description MANAGEMENT
 ip address 10.1.40.2 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.40.254
!
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree cost 10
 no shutdown
!
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 50,51,52,53
 spanning-tree cost 20
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN50-STAFF
 switchport mode access
 switchport access vlan 50
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN51-CRITICAL-DEVICES
 switchport mode access
 switchport access vlan 51
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN52-MONITORING
 switchport mode access
 switchport access vlan 52
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN53-CCTV
 switchport mode access
 switchport access vlan 53
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