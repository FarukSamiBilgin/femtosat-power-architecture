# Laser-Sail Güç Sistemi — İki Tam Versiyon, Yan Yana Kıyas

Her iki versiyon da aynı laser-sail platformu üzerine, kurduğumuz tutarlı modele göre (kaynak-başına MPPT + paralel güç düzlemi + mW etiketleri) sıfırdan kuruldu. Tüm sayılar doğrulanmış hesaptan gelir. Amaç: kıyaslayıp seçmen.

---

## 0. Ortak platform (her iki versiyonda aynı)

| Büyüklük | Değer |
|---|---|
| Çip gövdesi | 3×3×1 cm, 30 cm² yüzey |
| Yelken | ~4 m², ~0.4 g/m² → 1.6 g |
| Çip + yük | 0.30 g |
| **Taban kütle (kaynaksız)** | **1.90 g → 0.200c, 22 yıl** |
| Yüzey tahsisi | PV 9 cm² (güneş yüzü) · radyatör 12 cm² · comms+sensör 9 cm² |
| PV modeli | 18% × 9 cm² × 1361/d² → **220 mW @1 AU**, 5.4 AU'da taban-altı, 47 AU'da uyku-altı |
| Comms kovası | 22.3 mW × 2 s = **44.6 mJ** |
| Yük aralığı | uyku 0.10 mW … pik 29.1 mW (**2.46 mertebe**) |

**Kütle→hız yasası:** son hız ≈ taban_kütle / toplam_kütle × 0.200c. Taşıdığın her gram doğrudan hızdan düşer. İki versiyonun tek temel farkı budur (bkz. `AB_comparison.png`, sol panel).

---

# VERSİYON A — Maksimum Hız (termal RTG yok)

**Felsefe:** Hiçbir gram boşa gitmez; sürekli güç yerine *bankalanmış* güçle yaşa. Starshot'ın gerçek baseline'ı. **Bu versiyonda enerji-bankalama tezi gerçekten yük taşır** — nadir enerji-zengin pencereleri (lazer-itme, güneşe yakınlık, flyby) bankalayıp aradaki 20 yılı µW keep-alive ile geçirirsin.

**Kütle / hız:** 1.90 + 0.03 g (betavoltaik) = **1.93 g → 0.197c → 22 yıl.** Hız cezası ≈ %1.5 (ihmal).

### Kaynak yığını
```
                                         GÜÇ
[Lazer-itme yaması] ─ MPPT ─►  termal-sınırlı, kısa  ─┐  (depo→FULL, sonra fazlası yansıtılır)
[PV 9 cm²] ─────────  MPPT ─►  0…220 mW (mesafeye)   ─┼─► PARALEL GÜÇ DÜZLEMİ ─► [süperkap 28 mF ∥ küçük pil]
[Betavoltaik ~30 mg] ──────►  ~3 µW SÜREKLİ          ─┘            │
                                                          ┌────────┴────────┐
                                                          ▼                 ▼
                                                   [düşük-Iq buck-boost]  [BOOST]
                                                    3.3 V hayatta-kalma   pik (comms/sensör)
```

### Faz-bazlı güç bütçesi
| Faz | Süre | Kaynak | Mod |
|---|---|---|---|
| Lazer-itme (~1 AU) | ~10 dk | PV 220 mW + itme-yaması (termal-sınırlı) | **Termal hayatta-kalma**; depo→%100 |
| Güneşe yakın seyir | haftalar | PV 220→9 mW | Agresif bankalama + **erken bilim** |
| **Derin seyir** | **~20 yıl** | **betavoltaik ~3 µW** | **DORMANT** — RTC+SRAM+uyanma sayacı; gerisi kapalı |
| Hedef flyby | gün/hafta | PV ~220 mW (yelken konsantratör) | **Soğuk-başlatma → patlama bilim + comms** |

### Derin seyirde "ölü değil, uyuyor"
Betavoltaik günde ~259 mJ bankalar → ~**52 sensör okuması/gün** (manyetometre/parçacık sayıcı, 5 mJ/okuma) mümkün. Yani ultra-düşük-duty bilim sürer, sürekli işlem yok.

### Kontrol
Derin-uyku FSM. Uyanma tetikleyicileri: zamanlayıcı · PV-algılandı (yıldıza yaklaşım) · anomali. Sürekli AI döngüsü **yok**; MPPT yalnız PV aktifken çalışır. Denetçi ~birkaç düzine bayt.

