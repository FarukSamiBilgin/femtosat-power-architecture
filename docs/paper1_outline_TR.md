# Konferans Bildirisi İskeleti — v2 (Tutarlı, Enerji-Bankalama Çerçevesi)

**Sistem (senin tasarımın):** RTG sürekli taban → çok-kaynaklı harvester katmanları → **hibrit depolama tamponu (pil + süperkapasitör)** → ikili topoloji: **flyback** (görev yokken uyku/hayatta-kalma) + **boost** (pik görev anları: lazer/comms, sensör, manevra).

**Tezin tek cümlesi:**
> Çok-kaynaklı *fırsatçı* enerji toplama + hibrit depolama + flyback/boost ikili topolojisi, mevcut her enerji kıvılcımını ortak bir tampona bankalayarak, sabit RTG-tabanlı bir sisteme göre **pik-görev sıklığını (duty-cycle) ve hata-toleransını** artırır.

**Kilit kavramsal kayma:** Metrik *anlık güç (P)* değil, **biriken enerji (∫P·dt)** ve onun açtığı **görev sıklığı**. Bu kayma, "10 mW nerede?" sorusunu tamamen ortadan kaldırır ve piezo/tribo/RF'nin µW'larını kusur olmaktan çıkarıp tasarımın amacı yapar.

> `[SİM]` = kendi PSIM/MATLAB sonucunla değiştir. Bildiride **tek** güç modeli kullan.

---

## 1. Başlık (öneri)
*A Multi-Source Energy-Banking Power Architecture for Coin-Sized Photon-Sail Nanosatellites: Per-Source MPPT and Flyback/Boost Dual-Mode Conversion*

---

## 2. Abstract (taslak, İngilizce ~190 kelime)

> Coin-sized photon-sail nanosatellites face an extreme power problem: a sub-milliwatt sleep budget, peak loads (laser communication, sensing) an order of magnitude higher, and a multi-decade mission spanning full solar illumination to deep-space darkness. We present a multi-source *energy-banking* power architecture for a 3×3 cm femtosatellite. A radioisotope thermoelectric generator provides the continuous baseline; a surface-integrated harvesting stack (triple-junction photovoltaic and a Bi₂Te₃/Sb₂Te₃ thermoelectric layer driven by the residual RTG-to-space gradient, plus opportunistic piezoelectric, triboelectric, and RF mechanisms) feeds a common hybrid supercapacitor/battery buffer. Each source is interfaced through a dedicated front-end and maximum-power-point-tracking stage, then combined in the power domain—avoiding the impedance mismatch that series-connecting heterogeneous sources would impose. A dual-mode converter delivers peak loads via a boost stage from the buffer and sustains survival operation via a flyback stage. Rather than reporting instantaneous power, we evaluate banked energy and the resulting peak-event cadence. Simulation [SİM] shows the architecture captures sources spanning roughly five orders of magnitude of power onto one buffer and improves cruise-phase mission cadence by [X]% over an RTG-only baseline.

**Index Terms** — energy harvesting, energy banking, MPPT, nanosatellite power management, thermoelectric, flyback, boost converter, deep space.

---

## 3. Sistem Mimarisi — Tek Doğru Anlatım (Bölüm IV'ün özü)

Akış zinciri (bildirideki ana şekil, Fig. 3):

```
[RTG] ─────────────┐
[PV katmanı] ──MPPT─┤
[TE katmanı] ──MPPT─┼──► ORTAK GÜÇ DÜZLEMİ ──► [Hibrit tampon: süperkap + pil]
[Piezo] ───────MPPT─┤                                  │
[Tribo] ───────MPPT─┤                          ┌───────┴────────┐
[RF] ──────────MPPT─┘                          ▼                ▼
                                          [FLYBACK]         [BOOST]
                                       uyku/survival      pik/görev
                                          (3.3V)        (comms/lazer)
```

**İki teknik hata burada düzeltiliyor:**
1. **Seri bağlantı / 18 V iddiası SİLİNDİ.** Akımları 5 mertebe farklı kaynaklar (mW PV ↔ pA RF) seri bağlanamaz; en zayıf akım hepsini kilitler. Doğrusu: *her kaynak kendi MPPT'siyle ayrı, sonra **paralel güç-düzleminde** tamponda birleşir.* Bu zaten "her kaynak için ayrı optimal yük" tablonla tutarlı.
2. **TE ↔ RTG çift-sayımı:** TE harvester, RTG'nin soğuk tarafa **reddettiği** ısı akısının bir kısmından geri kazanım olarak modellenir; ortak ısı-akısı bütçesi verilir. Yoksa aynı enerjiyi iki kez sayarsın.

---

## 4. Enerji-Bankalama Argümanı (bildirinin kalbi — Bölüm II + V)

Anlık güç yerine "kova doldurma" mantığı:

- **Comms kovası:** ~22 mW × ~2 s ≈ **44 mJ** (bir veri patlaması için gereken enerji).
- **RTG tek başına** (seyir, net fazla ≈ 7.5 − 0.41 ≈ 7.1 mW): bu kovayı **~6 s**'de doldurur. Yani RTG zaten ana iş gücü — bunu dürüstçe söyle.
- **Harvester'ın marjinal katkısı görev evresine bağlı:**
  - Derin seyir: yalnız TE sızıntısı (~0.2–0.3 mW) → kova dolum süresi ~6.0 s'ye iner (küçük ama sürekli).
  - Yıldız/yer-yakını: PV (+0.5 mW) + diğerleri devrede → dolum belirgin hızlanır; ana panel zaten baskın.

