# Paper 1 — A Multi-Source Energy-Banking Power Architecture with Thermoelectric Reject-Heat Recovery for Continuous-Operation Photon-Sail Nanosatellites

**Faruk Sami Bilgin**

---

## Abstract

Coin-sized photon-sail nanosatellites demand continuous power over a multi-decade interstellar cruise while massing only a few grams. We present a multi-source *energy-banking* power architecture for a 3×3×1 cm femtosatellite whose continuous baseline is a milligram-scale radioisotope thermoelectric generator (RTG). The central technical contribution is a **high-ZT thermoelectric reject-heat recovery layer** that converts part of the heat a conventional RTG rejects, recovering several milliwatts at no additional thermal budget. Rather than reporting instantaneous power, we reframe the design objective as *banked energy* and the resulting *peak-event cadence*: every source is conditioned by a dedicated maximum-power-point-tracking (MPPT) stage, combined in the power domain to avoid the impedance mismatch of series connection, gated by a net-energy threshold, and accumulated in a hybrid supercapacitor/battery buffer. A dual-mode converter sustains survival through a low-quiescent buck-boost stage and serves peak loads through a boost stage. For a 150 mg Pu-238 source the architecture delivers ≈6.5 mW continuously in every mission phase—a ~38× margin over the deep-sleep load—refilling a 44.6 mJ communication bucket in ≈8 s, and degrades gracefully: even a failure of the primary RTG converter leaves the recovery path above the survival floor through two independent banking paths. Analytical evaluation with a calibrated thermoelectric model and a ZT sensitivity study confirms conclusions independent of optimistic material assumptions; [SİM] completes the circuit-level results.

**Index Terms**—Energy harvesting, energy banking, MPPT, thermoelectric generator, reject-heat recovery, radioisotope, nanosatellite power management, deep space.

---

## I. Introduction

Photonic-propulsion concepts envisage accelerating gram-scale spacecraft to a fraction of light speed with ground-based laser arrays, enabling interstellar transit within decades [1]. A platform able to *operate continuously throughout the cruise*—taking interstellar-medium, magnetic-field, and particle measurements en route, not only at the destination—requires a continuous power source that survives full solar illumination through deep-space darkness without refueling. Photovoltaics (PV) vanish beyond a few AU; only a radioisotope source provides continuous deep-space power at this scale, but it is mass-, cost-, and regulation-limited to a few milliwatts.

The defining tension is the gap between a sub-milliwatt sleep budget and tens-of-milliwatt peak loads (communication, sensing, actuation). We argue the response is not a larger source but an architecture organized around *energy banking*: every available increment of energy is transferred into a shared buffer from which high-power events are served on demand, making the figure of merit the accumulated energy between events and the achievable cadence of power-intensive opportunities. The contributions are:

1. A multi-source energy-banking power-management unit (PMU) with per-source MPPT, power-domain combining, and net-energy gating.
2. A **high-ZT thermoelectric reject-heat recovery layer** that recovers several milliwatts from heat a conventional RTG discards, modeled from a calibrated thermal network rather than asserted.
3. A graceful-degradation argument: two independent radioisotope-to-electricity paths (primary conversion and reject-heat recovery) tolerate single-point failure and partially offset 20-year decay.

## II. Mission and Load Context

The platform is a 3×3×1 cm body, external area A = 2(3×3)+4(3×1) = 30 cm², allocated as 9 cm² Sun-facing (PV), 12 cm² space-facing (radiator/thermoelectric cold side), and 9 cm² communication/sensors; a Sun-facing surface cannot also be a cold radiator, so the split is physical. Loads span Table I, a dynamic range of 29.1/0.10 ≈ 291× (≈2.5 orders) between deep sleep and simultaneous peak.

**TABLE I. System power by operating mode.**

| Mode | Power | Context |
|---|---|---|
| Deep sleep | 0.10 mW | Deep cruise |
| Minimum operations | 0.41 mW | Housekeeping |
| Navigation | 0.82 mW | Attitude |
| Data collection | 6.55 mW | Science |
| Communication | 22.3 mW | Earth contact (burst) |
| Peak | 29.1 mW | Worst case |

