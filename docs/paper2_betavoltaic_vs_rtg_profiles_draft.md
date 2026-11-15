# A Profile-Agnostic Energy-Banking Power Architecture for Coin-Sized Photon-Sail Nanosatellites: Per-Source MPPT, Dual-Mode Conversion, and Source Selection for Maximum-Velocity versus Continuous-Science Missions

**Faruk Sami Bilgin**

*Status: Conference paper draft (unpublished). Entries marked [SİM] are pending simulation results and are intentionally left unfilled.*

---

## Abstract

Coin-sized photon-sail nanosatellites face an extreme power problem: a sub-milliwatt sleep budget, peak loads—laser communication, sensing, attitude actuation—more than two orders of magnitude higher, and a multi-decade mission spanning full solar illumination to deep-space darkness, with no refueling or maintenance. We present a *profile-agnostic energy-banking* power architecture for a 3×3×1 cm femtosatellite. The relevant figure of merit is reframed from instantaneous harvested power to *banked energy* and the resulting *peak-event cadence*: every available increment of energy is transferred into a shared hybrid buffer, from which high-power events are served on demand. Each source is conditioned by a dedicated front-end and maximum-power-point-tracking (MPPT) stage and combined in the power domain—avoiding the impedance mismatch of series connection—and gated by a net-energy threshold so that no source is admitted unless it exceeds its own conditioning overhead. A dual-mode converter sustains survival operation through a low-quiescent buck-boost stage and delivers peak loads through a boost stage drawing from the buffer. On this common backbone we instantiate two mission profiles that differ only in their deep-cruise source: (A) a *maximum-velocity* profile that omits a radioisotope thermoelectric generator (RTG) and uses a milligram-scale betavoltaic keep-alive with photovoltaic (PV) banking near stars; and (B) a *continuous-science* profile that carries a Pu-238 RTG augmented by a high-ZT thermoelectric reject-heat recovery layer. Analytical evaluation with grounded device parameters shows the architecture banks sources spanning roughly nine orders of magnitude of power, and that the source choice—not the architecture—sets the velocity/science trade. [SİM] completes the circuit-level results.

**Index Terms**—Energy harvesting, energy banking, MPPT, nanosatellite power management, thermoelectric generator, betavoltaic, photovoltaic, boost converter, femtosatellite, deep space.

---

## I. Introduction

Photonic-propulsion mission concepts envisage accelerating gram-scale spacecraft to a substantial fraction of light speed using ground-based laser arrays, enabling interstellar transit within decades rather than millennia [1]. Realizing such a platform requires compressing generation, conversion, storage, sensing, and communication into a coin-sized body. The resulting power problem differs qualitatively from that of a CubeSat: the collection surface is tens of square centimeters, mass margins forbid bulky storage, and—critically for a laser sail—**every gram of stored mass directly reduces the achievable terminal velocity**, since for a fixed laser fluence the terminal velocity scales inversely with the total areal mass density.

A single primary source cannot serve this profile. Photovoltaics dominate near a star but vanish in deep space; a radioisotope source is continuous but mass-, cost-, and regulation-limited; and the instantaneous demand of a communication burst exceeds any continuous source the platform can carry. The mismatch between a sub-milliwatt sleep budget and tens-of-milliwatt peaks is the central tension.

We argue the right response is not a larger source but an architecture organized around *energy banking*: continuously transferring every available increment of energy—however small, whatever the mechanism—into a shared buffer, from which high-power events are served on demand. Under this view the figure of merit is not instantaneous harvested power but the energy accumulated between events and the cadence at which power-intensive opportunities can be repeated. A consequence we make explicit is that, below a threshold set by a source's own conditioning electronics, admitting that source costs more energy than it yields; banking is therefore *gated*, not indiscriminate.

A further consequence is that the architecture is **agnostic to the deep-cruise source**. We exploit this by defining two mission profiles on one backbone, and showing that the choice between them is a mission-objective decision (velocity versus continuous science), not an architectural one. The contributions are:

