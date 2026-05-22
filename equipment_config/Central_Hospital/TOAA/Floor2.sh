hostname TOAA_Floor2
!
vtp mode client
vtp domain VINHEALTH
vtp password VinHealth2024
!
no ip domain-lookup
ip domain-name vinhealth.local
spanning-tree mode rapid-pvst
!
interface Vlan30
 description MANAGEMENT
 ip address 10.1.20.2 255.255.255.0
 no shutdown
!
ip default-gateway 10.1.20.254
!
interface Ethernet1/0
 description TRUNK-TO-SWL3_3 [PRIMARY UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree cost 10
 no shutdown
!
interface Ethernet1/1
 description TRUNK-TO-SWL3_4 [BACKUP UPLINK]
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 30,31,32,33
 spanning-tree cost 20
 no shutdown
!
interface Ethernet2/0
 description ACCESS-VLAN30-STAFF
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/1
 description ACCESS-VLAN31-LIS-IOT
 switchport mode access
 switchport access vlan 31
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/2
 description ACCESS-VLAN32-DEVICES
 switchport mode access
 switchport access vlan 32
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
!
interface Ethernet2/3
 description ACCESS-VLAN33-CCTV
 switchport mode access
 switchport access vlan 33
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