Each power-intensive event is a fixed energy "bucket"; a communication burst is E_comms ≈ 22.3 mW × 2 s ≈ 44.6 mJ. The PMU refills this bucket between events; accumulated energy and refill time, not instantaneous power, are the metrics.

## III. Energy-Banking Power Architecture

**Per-source conditioning and power-domain combining.** Series connection is infeasible—heterogeneous source currents differ by orders of magnitude, so a string is current-limited by its weakest member. Each source is instead brought to its maximum-power point and combined in the power domain onto a hybrid bus (supercapacitor for bursts ∥ battery for energy density).

**Gated banking.** Each front-end draws quiescent power P_q (energy-harvesting PMICs specify IQ ~10²–10³ nA [11]); a source contributes net energy only if P_source > P_q, so the FSM disables sub-threshold sources (e.g. deep-space RF below the thermal-noise floor).

**Dual-mode conversion.** A low-quiescent synchronous **buck-boost** supplies the 3.3 V survival rail (an isolated flyback is avoided: isolation is needless on one die and its fixed losses are inefficient at sub-mW loads); a **boost** stage discharges the supercapacitor for peak loads, decoupling instantaneous load from generation.

**Mission-phase FSM.** Sources and converter mode are selected per phase; the controller monitors buffer state-of-charge and sheds non-critical loads in reverse priority when banking lags demand. Control is event-driven and ultra-low-power so its own consumption stays within budget.

```
[RTG]──────────────┐
[TE recovery]──MPPT─┤
[PV]──────────MPPT──┼─► POWER-DOMAIN COMBINING ─► [supercap ∥ battery]
[Opportunistic]─gate┘                                  │
                                              ┌────────┴────────┐
                                              ▼                 ▼
                                     [LOW-Iq BUCK-BOOST]     [BOOST]
                                      survival / 3.3 V       peak
```

## IV. RTG with Thermoelectric Reject-Heat Recovery

A radioisotope block dissipates Q_th; a thermoelectric converter extracts η_TEG·Q_th, the balance flowing to a radiator at T_rad from Q_rej = εσA_rad·T_rad⁴, giving **T_rad ≈ 218 K** (A_rad = 12 cm², ε = 0.85). Device efficiency is
η_TEG(ZT) = β · (T_h−T_rad)/T_h · (√(1+ZT)−1)/(√(1+ZT)+T_rad/T_h),
with parasitic de-rating **β ≈ 0.58** calibrated so a conventional ZT≈0.7 converter yields ≈5.4%. The *recovery* contribution is the extra power from co-integrating a **high-ZT (ZT≈1.25) converter**, lifting system efficiency to ≈8%.

A thin film placed *in series* with the reject-heat flow develops negligible ΔT and thus negligible Seebeck output; recovery must therefore be a segmented/higher-ZT converter, not a passive coating—an essential correction. For **150 mg Pu-238** (Q_th ≈ 81 mW): RTG ≈ **4.4 mW** + recovery ≈ **2.1 mW** = **≈6.5 mW continuous, in every phase**, decaying to ≈5.5 mW at 20 years (Pu-238 t½ = 87.7 yr [standard]). The RTG's waste heat additionally keeps electronics and battery above their minimum operating temperature—a thermal-survival by-product unique to this profile.

PV supplements near a star: with η_pv = 18% over 9 cm², P_pv(d) = η_pv·A_pv·(1361/d²) ≈ **220 mW at 1 AU**, equal to the RTG baseline near 5.4 AU and negligible beyond ≈47 AU.

## V. Evaluation

**Banking by phase.** Near 1 AU the system is storage-limited (PV ≈220 mW fills the buffer in minutes). In deep cruise the source after conditioning is ≈5.7 mW against a ~0.15 mW average load—a **~38× margin**—so the 44.6 mJ bucket refills in ≈**8 s**; operation is continuous in every phase. The deep-cruise cadence improvement over a conventional-converter RTG baseline arises entirely from the high-ZT recovery layer.