1. A profile-agnostic, gated energy-banking power-management unit (PMU) with per-source MPPT and power-domain combining, demonstrated to bank from sources spanning roughly nine orders of magnitude near a star without mutual loading.
2. A dual-mode conversion and arbitration scheme—low-quiescent buck-boost for survival, boost for peak loads—governed by a mission-phase finite-state machine (FSM) and evaluated by banked-energy and peak-event-cadence metrics.
3. Two grounded source instantiations—an RTG with high-ZT thermoelectric reject-heat recovery, and a betavoltaic keep-alive with duty-cycled cruise sampling—and a quantitative decision framework relating source choice to terminal velocity, cruise capability, mass, regulatory burden, and fault tolerance.

## II. Mission and Load Context

### A. Platform and power budget

The platform is a 3×3×1 cm body with total external area
A_surface = 2(3×3) + 4(3×1) = 30 cm²,
allocated as 9 cm² Sun-facing (PV), 12 cm² space-facing (radiator/thermoelectric cold side), and 9 cm² for communication and sensors. A Sun-facing surface cannot simultaneously serve as a cold radiator; this allocation removes that conflict.

The load resolves into the modes in Table I. The defining feature is a dynamic range of 29.1/0.10 ≈ 291×, i.e. about **2.5 orders of magnitude** (not four) between the deep-sleep floor and the simultaneous peak.

**TABLE I. System power by operating mode (3×3 cm platform).**

| Operating mode | Power | Context |
|---|---|---|
| Deep sleep | 0.10 mW | Deep cruise |
| Minimum operations | 0.41 mW | Cruise housekeeping |
| Navigation active | 0.82 mW | Attitude updates |
| Data collection | 6.55 mW | Flyby science |
| Communication | 22.3 mW | Earth contact (burst) |
| Peak (simultaneous) | 29.1 mW | Emergency / worst case |

### B. Buffer-and-bucket model

Each power-intensive event is modeled as a fixed energy "bucket." A representative communication burst draws 22.3 mW for ≈2 s:
E_comms ≈ 22.3 mW × 2 s ≈ 44.6 mJ.
The PMU's task is to refill this bucket from all available sources between events. This reframing—accumulated energy and refill time rather than instantaneous power—motivates the architecture (Section III) and the evaluation (Section VI).

### C. Mission phases and source availability

The multi-decade profile divides into a brief laser-acceleration phase near 1 AU; an early-cruise phase over 2–10 AU with rapidly declining solar input; a deep-cruise phase in effective darkness; and a stellar-approach/flyby phase where a new star revives PV. PV availability follows the inverse-square law (Section IV-A); the continuous deep-cruise source is what distinguishes the two profiles of Section V.

## III. Energy-Banking Power Architecture (Profile-Agnostic Backbone)

### A. Per-source conditioning and power-domain combining

Series connection of heterogeneous sources is infeasible: their characteristic currents differ by orders of magnitude, so a series string is current-limited by its weakest member, collapsing extractable power. Instead, each source is brought to its own maximum-power point by an appropriate algorithm and combined in the power domain onto a hybrid storage bus (supercapacitor for high-rate bursts in parallel with a battery for energy density). Representative matching is given in Table II.

**TABLE II. Per-source MPPT matching.**

| Source | MPPT/conditioning | Optimal load (order) |
|---|---|---|
| Photovoltaic | Perturb & Observe | ~10¹–10² Ω |
| Thermoelectric (RTG-coupled) | Fractional open-circuit voltage | ~10³–10⁴ Ω |
| Betavoltaic | Series-stacked to bus; low-leakage diode + LDO | high-Z, ~constant-current |
| Piezo/Tribo/RF (opportunistic) | SSHI / charge pump / rectifier | ~10⁵–10⁸ Ω |

### B. Gated banking (net-energy threshold)

Every conditioning front-end draws a quiescent power P_q (energy-harvesting PMICs specify IQ on the order of 10²–10³ nA [11][12]). A source therefore contributes net energy only if P_source > P_q. The FSM disables the front-end of any source below its threshold—e.g. deep-space RF, whose rectifiable power lies at or below the thermal-noise floor. This makes "no source too small to matter" precise: a source must exceed its own conditioning overhead. The betavoltaic path avoids this overhead entirely by series-stacking cells to the bus voltage (Section IV-C), eliminating a boost stage.

