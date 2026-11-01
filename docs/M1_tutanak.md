# M1 — Adım 0 ve Adım 1 (taslak)

## Öğrenci bilgileri

| Alan | Değer |
|---|---|
| Öğrenci numarası (SID) | 5001230021 |
| Seçilen görev | G4 Sıralama ve medyan |
| Seçilen ISA | RISC-V RV32IM |
| Derleyici | xPack GNU RISC-V Embedded GCC 15.2.0 (`riscv-none-elf-gcc`), `-march=rv32im -mabi=ilp32 -O0` |
| Simülatör / araçlar | Ripes (RISC-V, doğrulama), kendi RV32IM emülatörü `tools/rvsim.py`, kendi cache simülatörü `tools/cachesim.py` |

## Adım 0 — Kişiye özel parametreler

| Sembol | Tanım | Hesap | Sonuç |
|---|---|---|---|
| d | Son hane | 500123002**1** | 1 |
| D2 | Son iki hane | 50012300**21** | 21 |
| S | Hane toplamı | 5+0+0+1+2+3+0+0+2+1 | 14 |
| N | 24 + (D2 mod 25) | 24 + (21 mod 25) = 24 + 21 | 45 |
| Cache | d = 1 satırı | tablodan | 128 B / 16 B line / 2-way set-assoc. / 8 line / 4 set |
| Write policy | d tek → write-through | d = 1 tek | write-through |
| k | (S mod 7) + 3 | (14 mod 7) + 3 = 0 + 3 | 3 |
| Interrupt türü | S çift → Timer | S = 14 çift | Timer |
| f | 1.0 + 0.1 × d GHz | 1.0 + 0.1 × 1 | 1.1 GHz (varsayım) |
| T1 / T2 | T2 = 20 + 5 × (d mod 4) | 20 + 5 × 1 | T1 = 1 cycle, T2 = 25 cycle (varsayım) |
| Nc | 2 + (S mod 7) | 2 + 0 | 2 (varsayım) |
| Görev parametresi | SID çift → artan, tek → azalan | 5001230021 > 2³¹ − 1 = 2 147 483 647 → son 9 hane 001230021 = 1 230 021; tek | Azalan sıralama |

Adres alanları (32-bit adres, set-associative):

| Alan | Bit | Hesap |
|---|---|---|
| Word (w) | 4 | line = 16 B = 2⁴ |
| Set (d) | 2 | 8 line / 2 way = 4 set = 2² |
| Tag (s − d) | 26 | 32 − 4 − 2 |
| Toplam | 32 | 26 + 2 + 4 |

## 1.1 Görev seçimi

☒ G4 Sıralama ve medyan

## 1.2 Çözüm tasarımı

Girdi dizisi `generate()` içinde SID ile tohumlanan LCG'den üretilir ve 45 elemanlı global `data[]` dizisine yazılır. Sıralama için O(N²) bubble sort seçildi; her karşılaştırma `out_of_order(a, b, desc)` fonksiyonuna yapılan bir çağrıdır, böylece her iç döngü iterasyonu load, store, koşullu branch, call ve return içerir ve izlenecek kernel kolayca seçilir. Sıralama yönü `SID & 1` ile belirlenir (SID tek → azalan). Sıralamadan sonra `stats()` diziyi bir kez daha geçerek min ve max'ı bulur, medyanı (N − 1)/2 = 22 indisinden okur. Tüm sonuçlar global değişkenlerde tutulur; dizi ve sonuçlar `.data/.bss` bölümünde, kod `.text` bölümünde aynı adres uzayındadır.

## 1.3 C kaynak kodu

Dosya: `src/main.c` (59 satır).

