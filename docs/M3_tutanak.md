# M3 — Adım 3: CPU, interrupt ve bus

*Tutanaktaki başlık: Adım 3 — CPU, interrupt ve bus (final paketiyle: 16 Kasım, Pazartesi)*

## Model varsayımları (okudum ve uyguladım)

- ☒ Pipeline yok, her an tek instruction yürütülür.

- ☒ PC, IR, MAR ve MBR Fig. 3.2'deki gibi kavramsal olarak vardır.

- ☒ Her bellek erişimi bir bus işlemidir; cache bu adımda yok sayılır.

- ☒ Data bus genişliği = 32 bit (RV32 word = 32 bit).

## Modelin gerçek donanımdan ayrıldığı yerler (3–5 cümle)

Gerçek RISC-V çekirdekleri (Ripes'taki 5-stage dahil) pipeline kullanır; aynı anda birden çok instruction farklı aşamalardadır, oysa bu modelde bir instruction bitmeden sonraki fetch edilmez. Gerçek donanımda instruction fetch'ler I-cache'ten, load/store'lar D-cache'ten karşılanır; bu adımda her erişim ana belleğe giden ayrı bir bus işlemi sayılır, bu yüzden bus işlemi sayısı gerçekte olacağından çok fazladır. MAR, MBR ve IR RISC-V ISA'sında tanımlı register'lar değildir; burada yalnızca kavramsal olarak, Fig. 3.2'deki gibi kullanılır (gerçek datapath'te pipeline register'ları ve adres/veri latch'leri vardır). Ayrıca Fig. 3.6'nın durumları tek bir sıralı akış olarak gösterilir; gerçek işlemcide iac (PC + 4) ile do aynı cycle'da, ALU dışındaki toplayıcılarla paralel yapılır ve tek bus yerine ayrı instruction/data yolları (Harvard tarzı L1) bulunur.

## 3a. Instruction cycle izleme tablosu

Her dinamik instruction bir satırdır. Bir instruction birden çok bellek erişimi yapıyorsa MAR, MBR ve bus hücrelerine sırayla yazılır. Kategori: PM = processor–memory, PIO = processor–I/O, DP = data processing, C = control.

| # | PC (önce → sonra) | Assembly | IR (hex) | Fig. 3.6 durumları | MAR | MBR | ALU işlemi | Değişen register | Bus (adres / data / control) | Kategori |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0x101BC → 0x1005C | jal x1, 0x1005C<br>(jal ra,out_of_order) | 0xEA1FF0EF | iac, if, iod, do | 0x000101BC | 0xEA1FF0EF | PC + 4 = 0x101C0; hedef = 0x101BC + (−352) = 0x1005C | ra (x1) = 0x000101C0; PC = 0x1005C | (0x000101BC / 0xEA1FF0EF / Memory read) | C |
| 2 | 0x1005C → 0x10060 | addi x2, x2, -32 | 0xFE010113 | iac, if, iod, do | 0x0001005C | 0xFE010113 | 0x7FFFFFB0 + (−32) = 0x7FFFFF90 | sp (x2) = 0x7FFFFF90 | (0x0001005C / 0xFE010113 / Memory read) | DP |
| 3 | 0x10060 → 0x10064 | sw x1, 28(x2) | 0x00112E23 | iac, if, iod, oac, os | 0x00010060, sonra 0x7FFFFFAC | 0x00112E23, sonra 0x000101C0 | adres: 0x7FFFFF90 + 28 = 0x7FFFFFAC | yok (bellek[0x7FFFFFAC] = 0x101C0) | (0x00010060 / 0x00112E23 / Memory read),<br>(0x7FFFFFAC / 0x000101C0 / Memory write) | PM |
| 4 | 0x10064 → 0x10068 | sw x8, 24(x2) | 0x00812C23 | iac, if, iod, oac, os | 0x00010064, sonra 0x7FFFFFA8 | 0x00812C23, sonra 0x7FFFFFE0 | adres: 0x7FFFFF90 + 24 = 0x7FFFFFA8 | yok (bellek[0x7FFFFFA8] = 0x7FFFFFE0) | (0x00010064 / 0x00812C23 / Memory read),<br>(0x7FFFFFA8 / 0x7FFFFFE0 / Memory write) | PM |
| 5 | 0x10068 → 0x1006C | addi x8, x2, 32 | 0x02010413 | iac, if, iod, do | 0x00010068 | 0x02010413 | 0x7FFFFF90 + 32 = 0x7FFFFFB0 | s0 (x8) = 0x7FFFFFB0 | (0x00010068 / 0x02010413 / Memory read) | DP |
| 6 | 0x1006C → 0x10070 | sw x10, -20(x8) | 0xFEA42623 | iac, if, iod, oac, os | 0x0001006C, sonra 0x7FFFFF9C | 0xFEA42623, sonra 0x000000BE (190) | adres: 0x7FFFFFB0 − 20 = 0x7FFFFF9C | yok (bellek[0x7FFFFF9C] = 190 = a) | (0x0001006C / 0xFEA42623 / Memory read),<br>(0x7FFFFF9C / 0x000000BE / Memory write) | PM |
| 7 | 0x10070 → 0x10074 | sw x11, -24(x8) | 0xFEB42423 | iac, if, iod, oac, os | 0x00010070, sonra 0x7FFFFF98 | 0xFEB42423, sonra 0x0000017A (378) | adres: 0x7FFFFFB0 − 24 = 0x7FFFFF98 | yok (bellek[0x7FFFFF98] = 378 = b) | (0x00010070 / 0xFEB42423 / Memory read),<br>(0x7FFFFF98 / 0x0000017A / Memory write) | PM |
| 8 | 0x10074 → 0x10078 | sw x12, -28(x8) | 0xFEC42223 | iac, if, iod, oac, os | 0x00010074, sonra 0x7FFFFF94 | 0xFEC42223, sonra 0x00000001 | adres: 0x7FFFFFB0 − 28 = 0x7FFFFF94 | yok (bellek[0x7FFFFF94] = 1 = desc) | (0x00010074 / 0xFEC42223 / Memory read),<br>(0x7FFFFF94 / 0x00000001 / Memory write) | PM |
| 9 | 0x10078 → 0x1007C | lw x15, -28(x8) | 0xFE442783 | iac, if, iod, oac, of | 0x00010078, sonra 0x7FFFFF94 | 0xFE442783, sonra 0x00000001 | adres: 0x7FFFFFB0 − 28 = 0x7FFFFF94 | a5 (x15) = 1 | (0x00010078 / 0xFE442783 / Memory read),<br>(0x7FFFFF94 / 0x00000001 / Memory read) | PM |
| 10 | 0x1007C → 0x10080 | beq x15, x0, 0x10094<br>(beqz a5,.L4) | 0x00078C63 | iac, if, iod, do | 0x0001007C | 0x00078C63 | karşılaştırma 1 = 0? hayır → alınmaz (hedef 0x1007C + 24 = 0x10094) | yok (PC = PC + 4) | (0x0001007C / 0x00078C63 / Memory read) | C |
| 11 | 0x10080 → 0x10084 | lw x14, -20(x8) | 0xFEC42703 | iac, if, iod, oac, of | 0x00010080, sonra 0x7FFFFF9C | 0xFEC42703, sonra 0x000000BE | adres: 0x7FFFFFB0 − 20 = 0x7FFFFF9C | a4 (x14) = 190 | (0x00010080 / 0xFEC42703 / Memory read),<br>(0x7FFFFF9C / 0x000000BE / Memory read) | PM |
| 12 | 0x10084 → 0x10088 | lw x15, -24(x8) | 0xFE842783 | iac, if, iod, oac, of | 0x00010084, sonra 0x7FFFFF98 | 0xFE842783, sonra 0x0000017A | adres: 0x7FFFFFB0 − 24 = 0x7FFFFF98 | a5 (x15) = 378 | (0x00010084 / 0xFE842783 / Memory read),<br>(0x7FFFFF98 / 0x0000017A / Memory read) | PM |
| 13 | 0x10088 → 0x1008C | slt x15, x14, x15 | 0x00F727B3 | iac, if, iod, do | 0x00010088 | 0x00F727B3 | 190 &lt; 378 (işaretli) → 1 | a5 (x15) = 1 | (0x00010088 / 0x00F727B3 / Memory read) | DP |
| 14 | 0x1008C → 0x10090 | andi x15, x15, 255 | 0x0FF7F793 | iac, if, iod, do | 0x0001008C | 0x0FF7F793 | 1 AND 0xFF = 1 | a5 (x15) = 1 | (0x0001008C / 0x0FF7F793 / Memory read) | DP |
| 15 | 0x10090 → 0x100A4 | jal x0, 0x100A4<br>(j .L5) | 0x0140006F | iac, if, iod, do | 0x00010090 | 0x0140006F | hedef = 0x10090 + 20 = 0x100A4 | yok (x0'a yazılmaz); PC = 0x100A4 | (0x00010090 / 0x0140006F / Memory read) | C |
| 16 | 0x100A4 → 0x100A8 | addi x10, x15, 0<br>(mv a0,a5) | 0x00078513 | iac, if, iod, do | 0x000100A4 | 0x00078513 | 1 + 0 = 1 | a0 (x10) = 1 (dönüş değeri) | (0x000100A4 / 0x00078513 / Memory read) | DP |
| 17 | 0x100A8 → 0x100AC | lw x1, 28(x2) | 0x01C12083 | iac, if, iod, oac, of | 0x000100A8, sonra 0x7FFFFFAC | 0x01C12083, sonra 0x000101C0 | adres: 0x7FFFFF90 + 28 = 0x7FFFFFAC | ra (x1) = 0x000101C0 | (0x000100A8 / 0x01C12083 / Memory read),<br>(0x7FFFFFAC / 0x000101C0 / Memory read) | PM |
| 18 | 0x100AC → 0x100B0 | lw x8, 24(x2) | 0x01812403 | iac, if, iod, oac, of | 0x000100AC, sonra 0x7FFFFFA8 | 0x01812403, sonra 0x7FFFFFE0 | adres: 0x7FFFFF90 + 24 = 0x7FFFFFA8 | s0 (x8) = 0x7FFFFFE0 | (0x000100AC / 0x01812403 / Memory read),<br>(0x7FFFFFA8 / 0x7FFFFFE0 / Memory read) | PM |
| 19 | 0x100B0 → 0x100B4 | addi x2, x2, 32 | 0x02010113 | iac, if, iod, do | 0x000100B0 | 0x02010113 | 0x7FFFFF90 + 32 = 0x7FFFFFB0 | sp (x2) = 0x7FFFFFB0 | (0x000100B0 / 0x02010113 / Memory read) | DP |
| 20 | 0x100B4 → 0x101C0 | jalr x0, 0(x1)<br>(ret) | 0x00008067 | iac, if, iod, do | 0x000100B4 | 0x00008067 | hedef = x1 + 0 = 0x101C0 (bit 0 sıfırlanır) | yok; PC = 0x101C0 (sort'a dönüş) | (0x000100B4 / 0x00008067 / Memory read) | C |

| Kernel toplamları | Sayı |
|---|---|
| Instruction fetch | 20 (her instruction için 1 fetch; 20 × Memory read) |
| Operand fetch (of) | 5 (#9, #11, #12, #17, #18: lw) |
| Operand store (os) | 5 (#3, #4, #6, #7, #8: sw) |
| PC'nin sıra dışı değiştiği instruction | #1 jal (0x101BC → 0x1005C, çağrı), #15 jal x0 (0x10090 → 0x100A4, else'in üstünden atlama), #20 jalr (0x100B4 → 0x101C0, dönüş). #10 beq alınmadı (desc = 1); desc = 0 olsaydı PC = 0x10094 olurdu. Kategori sayıları: PM 10, DP 6, C 4, PIO 0. |

## 3b. Fig. 3.4 makinesine aktarım

Kernel'in tek bir dizi elemanını güncelleyen parçası, opcode 1, 2, 3, 5 ve 7 ile yeniden yazılır ve Fig. 3.5 formatında izlenir:

| Adım | Fetch / execute | PC | IR (hex) | AC | Değişen bellek hücresi |
|---|---|---|---|---|---|
| 1 | Fetch | 300 → 301 | 1400 | – (önceki) | – |
| 2 | Execute | 301 | 1400 | 017A (378) | – (AC ← M[400] = data[1]) |
| 3 | Fetch | 301 → 302 | 23FC | 017A | – |
| 4 | Execute | 302 | 23FC | 017A | M[3FC] (data[0]): 00BE → 017A |
| 5 | Fetch | 302 → 303 | 7006 | 017A | – |
| 6 | Execute | 303 | 7006 | 017A | – (I/O device 6 ← 017A) |
| 7 | Fetch | 303 → 304 | 3005 | 017A | – |
| 8 | Execute | 304 | 3005 | 0001 | – (AC ← I/O device 5 = 0001, varsayım) |
| 9 | Fetch | 304 → 305 | 53F8 | 0001 | – |
| 10 | Execute | 305 | 53F8 | 0001 (0001 + 0000) | – (AC ← AC + M[3F8] = swaps) |
| 11 | Fetch | 305 → 306 | 23F8 | 0001 | – |
| 12 | Execute | 306 | 23F8 | 0001 | M[3F8] (swaps): 0000 → 0001 |

Aktarılan parça: takasın data[0]'ı güncelleyen satırı (C satırı 35, data[j] = data[j + 1], j = 0) ve swaps++ (satır 37). Adresler gerçek adreslerin düşük 12 biti olarak eşlendi: data[0] = 0x113FC → 3FC, data[1] = 0x11400 → 400, swaps = 0x113F8 → 3F8 (varsayım: 16-bit word, değerler hex; 190 = 00BE, 378 = 017A). Program 300'den başlar: 1400 (LOAD AC ← M[400]), 23FC (STORE AC → M[3FC]), 7006 (Store AC to I/O: güncellenen değer çıkış aygıtı 6'ya), 3005 (Load AC from I/O: aygıt 5 sabit 0001 verir, varsayım; Fig. 3.4'te immediate adresleme olmadığı için +1 sabiti bir bellek hücresinden ya da aygıttan gelmek zorundadır), 53F8 (ADD AC ← AC + M[3F8]), 23F8 (STORE AC → M[3F8]).

| Ölçü | Seçilen ISA | Fig. 3.4 makinesi |
|---|---|---|
| Aynı iş için instruction cycle sayısı | 18 instruction cycle (-O0): satır 35 = 13 (0x101E4–0x10214: 4 ALU adres hesabı + 2 lw j + lw data[j+1] + lui/addi &amp;data ×2 + slli ×2 + add ×2 + sw), satır 37 = 5 (0x10238–0x10248: lui, lw, addi, lui, sw). 18 fetch + 4 data read + 2 data write. | 5 instruction cycle aynı iş için (1400, 23FC, 3005, 53F8, 23F8) + 1 I/O çıkışı (7006) = 6. 6 fetch + 2 data read + 2 data write + 2 I/O. Oran ≈ 18 / 5 = 3.6; -O0'da fark, her erişimde j'nin stack'ten yeniden yüklenmesi ve &amp;data[j] adresinin (lui/addi/slli/add) yeniden hesaplanmasından gelir; Fig. 3.4'te adres instruction'ın içinde sabittir (indis yok). |

## Tek accumulator'ın getirdiği sınırlama (PDP-11 ADD B,A ile karşılaştırarak)

Fig. 3.4 makinesinde ALU'nun tek girişi AC'dir: her işlem bir operandı bellekten alır, diğeri ve sonuç her zaman AC'dedir. Bu yüzden iki bellek değerini toplamak bile üç instruction cycle ister (LOAD A, ADD B, STORE A) ve AC'deki ara değer başka bir iş için gerekiyorsa önce belleğe yazılmak zorundadır (takastaki t gibi). Stallings'in PDP-11 örneğinde ADD B,A tek instruction'dır: B ve A bellekten okunur, toplanır ve sonuç A'ya yazılır; yani tek instruction cycle'da iki operand fetch ve bir operand store yapılır (Fig. 3.6'da of ve os durumlarının tekrarlanabilmesi). RISC-V ise ikisinin arasında durur: bellek-bellek işlemi yoktur (load/store mimarisi), ama 31 genel register olduğu için a, b, &data[j] ve sayaç aynı anda register'larda tutulabilir; -O1 sürümünde takas kararı bu sayede yalnız 4 instruction'a iner (2b). Tek accumulator, ara sonuçlar için sürekli bellek trafiği (dolayısıyla bus cycle) demektir.

## IAS register'ları ve seçilen ISA

| IAS register'ı | IAS'taki görevi | Seçilen ISA'daki karşılığı | Programcıya görünür mü? |
|---|---|---|---|
| MBR | Bellekten okunan ya da belleğe/I/O'ya yazılacak word'ü tutar. | Tanımlı bir register yok; load/store datapath'indeki veri latch'i (Ripes'ta memory 'data in/out'). lw/sw'nin veri yolu. | Hayır (organization) |
| MAR | MBR'deki word'ün okunacağı/yazılacağı bellek adresini tutar. | Tanımlı bir register yok; adres her seferinde rs1 + imm (lw/sw) veya PC olarak hesaplanıp bus'a verilir. | Hayır (organization) |
| IR | Yürütülen instruction'ın 8-bit opcode'unu tutar. | Tanımlı değil; fetch edilen 32-bit instruction word'ü decode edilene kadar datapath'te tutulur (Ripes IF/ID). | Hayır (organization) |
| IBR | 40-bit word'deki sağdaki instruction'ı geçici olarak tutar (word başına iki instruction). | Karşılığı yok: her 32-bit word tek instruction'dır; gerçek çekirdeklerdeki fetch/prefetch buffer'ları ISA'da görünmez. | Hayır (organization) |
| PC | Sıradaki instruction (çifti) adresini tutar. | pc (32-bit). x0–x31 arasında değildir; jal/jalr/branch ile değiştirilir, auipc ve jal ile okunur (kernel #1, #15, #20). | Evet, dolaylı (architecture) |
| AC | ALU işlemlerinin operandını ve sonucunu tutan accumulator. | Tek accumulator yok; 31 genel register'ın (x1–x31) her biri bu görevi yapar (ör. a5 = x15). | Evet (architecture) |
| MQ | Çarpmada çarpanı ve sonucun düşük 39 bitini, bölmede bölümü tutar. | Ayrı register yok: mul düşük 32 biti, mulh/mulhu yüksek 32 biti, div/rem bölüm/kalanı herhangi bir x register'ına yazar (program % 1000 için mulhu kullanır). | Evet, genel register olarak (architecture); MQ'nun kendisi yok |

## 3c. Interrupt senaryosu (k = 3, tür = Timer)

| Soru | Cevap |
|---|---|
| Interrupt hangi instruction'ın execute'u sırasında geliyor? (adres, assembly) | Kernel'in 3. instruction'ı: 0x00010060 sw x1, 28(x2) (out_of_order prologue'unda ra'nın stack'e kaydı; MAR = 0x7FFFFFAC, MBR = 0x000101C0). |
| Ne zaman tanınır ve bu instruction neden yarıda kesilmez? (Fig. 3.9) | Fig. 3.9'a göre işlemci interrupt'ı yalnızca instruction cycle'ın sonunda (execute/os bittikten sonra, sıradaki fetch'ten önce) kontrol eder. Timer sinyali (mip.MTIP = 1) sw'nin execute'u sırasında gelir, ama sw, os durumundaki Memory write bus işlemini bitirir; ardından interrupt cycle başlar. Yarıda kesilseydi MAR/MBR'deki yarım işlem ve kısmi bellek yazması kaydedilmesi gereken fazladan bir durum olurdu; bütün instruction'ların tam bitmesi, dönüşte kaldığı yerden devam etmeyi tek bir PC değeriyle mümkün kılar (RISC-V'de interrupt'lar instruction sınırında alınır: mepc'deki instruction hiç başlamamış, öncekiler tamamlanmıştır). |
| Kaydedilen PC değeri (hex) | 0x00010064 (k + 1'inci instruction: sw x8, 24(x2)); donanım bunu mepc'ye yazar. |
| Kaydedilen diğer durum bilgisi | mcause = 0x80000007 (Interrupt = 1, Exception Code = 7: Machine timer interrupt); mstatus: MPIE ← MIE (1), MIE ← 0 (diğer interrupt'lar kapanır), MPP ← 11 (M-mode); mtval = 0. Genel register'lar (sp = 0x7FFFFF90, ra = 0x000101C0, s0 = 0x7FFFFFE0, a0 = 190, a1 = 378, a2 = 1) donanımca kaydedilmez; handler kullanacağı register'ları kendi stack'ine yazar. |
| Seçilen ISA'daki gerçek mekanizma (register adları, vektör) | mtime ≥ mtimecmp olunca mip.MTIP = 1 olur; mstatus.MIE = 1 ve mie.MTIE = 1 ise hart trap'e girer: mepc ← 0x00010064, mcause ← 0x80000007, PC ← mtvec. mtvec.MODE = 0 (Direct) ise PC = BASE; MODE = 1 (Vectored) ise PC = BASE + 4 × 7 = BASE + 0x1C. Handler mtimecmp'yi yeniden yazarak MTIP'i temizler ve mret ile döner (PC ← mepc, MIE ← MPIE). (Bare-metal programımız mtvec/mie kurmadığı için bu senaryo analizdir, varsayım.) |
| Kaynak (ISA referansı, bölüm, sayfa) | The RISC-V Instruction Set Manual, Volume II: Privileged Architecture, v20211203: §3.1.6.1 mstatus MIE/MPIE/MPP yığını (s. 21); §3.1.7 mtvec, Direct/Vectored (s. 29–30); §3.1.9 mip/mie, MTIP/MTIE ve öncelik sırası MEI &gt; MSI &gt; MTI (s. 31–34); §3.1.14 mepc (s. 37); §3.1.15 mcause ve Tablo 3.6 (s. 38–39); §3.2.1 mtime/mtimecmp (s. 44); §3.3.2 MRET (s. 46–47). |
| Handler dönüşünde ilk çalışan instruction'ın adresi | 0x00010064: sw x8, 24(x2) (mret, PC'yi mepc'den yükler; user program kaldığı yerden devam eder). |

## Fonksiyon çağrısı (Y3) ve interrupt karşılaştırması

| Ölçüt | Fonksiyon çağrısı | Interrupt |
|---|---|---|
| Akışı kim başlatır? | Program kendisi, planlı ve senkron: sort içindeki jal ra, out_of_order (0x101BC) instruction'ı. | Donanım (timer: mtime ≥ mtimecmp), asenkron; o anda yürütülen instruction'la (sw) ilgisi yoktur. |
| Dönüş adresini kim kaydeder, nereye? | jal donanımı PC + 4 = 0x000101C0'ı programcıya görünen ra (x1) register'ına yazar; callee bunu yazılımla stack'e kaydeder (sw x1, 28(x2) → 0x7FFFFFAC) ve jalr x0, 0(x1) ile döner. | Trap donanımı 0x00010064'ü CSR mepc'ye (genel register değil) yazar, mcause/mstatus'u günceller; handler kullandığı register'ları kendi stack'ine yazılımla kaydeder ve mret ile döner. |
| User program bundan haberdar mı? | Evet: çağrı kodda vardır; argümanlar (a0–a2), dönüş değeri (a0) ve stack frame ABI'ye göre derleyicinin ürettiği koddadır. | Hayır: interrupt user program için şeffaftır; dönüşte bütün register'lar ve bellek aynıdır, yalnızca süre uzar (Y7: median 472, min_v 21, max_v 988, swaps 457 değişmez). |

## İkinci (daha yüksek öncelikli) interrupt

Aynı olay dizisini iki yaklaşımla zaman çizelgesi olarak doldurun (Fig. 3.13 ve 3.14):

| Zaman | Sequential (disable) | Nested (priority) |
|---|---|---|
| t₀: 1. interrupt gelir | Timer handler (ISR-T) başlar: sw biter, mepc = 0x10064, mcause = 0x80000007; MIE = 0, tüm interrupt'lar kapalı. | ISR-T başlar; aynı kayıtlar yapılır. ISR-T mepc/mcause/mstatus'u stack'e kaydedip daha yüksek öncelikli kaynaklar için MIE'yi yeniden 1 yapar. |
| t₁: 2. interrupt gelir | 2. interrupt (yüksek öncelikli I/O, machine external interrupt, MEI) gelir; MIE = 0 olduğu için kabul edilmez, mip.MEIP beklemede kalır; ISR-T devam eder. | MEI, MTI'dan önceliklidir: ISR-T kesilir, ISR-T içindeki PC mepc'ye yazılır, I/O handler (ISR-IO) başlar. |
| t₂ | ISR-T biter; mret MIE'yi açar, bekleyen MEI hemen alınır (user program'a hiç dönülmeden): ISR-IO başlar. | ISR-IO biter; mret ile ISR-T'ye, kesildiği instruction'a döner. |
| t₃ | ISR-IO biter (mret). | ISR-T biter; stack'ten mepc = 0x10064'ü geri yükler ve mret yapar. |
| t₄: user program'a dönüş | PC = 0x00010064 (sw x8, 24(x2)). I/O isteği ISR-T'nin tamamı kadar beklemiştir (gecikme). | PC = 0x00010064 (sw x8, 24(x2)). I/O isteği hemen işlenmiştir; ISR-T daha geç biter. |

## 3d. Bus ve interconnection.

| Bus işlemi türü (kernel, cache yok) | Sayı | Aktif control line'lar |
|---|---|---|
| Instruction fetch (read) | 20 | Memory read, Clock, Transfer ACK (adres = PC, data = instruction word) |
| Data read | 5 (#9, #11, #12, #17, #18) | Memory read, Clock, Transfer ACK |
| Data write | 5 (#3, #4, #6, #7, #8) | Memory write, Clock, Transfer ACK |
| Toplam | 30 bus işlemi (25 read + 5 write); hepsi 32-bit word | I/O read/write hiç aktif olmaz (kernel'de I/O yok) |

| Hesap | Değer | Adımlar |
|---|---|---|
| Address bus genişliği ve maksimum adreslenebilir bellek | 2³² byte = 4 GiB | RV32: adresler 32 bit, byte adresleme → 2³² = 4 294 967 296 adreslenebilir byte. |
| Data bus 16 bit olsaydı kernel'in bus cycle sayısı | 60 bus cycle | Her instruction ve her data word'ü 32 bit = 2 × 16 bit → 2 transfer. Fetch 20 × 2 = 40, data read 5 × 2 = 10, data write 5 × 2 = 10; toplam 30 × 2 = 60. |
| Mevcut / 16-bit oranı | 30 / 60 = 0.5 | 32-bit bus, 16-bit bus'ın yarısı kadar bus cycle kullanır (aynı kernel 2 kat bus cycle ister; Problem 3.7 mantığı). |

## PCIe paket verimi (N × 4 = 45 × 4 = 180 byte'lık tek Memory Write TLP; Fig. 3.25)

| Alan (octet) | 12-byte header, ECRC yok | 16-byte header, ECRC var |
|---|---|---|
| STP framing (baş) | 1 | 1 |
| Sequence number | 2 | 2 |
| Header | 12 | 16 |
| Data | 180 (data[45]) | 180 (data[45]) |
| ECRC | 0 (yok) | 4 |
| LCRC | 4 | 4 |
| STP framing (son) | 1 | 1 |
| Toplam | 1 + 2 + 12 + 180 + 0 + 4 + 1 = 200 octet | 1 + 2 + 16 + 180 + 4 + 4 + 1 = 208 octet |
| Verim = data / toplam | 180 / 200 = 0.9000 (%90.00) | 180 / 208 = 0.8654 (%86.54) |
| 128b/130b ile verim | 0.9000 × 128/130 = 0.8862 (%88.62) | 0.8654 × 128/130 = 0.8521 (%85.21) |

## Sonucun bir çekirdekten PCIe cihazına yolu (Fig. 3.17 ve 3.21)

her adımda bağlantı, protokol katmanı ve aktarım birimi.

1) Çekirdek → kendi L1/L2 cache'i → çip üstü interconnect (çekirdek içi, protokol katmanı yok). 2) Çekirdek/cache → bellek denetleyicisi ve I/O hub: Fig. 3.17'deki multicore yapıda QPI bağlantısı. QPI protokol katmanı bir packet (yazma isteği) üretir; routing katmanı yolu seçer; link katmanı packet'i 80-bit flit'lere böler ve flit düzeyinde CRC ve kredi tabanlı akış denetimi yapar; fiziksel katman her flit'i 20-bit phit'ler halinde 20 lane üzerinden gönderir. 3) I/O hub içinde root complex, QPI isteğini PCIe'ye çevirir (Fig. 3.21). PCIe transaction katmanı 180 byte'lık Memory Write TLP'yi oluşturur (12/16-byte header + data + isteğe bağlı ECRC). Data link katmanı sequence number ve LCRC ekler; ACK/NAK ve akış denetimi için DLLP'ler değiş tokuş edilir. Fiziksel katman STP framing ekler ve 128b/130b kodlamayla lane'lere dağıtır. 4) Root complex → (gerekirse) PCIe switch → endpoint (PCIe cihazı): her link'te aynı TLP iletilir, her hop'ta DLLP'lerle onaylanır; cihaz TLP'yi açıp 180 byte'ı yazar. Posted write olduğu için cihaz completion TLP'si göndermez.