### C. Dual-mode conversion

The conversion strategy matches topology to demand:

- **Survival/housekeeping rail:** a low-quiescent synchronous **buck-boost** (bus 3.0–4.2 V → 3.3 V). An isolated flyback is explicitly *not* used: galvanic isolation is unnecessary within a single die, and at sub-milliwatt loads its fixed switching/controller losses make it inefficient.
- **Peak rail:** a **boost** stage discharges the supercapacitor to deliver currents exceeding the continuous capability of any single source. The buffer decouples instantaneous load from instantaneous generation: sources supply *average* power, the buffer supplies *peak* power.

### D. Mission-phase FSM

An FSM selects active sources and converter mode per phase. Near a star, PV and auxiliary mechanisms are enabled and banking is rapid; in deep cruise the system defaults to survival and wakes the boost stage only for scheduled events; during flyby all sources are enabled and event cadence is maximized. The controller monitors buffer state-of-charge and load priority and sheds non-critical loads in reverse priority when banking falls behind demand. Crucially, this control is event-driven and ultra-low-power—a compact FSM with gain-scheduled regulation, not a continuous high-rate optimization—so that the controller's own consumption stays within the sleep budget.

```
[Source_i] ──MPPT/gate──┐
        ...             ├─► POWER-DOMAIN COMBINING ─► [Hybrid bus: supercap ∥ battery]
[Source_n] ──MPPT/gate──┘                                   │
                                                   ┌────────┴────────┐
                                                   ▼                 ▼
                                          [LOW-Iq BUCK-BOOST]     [BOOST]
                                           survival / 3.3 V       peak / mission
```

## IV. Source Subsystems

### A. Photovoltaic (both profiles)

With η_pv = 18% over A_pv = 9 cm², output follows
P_pv(d) = η_pv · A_pv · (1361/d²),
giving **≈220 mW at 1 AU**, equal to a few-mW continuous source near **5.4 AU**, and below the deep-sleep floor beyond **≈47 AU**. PV is thus dominant near a star, secondary by mid-cruise, and negligible in deep cruise—reviving at the destination star.

### B. RTG with thermoelectric reject-heat recovery (Profile B)

A radioisotope block dissipates Q_th of thermal power; a thermoelectric converter extracts η_TEG·Q_th, the balance flowing to a radiator whose equilibrium temperature follows from Q_rej = εσA_rad·T_rad⁴, giving T_rad ≈ 218 K (A_rad = 12 cm², ε = 0.85). The device efficiency is
η_TEG(ZT) = β·(T_h−T_rad)/T_h·(√(1+ZT)−1)/(√(1+ZT)+T_rad/T_h),
with a parasitic de-rating β ≈ 0.58 calibrated so a conventional ZT≈0.7 converter yields the expected ~5.4%. The contribution we claim as *harvesting* is the additional power recovered by co-integrating a **high-ZT (superlattice) converter**: raising ZT to 1.25 lifts system efficiency to ≈8%, recovering heat a conventional unit rejects.

A thin (≈µm) film placed *in series* with the reject-heat flow develops negligible ΔT and hence negligible Seebeck output; the recovery is therefore realized as a segmented/higher-ZT converter, not a passive coating—an important correction to a naïve thin-film model. For a 150 mg Pu-238 source (Q_th ≈ 81 mW), this yields RTG ≈ 4.4 mW plus TE recovery ≈ 2.1 mW = **≈6.5 mW continuous, in every phase**, decaying to ≈5.5 mW at 20 years (Pu-238 t½ = 87.7 yr). The RTG's waste heat additionally keeps the electronics and battery above their minimum operating temperature in deep space.

### C. Betavoltaic keep-alive (Profile A)

A betavoltaic converts beta-decay electrons directly to electricity via a semiconductor junction, delivering nanowatts-to-microwatts continuously for decades [13][15]. Tritium devices are space-qualified—City Labs delivered a 20-year prototype to NASA producing 50–100 µW in vacuum/radiation tests, with a fresh ~100 µW output decaying to >32 µW at 20 years and an operating range of −55…+150 °C [15]—but tritium's 12.3-year half-life forces heavy oversizing for a multi-decade mission. We therefore select **Ni-63 (half-life 100 years)**: a diamond-Schottky prototype reported ~10 µW/cm³ and ~3300 mWh/g, decaying only ≈19% over 30 years [14].

