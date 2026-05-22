config t
hostname R2
!
ip cef
!
! =====================================================
! 1. SYSTEM SETTINGS
! =====================================================
service timestamps log datetime msec localtime
logging buffered 16384 informational
no ip http server
no ip http secure-server
!
!
! =====================================================
! 2. AAA + SSH CONFIG
! =====================================================
username admin privilege 15 secret VinHealth@2024
!
ip domain-name vinhealth.local
crypto key generate rsa modulus 2048
ip ssh version 2
!
aaa new-model
!
line vty 0 4
 login local
 transport input ssh
!
!
! =====================================================
! 3. INTERFACES
! =====================================================
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
 description TO_FIREWALL2_INSIDE
 ip address 10.100.4.5 255.255.255.252
 no shutdown
!
!
! =====================================================
! 4. IP SLA + TRACKING
! =====================================================
ip sla 1
 icmp-echo 100.100.101.1 source-interface FastEthernet0/0
 threshold 5000
 timeout 5000
 frequency 10
!
ip sla schedule 1 life forever start-time now
!
track 1 ip sla 1 reachability
!
!
! =====================================================
! 5. ROUTING
! =====================================================
! Primary route via ISP2 (tracked)
ip route 0.0.0.0 0.0.0.0 100.100.101.1 10 track 1

! Backup route via ISP1 cross link
ip route 0.0.0.0 0.0.0.0 100.100.201.1 20

! Internal route via Firewall
ip route 10.0.0.0 255.0.0.0 10.100.4.6
!
end
write memory