### Avantaj / Risk
- ✅ En yüksek hız (0.197c), en kısa transit (22 yıl)
- ✅ **20 yıl pil şarj-tutma gerekmez** (flyby'da PV ile soğuk-başlatma) → depolama güvenilirliği büyük kazanç
- ✅ Nükleer/fırlatma onayı minimal (sadece küçük betavoltaik)
- ⚠️ Derin seyirde sürekli bilim yok (sadece ultra-düşük-duty örnekleme)
- ⚠️ Lazer-itme termal darbesinden sağ çıkmak kritik; 20 yıl soğuk-hayatta-kalma + flyby soğuk-başlatma riski
- ⚠️ Betavoltaik düşük TRL (etkinleştirici ama olgunlaşmamış bileşen)

---

# VERSİYON B — Sürekli Bilim (Pu-238 150 mg RTG)

**Felsefe:** Hızdan feragat et, görev boyunca sürekli güç + sürekli bilim al. Burada RTG domine eder; **harvester'ın asıl değeri throughput değil, yedeklilik ve zarif bozulmadır** (geçen adımdaki büyük bulgu burada geçerli).

**Kütle / hız:** 1.90 + 0.75 g (Pu-238 + montaj) = **2.65 g → 0.143c → 30 yıl.** A'ya göre **%27 daha yavaş.**

### Kaynak yığını
```
[RADYOİZOTOP 81 mW_ısıl]
   ├─ RTG dönüştürücü (ZT 0.7) ───────────► 4.38 mW ┐
   └─ ret-ısı 76.6 mW → TE geri-kazanım(ZT1.25) ►+2.11 mW┤  = 6.49 mW SÜREKLİ (her faz)
[PV 9 cm²] ───────────── MPPT ─► 0…220 mW (mesafeye) ─┼─► PARALEL DÜZLEM ─► [süperkap ∥ pil]
                                                       ┘            │
                                                          ┌─────────┴────────┐
                                                          ▼                  ▼
                                                   [düşük-Iq buck-boost]   [BOOST]
                                                    3.3 V hayatta-kalma    pik
```

### Faz-bazlı güç bütçesi
| Faz | Kaynak | Mod |
|---|---|---|
| Güneşe yakın (1 AU) | PV 220 + RTG/TE 6.5 = **227 mW** | Bol güç, yüksek-duty bilim |
| **Derin seyir (~20 yıl)** | **RTG/TE 5.7 mW** (uyku marjı **×57**) | **SÜREKLİ işlem**; comms kovası 8.2 s'de dolar |
| Hedef flyby | PV 220 + RTG/TE 6.5 mW | Yüksek-duty bilim + comms |

EoL (20 yıl): Pu-238 %15 bozunur → RTG/TE 6.5 → **5.5 mW**. TE geri-kazanım katmanı bozulmayı kısmen telafi eder; RTG tamamen arızalansa bile TE-only > uyku → hayatta.

### Kontrol
Faz FSM + **çizelgeli PID/histeretik** (4-kontrolcü AI bankası DEĞİL). Radyasyon/sıcaklık → yavaş-zaman derating tablosu; NN bütçesi varsa **görev otonomisine** (FDIR, flyby hedef yakalama) gider.

### Avantaj / Risk
- ✅ Görev boyunca sürekli güç + sürekli bilim
- ✅ RTG atık ısısı elektroniği/pili derin uzayda sıcak tutar (termal bonus)
- ✅ İki bağımsız bankalama yolu → tek-nokta arıza toleransı
- ⚠️ **%27 daha yavaş** (0.143c, 30 yıl)
- ⚠️ Pil 20-30 yıl sürekli çevrimde → katı-hal şart, güvenilirlik kaygısı
- ⚠️ Pu-238 kıt + pahalı + nükleer fırlatma onayı; binlerce çip için program-düzeyi sorun

---

## Yan yana karar tablosu

| Eksen | **A: Maksimum hız** | **B: Sürekli bilim** |
|---|---|---|
| Son hız | **0.197c** | 0.143c |
| Transit (Alpha Cen) | **22 yıl** | 30 yıl |
| Toplam kütle | **1.93 g** | 2.65 g |
| Derin-seyir gücü | ~3 µW (dormant) | **5.7 mW (sürekli)** |
| Seyirde bilim | ultra-düşük-duty (~52 okuma/gün) | **sürekli** |
| Depolama 20yıl güvenilirliği | **kolay** (soğuk-başlatma) | zor (sürekli çevrim) |
| Termal | pasif; itme-darbesi kritik | **RTG ısıtır (bonus)** |
| Nükleer onay / maliyet | **minimal** | Pu-238 (kıt, onay) |
| Kontrol | derin FSM, olay-uyanma | faz FSM + çizelgeli PID |
| Enerji-bankalama tezi | **yük taşır (asıl fikir)** | önemsiz (RTG domine) |
| Ana risk | 20yıl soğuk-hayatta-kalma + soğuk-başlatma | kütle/hız cezası + pil ömrü |
| Bilim getirisi | flyby'da yoğunlaşmış | dağıtık + flyby |

## Hangisini ne zaman seç
- **Görevin amacı "en hızlı varış + flyby bilimi" ise → A.** Fizik ve Starshot felsefesi bunu destekler; bonus olarak makalenin enerji-bankalama tezi burada gerçekten merkezî hâle gelir.
- **"Yol boyunca sürekli ölçüm (yıldızlararası ortam, parçacık, manyetik alan profili)" pazarlanabilir bir bilim hedefi ise → B.** %27 hız bedelini ödersin ama geçen adımdaki RTG+TE yedeklilik hikâyesi tam burada parlar.

İkisi de mimari olarak aynı omurgayı (per-source MPPT + paralel düzlem + buck-boost/boost + FSM) paylaşır; fark yalnızca **derin-seyir kaynağı** (betavoltaik µW ↔ RTG/TE mW) ve onun getirdiği kütle/hız/bilim üçlü dengesidir. Seçtiğinde, o versiyonu tam IEEE bölümleri + şekiller + güç bütçe tablolarıyla detaylandırırım.