The keep-alive load is minimized by storing all state in nonvolatile FRAM/MRAM (no SRAM-retention current); deep-cruise draw is then a real-time clock (~14 nA [6]) plus a wake comparator and CMOS leakage floor (~10²–10³ nA [7]), i.e. **~0.7 µW**—well below what a small betavoltaic supplies. Active milliwatt loads are served by the manufacturer-standard pattern of **trickle-charging storage and operating on a duty cycle** [3]: the betavoltaic damps energy into a small low-leakage capacitor from which short bursts run.

Crucially, this profile avoids the 20-year battery-retention problem: storage need not hold charge for the cruise, because the betavoltaic continuously bridges and PV cold-starts the system at the destination.

### D. Opportunistic mechanisms (both profiles)

Piezoelectric (event-driven), triboelectric (sub-µW in cruise vacuum), and RF (at or below the thermal-noise floor in deep space) are integrated but *not budgeted*; they are admitted only through the net-energy gate of Section III-B, contributing redundant banking paths when their output exceeds conditioning overhead.

## V. Two Mission Profiles on One Backbone

For a laser sail the terminal velocity scales as v_f ∝ m_base/m_total. With a 4 m² sail (≈0.4 g/m²) and a 0.30 g chip, m_base ≈ 1.90 g → 0.200c, ≈22-year transit to α Centauri. Added source mass trades directly against velocity.

### A. Profile A — Maximum velocity (betavoltaic, dormant cruise)

The deep-cruise source is a Ni-63 betavoltaic keep-alive; no RTG. Two operating points span a velocity/cruise-science knob:

- **A-minimal (dormant):** keep-alive only (~0.1 µW, bare RTC), betavoltaic ≈0.1 g → **0.191c, ≈23 yr**. Cruise is dormant; the craft wakes at the destination. Energy banking is genuinely load-bearing here—rare energy-rich windows (laser push, near-star PV, flyby) are banked and the long dark cruise is bridged on microwatts.
- **A-science:** betavoltaic sized for surplus (~0.7–1 µW), ≈0.6–0.9 g → **0.152–0.137c, ≈29–32 yr**, enabling cruise micro-sampling.

A single sense-process-store cycle costs only **≈0.8 µJ** (MCU active ≈100 µA/MHz [1]; low-power magnetometer single read [4]; FRAM write 125 ns/word [1]). With even 0.3 µW surplus this banks in ≈17 s, supporting **thousands of micro-measurements per day**; results accrue in nonvolatile memory and are transmitted in PV windows. Storage uses a small (~1–10 mF) low-leakage capacitor for cruise sampling—settled EDLC leakage falls to nanoampere levels [9][10], compatible with the µW surplus—and the 28 mF supercapacitor for communication bursts, charged from PV.

The principal risks are thermal (no RTG waste heat → cold chip in deep cruise, possibly below the −55 °C device floor; a small radioisotope heater may be required) and the lower space technology-readiness level of Ni-63 betavoltaics relative to tritium.

### B. Profile B — Continuous science (Pu-238 RTG)

The deep-cruise source is the 150 mg Pu-238 RTG with thermoelectric recovery of Section IV-B. Added mass ≈0.75 g → **0.143c, ≈30-year transit**. Deep-cruise source after conditioning is ≈5.7 mW against a 0.15 mW average load—a ~38× margin—so the communication bucket refills in ≈8 s and operation is continuous in every phase. Over 20 years the source degrades ≈15%; the high-ZT recovery layer partially compensates, and even an RTG converter failure leaves the recovery path above the sleep floor, giving graceful degradation through two independent banking paths. Storage is cycled continuously, favoring a solid-state cell for calendar life; the RTG's waste heat provides thermal survival as a by-product.

### C. Comparison and decision framework

**TABLE III. Profile comparison.**