```c
 1  #define N 45
 2
 3  const int SID = 1230021;
 4
 5  int data[N];
 6  int median, min_v, max_v, swaps;
 7
 8  unsigned int lcg_next(unsigned int x)
 9  {
10      return 1664525u * x + 1013904223u;
11  }
12
13  int out_of_order(int a, int b, int desc)
14  {
15      if (desc)
16          return a < b;
17      return a > b;
18  }
19
20  void generate(void)
21  {
22      unsigned int x = (unsigned int)SID;
23      for (int i = 0; i < N; i++) {
24          x = lcg_next(x);
25          data[i] = (int)((x >> 16) % 1000u);
26      }
27  }
28
29  void sort(int desc)
30  {
31      for (int pass = 0; pass < N - 1; pass++)
32          for (int j = 0; j < N - 1 - pass; j++)
33              if (out_of_order(data[j], data[j + 1], desc)) {
34                  int t = data[j];
35                  data[j] = data[j + 1];
36                  data[j + 1] = t;
37                  swaps++;
38              }
39  }
40
41  void stats(void)
42  {
43      min_v = max_v = data[0];
44      for (int i = 1; i < N; i++) {
45          if (data[i] < min_v)
46              min_v = data[i];
47          if (data[i] > max_v)
48              max_v = data[i];
49      }
50      median = data[(N - 1) / 2];
51  }
52
53  int main(void)
54  {
55      generate();
56      sort(SID & 1);
57      stats();
58      return 0;
59  }
```

## 1.4 Zorunlu yapı eşlemesi

| # | Zorunlu yapı | Satır | Açıklama |
|---|---|---|---|
| Y1 | N elemanlı global dizi, en az iki geçiş | 5, 23–26, 31–38, 44–49 | `data[45]` önce üretilir, sonra bubble sort ile 44 kez, sonra min/max için bir kez daha geçilir. |
| Y2 | Koşullu dallanma | 15, 33, 45, 47 | `if (desc)`, swap kararı ve min/max karşılaştırmaları. |
| Y3 | Parametreli, değer döndüren fonksiyon | 13–18, 33 (ayrıca 8–11, 24) | `out_of_order(a, b, desc)` üç parametre alır, 0/1 döndürür; her karşılaştırmada çağrılır. |
| Y4 | Toplama, çarpma/shift, bit işlemi | 10, 25, 56 | `1664525u * x + 1013904223u` (çarpma + toplama), `x >> 16` (shift), `% 1000u` (remu), `SID & 1` (AND). |
| Y5 | Dizi elemanına store | 25, 35, 36 | Üretimde ve her takasta `data[]` yazılır. |
| Y6 | `const int SID` ve hesapta kullanımı | 3, 22, 56 | SID LCG tohumudur ve sıralama yönünü belirler; tüm çıktılar SID'e bağlıdır. |
| Y7 | Sonuç global değişkenlerde | 6, 37, 43, 46, 48, 50 | `median`, `min_v`, `max_v`, `swaps`. |

## 1.5 Program çıktıları

RV32IM `-O0` ELF'i (`build/main_O0.elf`) çalıştırıldıktan sonra bellekten okunan değerler. Aynı değerler `-O1`, yerel derleme ve bağımsız Python modeli (`tools/reference.py`) ile de elde edildi.

| Global değişken | Adres (hex) | Değer | Ekran görüntüsü |
|---|---|---|---|
| median | 0x000113EC | 472 | screenshots/outputs_ripes.png (eklenecek) |
| min_v | 0x000113F0 | 21 | aynı |
| max_v | 0x000113F4 | 988 | aynı |
| swaps | 0x000113F8 | 457 | aynı |

Diğer adresler: `SID` 0x000113E8 (.sdata), `data[0]` 0x000113FC … `data[44]` 0x000114AC (.bss), `.text` 0x00010000–0x000103E7.

Üretilen girdi: 190, 378, 470, 701, 470, 236, 945, 457, 749, 526, 175, 729, 516, 988, 456, 87, 654, 923, 467, 855, 873, 451, 984, 21, 223, 815, 712, 396, 140, 658, 472, 265, 498, 260, 659, 639, 731, 124, 95, 491, 455, 440, 531, 593, 383

Azalan sıralı: 988, 984, 945, 923, 873, 855, 815, 749, 731, 729, 712, 701, 659, 658, 654, 639, 593, 531, 526, 516, 498, 491, **472**, 470, 470, 467, 457, 456, 455, 451, 440, 396, 383, 378, 265, 260, 236, 223, 190, 175, 140, 124, 95, 87, 21

## 1.6 İzlenecek kernel

`-O0` derlemesindeki `out_of_order` çağrısı ve dönüşü. `-O1`'de bu fonksiyon `sort` içine inline edildiği için call/return yalnızca `-O0`'da görünür; kernel bu yüzden `-O0` listesinden seçildi.