**Bu yüzden harvester'ın savunulabilir üç değeri (overclaim YOK):**
1. **Enerji-zengin evrelerde görev sıklığını artırma** — kova daha hızlı dolunca daha sık comms/science penceresi.
2. **Hata-toleransı / zarif bozulma** — 20 yılda RTG degradasyonunda veya arızada bağımsız bankalama yolları kalır.
3. **Mimari yetenek** — *5 mertebe güç çeşitliliğini* (mW→nW) tek tampona, kaynaklar birbirini yüklemeden bankalayan birleşik PMU. Asıl yenilik bu; harvester watt'ları ikincil.

→ Lider metrik: **"pik-olay sıklığı / kullanılabilirlik, RTG-only tabana göre %X"** — "kaç mW" değil.

---

## 5. IEEE Bölüm Yapısı (4–6 sayfa)

- **I. Introduction (~0.75 s):** photon-sail femtosat güç problemi; uyku↔pik uçurumu; tek-kaynağın evreler arası yetersizliği. Katkılar (3): (1) enerji-bankalama PMU, (2) kaynak-başına MPPT + paralel birleştirme, (3) flyback/boost görev-modu mantığı + kaynak tahkimi.
- **II. Mission & Load Context (~0.5 s):** güç bütçe tablosu (uyku 0.10 mW → comms 22 mW → pik 29 mW); evreler ve kaynak erişilebilirliği; "kova" kavramının tanımı.
- **III. Harvesting Sources (~1.25 s):** PV (CsPbBr₃ / üçlü-eklem), TE (Bi₂Te₃/Sb₂Te₃, **ortak ısı bütçesi**, ZT konservatif + duyarlılık), ve tek paragraf "opportunistic: piezo/tribo/RF, <10 µW, derin uzayda ihmal, bankalama girdisi."
- **IV. Power Management Architecture (~1.25 s) — ANA KATKI:** Fig. 3 blok şema; MPPT eşleştirme tablosu; flyback/boost mod geçişi; kaynak tahkim FSM.
- **V. Simulation & Results (~1 s):** dönüştürücü verimi, MPPT yakınsama, **evre-bazlı bankalanmış enerji + pik-olay sıklığı**, RTG-only kıyas, termal kararlılık (−50…+80 °C). [SİM]
- **VI. Conclusion & Future Work (~0.25 s):** mimari taşınabilir; piezo/tribo/RF gelecekte daha yüksek TRL'de tak-çalıştır banka girdisi.

---

## 6. Düzeltilen Teknik Hatalar (hepsi v2'de kapatıldı)

| # | Eski hata | v2 düzeltmesi |
|---|---|---|
| 1 | Seri bağlantı, V=18 V, akım RF ile sınırlı | Paralel güç-düzlemi + kaynak-başına MPPT |
| 2 | Üç çelişen toplam (10 / 1.25 mW / µW) | Tek model; metrik = bankalanmış enerji, watt değil |
| 3 | TE ile RTG aynı ısıyı sayıyor | Ortak ısı-akısı bütçesi (reddedilen ısıdan geri kazanım) |
| 4 | Yüzey 54 cm² (oysa 3×3×1 → 30 cm²) | Geometri 30 cm²; güç buna ölçeklendi |
| 5 | Piezo: PZT/d₃₃=400 ↔ ZnO/d₃₃=12.4 | Tek malzeme seç ve tutarlı kullan |
| 6 | "PbBr₄ perovskit" | CsPbBr₃ (ABX₃) |
| 7 | Piezo 90-dk termal çevrim = LEO varsayımı | Yıldızlararası bağlamda kaldırıldı/yeniden modellendi |
| 8 | RF'yi derin uzayda gerçek kaynak gibi sunmak | Opportunistic + kT gürültü tabanı sınırı açıkça belirtildi |
| 9 | PV 150 µW/cm² ↔ 17.9 mW/cm² (100×) | Tek değer + koşul etiketi |

---

## 7. Beklenen Hakem İtirazları + Cevaplar

- **"Harvester gücü RTG yanında ihmal edilebilir."** → Doğru; iddiamız watt değil. Metrik bankalanmış enerji ve pik-olay sıklığı; ayrıca redundans ve 5-mertebe kaynak çeşitliliğini tek tamponda toplayan mimari.
- **"10 mW nerede?"** → O sayı yalnızca 1 AU + ideal pikti; her değer evreye etiketlendi. Bildiri performans değil mimari iddia ediyor.
- **"Tribo/RF uzayda çalışmaz / kT altı."** → Aynen; bütçeye konmadı, opportunistic banka girdisi olarak <10 µW karakterize edildi.
- **"ZT=2.84 gerçekçi değil."** → Konservatif ZT=[1.5–2.0] ile duyarlılık verildi; sonuç ZT'ye değil mimariye dayanıyor.
- **"Seri 18 V iddiası?"** → Kaldırıldı; paralel + MPPT.

---

## 8. Şekil/Tablo Listesi

- Fig. 1 — Görev evreleri + kaynak erişilebilirliği zaman çizelgesi
- Fig. 2 — Katman yığını (PV/TE öne çıkar; piezo/tribo/RF soluk)
- **Fig. 3 — Enerji-bankalama PMU blok şeması (ana şekil)**
- Fig. 4 — Kaynak tahkim + flyback/boost mod-geçiş FSM
- Fig. 5 — Bankalanmış enerji & pik-olay sıklığı, RTG-only kıyas [SİM]
- Tablo I — Tek tutarlı güç modeli (evre bazlı)
- Tablo II — MPPT eşleştirme (kaynak / algoritma / optimal yük)
- Tablo III — ZT duyarlılık analizi

> Mermaid dosyandaki PMU/güç-akış şemaları Fig. 3–4 için yeniden çizilebilir.