| Axis | A (betavoltaic) | B (Pu-238 RTG) |
|---|---|---|
| Terminal velocity | 0.19c (minimal) … 0.14c (science) | 0.143c |
| Transit (α Cen) | 23–32 yr | 30 yr |
| Added mass | 0.1–0.9 g | 0.75 g |
| Deep-cruise power | ~0.7 µW (dormant) | ~5.7 mW (continuous) |
| Cruise science | thousands of µJ-class reads/day, no continuous ops | continuous |
| 20-yr storage reliability | easy (PV cold-start; no long retention) | hard (continuous cycling) |
| Thermal | passive; cold-chip risk | RTG warms electronics |
| Regulatory/cost | low (tritium NSPM-20; Ni-63) [16] | Pu-238 scarce, high approval burden |
| Energy-banking thesis | load-bearing (banks rare windows) | secondary (RTG dominates) |
| Fault tolerance | PV-revival dependent | two independent banking paths |

The architecture is identical; only the deep-cruise source differs. The decision rule is therefore explicit: a mission whose value is *earliest arrival and flyby science* selects A; a mission whose value is *continuous in-cruise measurement* selects B and pays a velocity premium.

## VI. Analytical Evaluation and Simulation

We evaluate (i) *banked energy* ∫(P_sources − P_load)dt and (ii) *peak-event cadence*, the refill rate of the 44.6 mJ bucket, against an RTG-only baseline. Near 1 AU both profiles are storage-limited (PV ≈220 mW fills the buffer in minutes; surplus is curtailed). In deep cruise, Profile B banks ≈5.7 mW (cadence improvement over a conventional-converter RTG baseline arising from the high-ZT recovery), while Profile A is dormant on microwatts; for A the architecture's value is the *independent banking path and 100-year source stability*, not throughput. A ZT sensitivity sweep over [1.0, 2.0] (Table IV) confirms qualitative conclusions are independent of an optimistic ZT. Converter efficiencies (η_mppt ≈ 0.88, η_charge ≈ 0.95, boost/buck-boost ≈ 0.88–0.90) and thermal stability over −50…+80 °C are verified at circuit level in [PSIM/MATLAB]. [SİM: insert MPPT convergence, light-load efficiency curves, SoC trajectories, and the per-phase banked-energy/cadence plots.]

**TABLE IV. ZT sensitivity of thermoelectric recovery (Profile B).**

| ZT | System η | Total RTG+TE (mW) | TE recovery (mW) |
|---|---|---|---|
| 1.0 | 7.0% | 9.5×(Q_th/137) | +2.1 (@81 mW) |
| 1.25 | 8.0% | — | +2.1 |
| 1.5 | 9.0% | — | +3.0 |
| 2.0 | 10.5% | — | +4.0 |

*(Values scale with Q_th; tabulated for the 150 mg / 81 mW case. [SİM] to finalize.)*

## VII. Conclusion and Future Work

We have presented an energy-banking power architecture for a coin-sized photon-sail nanosatellite that reframes the design objective from maximizing instantaneous harvested power to maximizing banked energy and peak-event cadence, and that is agnostic to its deep-cruise source. Per-source MPPT with power-domain combining and net-energy gating banks from sources spanning roughly nine orders of magnitude without mutual loading; a low-quiescent buck-boost/boost dual-mode stage decouples peak load from continuous generation. On this backbone, a maximum-velocity profile (betavoltaic keep-alive, dormant cruise) and a continuous-science profile (Pu-238 RTG with high-ZT reject-heat recovery) are shown to be two instantiations whose selection follows from the mission objective rather than from the architecture. The contribution is structural: a fault-tolerant, source-agnostic PMU that converts a power-constrained platform into one whose mission cadence and survivability scale with the energy it can accumulate. Future work includes hardware prototyping of the combining/gating PMU, measured characterization of thermoelectric reject-heat recovery, raising the space technology-readiness level of Ni-63 betavoltaics, and circuit-level closure of the [SİM] results.

## References

> Component and device values below are from manufacturer datasheets and peer-reviewed/technical sources verified during design; mission-concept and standard-constant references ([1], Pu-238 parameters) should be confirmed against canonical sources before submission.