| Alan | Değer |
|---|---|
| C satır aralığı | 33 (çağrı) ve 13–18 (`out_of_order` gövdesi ve dönüşü) |
| Başlangıç ve bitiş adresi (hex) | 0x000101BC (`jal x1, out_of_order`) → 0x000100B4 (`jalr x0, 0(x1)`); dönüş 0x000101C0'a |
| Dinamik instruction sayısı | 20 (programdaki 1955.–1974. instruction) |
| Hangi döngü iterasyonu | `sort` ilk çağrı: pass = 0, j = 0; a = data[0] = 190, b = data[1] = 378, desc = 1 → 190 < 378, sonuç 1 (takas yapılacak) |
| İçerik | 5 load, 5 store, 6 ALU (addi, slt, andi), 1 koşullu branch (`beq`, alınmadı), 1 call (`jal`), 1 jump (`jal x0`), 1 return (`jalr`) |

| # | Adres | Machine code | Assembly | C satırı |
|---|---|---|---|---|
| 1 | 0x101BC | 0xEA1FF0EF | jal x1, 0x1005C | 33 |
| 2 | 0x1005C | 0xFE010113 | addi x2, x2, -32 | 14 |
| 3 | 0x10060 | 0x00112E23 | sw x1, 28(x2) | 14 |
| 4 | 0x10064 | 0x00812C23 | sw x8, 24(x2) | 14 |
| 5 | 0x10068 | 0x02010413 | addi x8, x2, 32 | 14 |
| 6 | 0x1006C | 0xFEA42623 | sw x10, -20(x8) | 14 |
| 7 | 0x10070 | 0xFEB42423 | sw x11, -24(x8) | 14 |
| 8 | 0x10074 | 0xFEC42223 | sw x12, -28(x8) | 14 |
| 9 | 0x10078 | 0xFE442783 | lw x15, -28(x8) | 15 |
| 10 | 0x1007C | 0x00078C63 | beq x15, x0, 0x10094 | 15 |
| 11 | 0x10080 | 0xFEC42703 | lw x14, -20(x8) | 16 |
| 12 | 0x10084 | 0xFE842783 | lw x15, -24(x8) | 16 |
| 13 | 0x10088 | 0x00F727B3 | slt x15, x14, x15 | 16 |
| 14 | 0x1008C | 0x0FF7F793 | andi x15, x15, 255 | 16 |
| 15 | 0x10090 | 0x0140006F | jal x0, 0x100A4 | 16 |
| 16 | 0x100A4 | 0x00078513 | addi x10, x15, 0 | 18 |
| 17 | 0x100A8 | 0x01C12083 | lw x1, 28(x2) | 18 |
| 18 | 0x100AC | 0x01812403 | lw x8, 24(x2) | 18 |
| 19 | 0x100B0 | 0x02010113 | addi x2, x2, 32 | 18 |
| 20 | 0x100B4 | 0x00008067 | jalr x0, 0(x1) | 18 |

Not: k = 3 olduğundan Timer interrupt'ı 3. instruction (`sw x1, 28(x2)`, 0x10060) execute edilirken gelir; kaydedilecek PC 0x10064 olur.

## Seçilen ISA ve gerekçesi

RV32IM: sabit 32-bit instruction uzunluğu elle kodlamayı düzenli kılar; R, I, S, B, U, J formatları tüm zorunlu instruction'ları (lui/addi, beq/blt, lw, sw, jal) kapsar. `M` uzantısı `mul` ve `remu`'yu donanım instruction'ı yapar; yalnız RV32I çarpmayı kütüphane çağrısına çevirip Y4 ile çelişirdi. SID = 1 230 021 = 0x0012C4C5 tek bir 12-bit immediate'e sığmaz, bu yüzden `lui + addi` çiftiyle yüklenir: alt 12 bit 0x4C5 (bit 11 = 0, pozitif), dolayısıyla üst 20 bit için +1 düzeltme gerekmez, `lui 0x12C` + `addi 0x4C5`. Derleyici de tam olarak bunu üretti: 0x100C8 `lui x15, 0x12C` (0x0012C7B7) ve 0x100CC `addi x15, x15, 1221` (0x4C578793).