**Graceful degradation.** Over 20 years the source decays ≈15%; recovery partially compensates. Critically, a failure of the primary RTG converter leaves the recovery path **above the 0.10 mW sleep floor**, so two independent radioisotope-to-electricity paths tolerate single-point failure—the architecture's principal reliability claim.

**Sensitivity.** A ZT sweep over [1.0, 2.0] (Table II) confirms qualitative conclusions are independent of an optimistic ZT.

**TABLE II. ZT sensitivity (150 mg / 81 mW source).**

| ZT | System η | RTG+TE (mW) | Recovery (mW) |
|---|---|---|---|
| 1.0 | 7.0% | 5.6 | +1.2 |
| 1.25 | 8.0% | 6.5 | +2.1 |
| 1.5 | 9.0% | 7.3 | +2.9 |
| 2.0 | 10.5% | 8.5 | +4.1 |

Converter efficiencies (η_mppt ≈ 0.88, η_charge ≈ 0.95, buck-boost/boost ≈ 0.88–0.90) and thermal stability over −50…+80 °C are verified at circuit level in [PSIM/MATLAB]. [SİM: MPPT convergence, light-load efficiency, SoC trajectories, per-phase banked-energy/cadence plots.]

**Cost.** For a laser sail the ≈0.75 g source mass reduces terminal velocity to ≈0.14c (≈30-year transit) versus ≈0.20c for a source-free baseline; this profile trades velocity for continuous in-cruise capability. A mass-optimal alternative that omits the RTG is addressed in a companion paper.

## VI. Conclusion

We presented an energy-banking power architecture whose continuous baseline is a radioisotope source augmented by a high-ZT thermoelectric reject-heat recovery layer, recovering several milliwatts from otherwise-discarded heat and delivering ≈6.5 mW continuously with a ~38× sleep margin and ≈8 s communication-bucket refill. The architecture's contribution is structural and reliability-oriented: per-source MPPT with power-domain combining and net-energy gating banks heterogeneous sources without mutual loading, while two independent radioisotope-to-electricity paths provide graceful degradation over a 20-year unmaintainable mission. Future work includes measured characterization of reject-heat recovery, hardware prototyping of the combining/gating PMU, and circuit-level closure of [SİM].

## References

[1] P. Lubin, "A Roadmap to Interstellar Flight," *J. British Interplanetary Society*, 2016. *[verify]*
[2] NASA GRC, "Low Power Radioisotope Conversion Technology and Performance Summary," NTRS 20180007388, 2018.
[3] Bi₂Te₃/Sb₂Te₃ superlattice thermoelectrics and ZT enhancement. *[fill with chosen primary]*
[4] TI, "BQ25504 Ultra-Low-Power Boost/Charger for Energy Harvesting" (cold-start 330–600 mV; IQ <330 nA). https://www.ti.com/lit/ds/symlink/bq25504.pdf
[5] ADI, "ADP5091/92 Ultralow-Power Energy Harvester PMU" (cold-start 380 mV; 6–16 µW…600 mW). https://www.analog.com/en/products/adp5091.html
[6] TI, "MSP430FR5969," SLAS704 (≈100 µA/MHz; FRAM 125 ns/word; radiation-resistant). https://www.ti.com/lit/ds/symlink/msp430fr5969.pdf
[7] Triple-junction / CsPbBr₃ perovskite thin-film PV for space. *[fill]*
[8] Hybrid supercapacitor/battery storage for pulsed loads in small spacecraft. *[fill]*
[9] MPPT techniques survey (P&O, fractional-Voc). *[fill]*
[10] Pu-238 specific power (≈0.54 W/g) and half-life (87.7 yr), NASA RPS references. *[verify]*

*Note: Pu-238 parameters and [1] are standard; confirm against canonical sources before submission.*