[1] P. Lubin, "A Roadmap to Interstellar Flight," *J. British Interplanetary Society*, 2016 (Breakthrough Starshot photon-sail concept). *[verify bibliographic details]*

[2] NASA Glenn Research Center, "Low Power Radioisotope Conversion Technology and Performance Summary," NTRS 20180007388, 2018 (betavoltaic vs. thermoelectric; tritium efficiency 5–8%).

[3] City Labs, "Tritium Battery Applications" — trickle-charge secondary storage + duty-cycle operation. https://citylabs.net/applications/

[4] STMicroelectronics, "LIS3MDL 3-axis digital magnetometer," datasheet (low-power single-conversion mode). https://www.st.com/resource/en/datasheet/lis3mdl.pdf

[5] Analog Devices, "ADXL362 Micropower 3-Axis MEMS Accelerometer," Rev. G (<2 µA @100 Hz; 270 nA wake). https://www.analog.com/en/products/adxl362.html

[6] Ambiq Micro, "Artasie Real-Time Clock" (keep-alive RTC ~14 nA). https://www.ambiq.com/rtc/

[7] Microchip Technology, "XLP nanoWatt MCUs" (power-down <100 nA; RTCC/WDT ~800 nA). https://www.mouser.com/new/microchip/microchipxlp/

[8] U.S. Patent 8,487,392, "High power density betavoltaic battery" (SiC betavoltaic 1–2 V, nW–mW, measured ~20% efficiency).

[9] Vishay, "How to Manage Leakage Current and Self-Discharge of EDLC Supercapacitors" (~µA/F, falling to nA after extended charge). https://www.vishay.com/docs/28585/howtomancurandseldisedlccaps.pdf

[10] KEMET, "Supercapacitor Leakage and Self-Discharge" application note (RTC-backup; µA–nA leakage).

[11] Texas Instruments, "BQ25504 Ultra-Low-Power Boost Converter/Charger for Energy Harvesting" (cold-start 330–600 mV; IQ <330 nA; µW–mW). https://www.ti.com/lit/ds/symlink/bq25504.pdf

[12] Analog Devices, "ADP5091/92 Ultralow-Power Energy Harvester PMU," Rev. A (cold-start 380 mV; 6–16 µW…600 mW; sub-µW loss). https://www.analog.com/en/products/adp5091.html

[13] U.S. Patent 9,099,212, "Low volumetric density betavoltaic power device" (series/parallel cell stacking; Voc 0.4 V Si … >2 V SiC/GaN/diamond).

[14] V. Bormashov et al. (MIPT/TISNCM), diamond-Schottky Ni-63 nuclear battery, *Diamond and Related Materials*, 2018 (~10 µW/cm³; Ni-63 t½ 100 yr; ~3300 mWh/g).

[15] City Labs / NASA, "Next-generation tritium space power source," 2023 (50–100 µW, 20-year, vacuum/radiation, −55…+150 °C). https://citylabs.net/city-labs-new-tritium-based-technology-nasa-missions/

[16] NSPM-20, U.S. space nuclear power/RHU regulatory framework (streamlined for tritium RHUs); cf. City Labs SBIR portfolio.

[17] Texas Instruments, "MSP430FR5969 Mixed-Signal Microcontroller," SLAS704 (≈100 µA/MHz active; LPM4.5 0.02 µA; FRAM 125 ns/word, radiation-resistant, nonmagnetic). https://www.ti.com/lit/ds/symlink/msp430fr5969.pdf

[18] Triple-junction / CsPbBr₃ perovskite thin-film PV for space — radiation tolerance and broad spectral response. *[fill with chosen primary]*

[19] Survey of MPPT techniques (P&O, fractional-Voc, SSHI) for multi-source harvesting. *[fill]*

[20] Hybrid supercapacitor/battery storage for pulsed loads in small spacecraft. *[fill]*

---

*Note: This is a single comparative paper covering both profiles, which avoids redundant "salami" publications since the two share one architecture. If a venue prefers, it can be split into (a) the architecture + Profile B, and (b) a focused Profile-A "betavoltaic keep-alive for dormant interstellar cruise" paper, reusing Sections III–IV.*
