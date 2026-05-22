1. Khu vực Phòng khám vệ tinh (Satellite Clinic)
Floor3 (Satellite) cổng `e1/0` ↔ SWL3 cổng `e3/0`
Floor2 (Satellite) cổng `e1/0` ↔ SWL3 cổng `e3/1`
Floor1 (Satellite) cổng `e1/0` ↔ SWL3 cổng `e3/2`
SWL3 cổng `Fa0/0` ↔ Firewall3 cổng `Fa0/0`
Firewall3 cổng `Fa1/0` ↔ R3 cổng `Fa1/0`
R3 cổng `Fa0/0` ↔ ISP1 cổng `Fa2/0`

2. Khu vực Đường truyền WAN và Cốt lõi (Cloud / ISP / Router / Firewall / Switch Core)
Cloud cổng `Internet` ↔ ISP1 cổng `Fa3/0`
ISP1 cổng `Fa0/0` ↔ R1 cổng `Fa0/0`
ISP1 cổng `Fa1/0` ↔ R2 cổng `Fa1/0`
ISP2 cổng `Fa1/0` ↔ R1 cổng `Fa1/0`
ISP2 cổng `Fa0/0` ↔ R2 cổng `Fa0/0`
R1 cổng `Fa2/0` ↔ Firewall1 cổng `Fa2/0`
R2 cổng `Fa2/0` ↔ Firewall2 cổng `Fa2/0`
Firewall1 cổng `Fa0/0` ↔ SWL3_1 cổng `e0/0`
Firewall2 cổng `Fa0/0` ↔ SWL3_2 cổng `e0/0`

SWL3_1 cổng `e0/1` ↔ SWL3_2 cổng `e0/1`
SWL3_1 cổng `e0/2` ↔ SWL3_4 cổng `e0/2`
SWL3_1 cổng `e0/3` ↔ SWL3_3 cổng `e0/3`

SWL3_2 cổng `e/1` ↔ SWL3_1 cổng `e0/1`
SWL3_2 cổng `e0/2` ↔ SWL3_3 cổng `e0/2`
SWL3_4 cổng `e0/3` ↔ SWL3_4 cổng `e0/3`


3. Bệnh viện trung tâm (Central Hospital) - TÒA A
Floor8 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e2/3`
Floor8 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e2/3`
Floor7 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e2/2`
Floor7 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e2/2`
Floor6 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e2/1`
Floor6 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e2/1`
Floor5 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e2/0`
Floor5 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e2/0`
Floor4 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e1/3`
Floor4 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e1/3`
Floor3 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e1/2`
Floor3 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e1/2`
Floor2 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e1/1`
Floor2 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e1/1`
Floor1 (Tòa A) cổng `e1/0` ↔ SWL3_3 cổng `e1/0`
Floor1 (Tòa A) cổng `e1/1` ↔ SWL3_4 cổng `e1/0`

4. Bệnh viện trung tâm (Central Hospital) - TÒA E
Floor4 (Tòa E) cổng `e1/0` ↔ SWL3_3 cổng `e3/3`
Floor4 (Tòa E) cổng `e1/1` ↔ SWL3_4 cổng `e3/3`
Floor3 (Tòa E) cổng `e1/0` ↔ SWL3_3 cổng `e3/2`
Floor3 (Tòa E) cổng `e1/1` ↔ SWL3_4 cổng `e3/2`
Floor2 (Tòa E) cổng `e1/0` ↔ SWL3_3 cổng `e3/1`
Floor2 (Tòa E) cổng `e1/1` ↔ SWL3_4 cổng `e3/1`
Floor1 (Tòa E) cổng `e1/0` ↔ SWL3_3 cổng `e3/0`
Floor1 (Tòa E) cổng `e1/1` ↔ SWL3_4 cổng `e3/0`