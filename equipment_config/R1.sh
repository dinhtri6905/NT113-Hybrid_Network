config t
hostname R1
!
ip cef
!
! =====================================================
! 1. SYSTEM SETTINGS (LOGGING + SECURITY HARDENING)
! =====================================================
service timestamps log datetime msec localtime
logging buffered 16384 informational
no ip http server
no ip http secure-server
!
!
! =====================================================
! 2. AAA + SSH CONFIG (SECURITY ACCESS)
! =====================================================
username admin privilege 15 secret VinHealth@2024
!
aaa new-model
aaa authentication login default local
!
ip domain-name vinhealth.local
crypto key generate rsa modulus 2048
ip ssh version 2
!
line vty 0 4
 login authentication default
 transport input ssh
 exec-timeout 10 0
!
line con 0
 logging synchronous
!
!
! =====================================================
! 3. INTERFACES (PHYSICAL / LAYER 3)
! =====================================================
interface FastEthernet0/0
 description TO_ISP1_PRIMARY
 ip address 100.100.100.2 255.255.255.252
 no shutdown
!
interface FastEthernet1/0
 description TO_ISP2_CROSS_BACKUP
 ip address 100.100.200.2 255.255.255.252
 no shutdown
!
interface FastEthernet2/0
 description TO_FIREWALL1_INSIDE
 ip address 10.100.0.1 255.255.255.252
 no shutdown
!
!
! =====================================================
! 4. IP SLA + TRACKING (FAILOVER MONITORING)
! =====================================================
ip sla 1
 icmp-echo 100.100.100.1 source-interface FastEthernet0/0
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
! 5. ROUTING (STATIC + FAILOVER)
! =====================================================
! Primary default route (ISP1 - tracked)
ip route 0.0.0.0 0.0.0.0 100.100.100.1 10 track 1

! Backup default route (ISP2 floating)
ip route 0.0.0.0 0.0.0.0 100.100.200.1 20

! Internal route to LAN via Firewall
ip route 10.0.0.0 255.0.0.0 10.100.0.2
!
!
end
write memory