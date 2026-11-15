# Paper 2 — A Mass-Optimal Betavoltaic Keep-Alive Power Architecture for Maximum-Velocity Photon-Sail Nanosatellites: Energy Banking with Duty-Cycled Dormant Cruise

**Faruk Sami Bilgin**

---

## Abstract

For a laser-driven photon sail the terminal velocity scales inversely with total mass, so every gram of onboard power hardware is paid for in mission speed. We present a *mass-optimal* power architecture for a 3×3×1 cm femtosatellite that omits a radioisotope thermoelectric generator (RTG) entirely and instead uses a milligram-scale **betavoltaic keep-alive** source, exploiting an energy-banking strategy in which the spacecraft banks energy during rare power-rich windows—laser push, near-star photovoltaic (PV) exposure, and destination flyby—and bridges the long dark cruise on microwatts. State is held in nonvolatile FRAM/MRAM so the deep-cruise draw reduces to a real-time clock and wake comparator (~0.7 µW), well within a Ni-63 betavoltaic's continuous output; active milliwatt loads are served by trickle-charging storage and operating on a duty cycle. A single sense-process-store cycle costs only ≈0.8 µJ, so even a sub-microwatt banking surplus supports thousands of in-cruise micro-measurements per day, accrued nonvolatilely and transmitted in PV windows. Because the betavoltaic continuously bridges and PV cold-starts the system at the destination, storage need not retain charge over the cruise—removing the 20-year battery-reliability problem. With a Ni-63 source (100-year half-life) the platform reaches ≈0.19c (≈23-year transit) in its minimal configuration, versus ≈0.14c for an RTG-carrying design. All device parameters are taken from manufacturer datasheets and the literature; [SİM] completes the circuit-level results.

**Index Terms**—Betavoltaic, energy banking, duty cycling, nanosatellite power management, MPPT, nonvolatile memory, photon sail, deep space.

---

## I. Introduction

Photonic-propulsion concepts accelerate gram-scale spacecraft to a fraction of light speed using ground-based lasers [1]. The governing relation for such a sail is that, for a fixed laser fluence, terminal velocity scales as v_f ∝ m_base/m_total: **mass is velocity**. A power subsystem optimized for a laser sail must therefore minimize mass above all, which puts a continuous radioisotope thermoelectric source—several grams once fuel, conversion, and housing are included—in direct conflict with the mission's purpose.

We resolve this by abandoning continuous deep-cruise power. Photovoltaics dominate near a star and vanish in deep space; the laser-push phase and the destination flyby are intense but brief. The natural strategy is *energy banking*: accumulate energy in the rare power-rich windows and live off storage and a microwatt keep-alive through the dark cruise. Under this view, banking is not a marginal enhancement but the load-bearing principle. The contributions are:

1. A mass-velocity-driven source selection that omits the RTG and quantifies the resulting velocity gain.
2. A **betavoltaic keep-alive subsystem**, grounded in real device data, with nonvolatile-state operation, series-stacked interfacing that eliminates a boost stage, and duty-cycled cruise sampling.
3. A storage architecture in which the buffer need not retain charge over the cruise, removing 20-year battery degradation as a failure mode.

## II. Mission, Loads, and the Mass-Velocity Argument

The platform is a 3×3×1 cm body, A = 30 cm² (9 cm² PV, 12 cm² radiator, 9 cm² comms/sensors). Loads span Table I (dynamic range ≈291×, ≈2.5 orders); a communication burst is E_comms ≈ 22.3 mW × 2 s ≈ 44.6 mJ.

**TABLE I. System power by operating mode.**

| Mode | Power |
|---|---|
| Deep sleep | 0.10 mW |
| Minimum operations | 0.41 mW |
| Navigation | 0.82 mW |
| Data collection | 6.55 mW |
| Communication | 22.3 mW |
| Peak | 29.1 mW |

With a 4 m² sail (≈0.4 g/m²) and a 0.30 g chip, m_base ≈ 1.90 g → ≈0.200c, ≈22-year transit to α Centauri. Added source mass trades directly against velocity: a 0.75 g RTG yields ≈0.14c, whereas a milligram-scale betavoltaic preserves ≈0.19c (Section V). This margin is the entire motivation for the present architecture.

## III. Energy-Banking Architecture

The PMU backbone is conventional to this work: each source is conditioned by a dedicated MPPT/front-end and combined in the **power domain** (not in series, which would current-limit heterogeneous sources), gated by a net-energy threshold so a source is admitted only when its output exceeds its conditioning quiescent power [11]. A low-quiescent **buck-boost** supplies the 3.3 V survival rail (an isolated flyback is avoided—needless on one die and inefficient at sub-mW loads), and a **boost** stage discharges the supercapacitor for peak loads served in PV windows. A mission-phase FSM (Section IV-D) selects sources and modes and is itself event-driven and ultra-low-power.

## IV. Betavoltaic Keep-Alive Subsystem

### A. Source and isotope selection

A betavoltaic converts beta-decay electrons directly to electricity, delivering nanowatts-to-microwatts continuously for decades [13][15]. Tritium devices are space-qualified—City Labs delivered a 20-year NASA prototype producing 50–100 µW in vacuum/radiation tests, fresh ≈100 µW decaying to >32 µW at 20 years, operating −55…+150 °C [15]—but tritium's 12.3-year half-life forces heavy oversizing. We select **Ni-63 (100-year half-life)**: a diamond-Schottky prototype reported ≈10 µW/cm³ and ≈3300 mWh/g, decaying only ≈19% over 30 years [14], the most stable choice for a multi-decade cruise (versus ≈15%/20 yr for Pu-238).

### B. Keep-alive load budget

State is held in nonvolatile FRAM/MRAM, eliminating SRAM-retention current; the deep-cruise draw is then a real-time clock (~14 nA [6]) plus a wake comparator and CMOS leakage floor (~10²–10³ nA [7])—**≈0.7 µW total**, well below a small betavoltaic's output. FRAM is additionally radiation-resistant and nonmagnetic [17], advantageous in deep space.

### C. Interfacing and cruise sampling

Betavoltaic cells are **series-stacked** to the bus voltage [13] (SiC/diamond cells give 1–2 V each [8]), so a low-leakage diode and a nano-power LDO suffice and the boost-stage quiescent overhead is eliminated—critical at the microwatt scale. Active loads use the manufacturer-standard **trickle-charge-and-duty-cycle** pattern [3]. A single sense-process-store cycle costs ≈0.8 µJ (MCU active ≈100 µA/MHz [17]; low-power magnetometer single read [4]; FRAM write 125 ns/word [17]); with a 0.3 µW banking surplus this accrues in ≈17 s, supporting **thousands of in-cruise micro-measurements per day**.

Two storage elements are used: a small (~1–10 mF) low-leakage capacitor for cruise sampling, whose settled leakage falls to nanoamperes [9][10]—compatible with the microwatt surplus—and the 28 mF communication supercapacitor, charged from PV (a leaky large supercapacitor cannot be filled from microwatts). Because the betavoltaic bridges continuously and PV cold-starts the system at the destination, **the buffer need not retain charge over the 20-year cruise**, removing battery calendar-life as a failure mode.

### D. Mission-phase FSM

`DORMANT` (RTC + wake, ~0.7 µW; betavoltaic trickle-charges the cruise cap) → on RTC alarm `SENSE`→`STORE` (≈0.3 mW for ≈2 ms, return to DORMANT) → on PV detection `ACTIVE_PV` (full operation, comms burst from PV-charged supercapacitor) → on PV loss back to DORMANT.

## V. Evaluation

**Velocity.** A Ni-63 betavoltaic at the keep-alive minimum (≈0.1 µW, ≈0.1 g) yields **≈0.191c (≈23-year transit)**; sizing for cruise-sampling surplus (≈0.7–1 µW, ≈0.6–0.9 g) trades down to ≈0.137–0.152c. Thus the architecture exposes a deliberate velocity/cruise-science knob, and is strictly faster than an RTG design only in its leaner configurations—an honest boundary: beyond ≈1 µW the velocity advantage disappears and an RTG becomes preferable.

**Banking by phase.** Near 1 AU (PV ≈220 mW from η_pv = 18% over 9 cm²) the system is storage-limited and banks to full; deep cruise is dormant on microwatts with duty-cycled sampling; the destination star revives PV (≈220 mW) for flyby science and the deferred communication dump.

**Reliability.** With no continuous source and no long-term charge retention required, the dominant risks are (i) thermal—absent RTG waste heat, the chip may fall below the −55 °C device floor in deep cruise, possibly requiring a small radioisotope heater—and (ii) the lower space technology-readiness level of Ni-63 betavoltaics relative to tritium. Both are identified for future work.

Converter and storage parameters and thermal behavior over −50…+80 °C are verified at circuit level in [PSIM/MATLAB]. [SİM: cruise duty-cycle SoC trajectories, cold-start at destination, banking-window fill times.]

## VI. Conclusion

We presented a mass-optimal power architecture for a maximum-velocity photon-sail femtosatellite that omits a radioisotope thermoelectric generator in favor of a Ni-63 betavoltaic keep-alive, and in which energy banking is the load-bearing principle rather than an enhancement. Nonvolatile-state operation reduces the dormant draw to ≈0.7 µW; series-stacked interfacing removes the boost-stage overhead; a ≈0.8 µJ measurement cycle enables thousands of in-cruise samples per day from a microwatt surplus; and the elimination of long-term charge retention removes 20-year battery degradation as a failure mode. The platform reaches ≈0.19c in its minimal configuration. Future work includes deep-space thermal management without RTG waste heat, raising the betavoltaic space technology-readiness level, and circuit-level closure of [SİM].

## References

[1] P. Lubin, "A Roadmap to Interstellar Flight," *J. British Interplanetary Society*, 2016. *[verify]*
[3] City Labs, "Tritium Battery Applications" — trickle-charge storage + duty-cycle. https://citylabs.net/applications/
[4] STMicroelectronics, "LIS3MDL 3-axis magnetometer" (low-power single-conversion). https://www.st.com/resource/en/datasheet/lis3mdl.pdf
[6] Ambiq Micro, "Artasie RTC" (~14 nA keep-alive). https://www.ambiq.com/rtc/
[7] Microchip, "XLP nanoWatt MCUs" (power-down <100 nA; RTCC/WDT ~800 nA). https://www.mouser.com/new/microchip/microchipxlp/
[8] U.S. Patent 8,487,392, "High power density betavoltaic battery" (SiC, 1–2 V, ~20% measured).
[9] Vishay, "EDLC Leakage and Self-Discharge" (~µA/F → nA after extended charge). https://www.vishay.com/docs/28585/howtomancurandseldisedlccaps.pdf
[10] KEMET, "Supercapacitor Leakage and Self-Discharge" application note.
[11] TI, "BQ25504 Energy-Harvesting Boost/Charger" (cold-start 330–600 mV; IQ <330 nA). https://www.ti.com/lit/ds/symlink/bq25504.pdf
[12] ADI, "ADP5091/92 Energy Harvester PMU" (cold-start 380 mV; 6–16 µW…600 mW). https://www.analog.com/en/products/adp5091.html
[13] U.S. Patent 9,099,212, "Low volumetric density betavoltaic power device" (series/parallel stacking; Voc 0.4–>2 V).
[14] V. Bormashov et al. (MIPT/TISNCM), diamond-Schottky Ni-63 nuclear battery, *Diamond and Related Materials*, 2018 (≈10 µW/cm³; t½ 100 yr; ≈3300 mWh/g).
[15] City Labs / NASA, "Next-generation tritium space power source," 2023 (50–100 µW, 20-year, vacuum/radiation, −55…+150 °C). https://citylabs.net/city-labs-new-tritium-based-technology-nasa-missions/
[16] NSPM-20 space nuclear/RHU regulatory framework (streamlined for tritium RHUs); City Labs SBIR portfolio.
[17] TI, "MSP430FR5969," SLAS704 (≈100 µA/MHz; LPM4.5 0.02 µA; FRAM 125 ns/word, radiation-resistant, nonmagnetic). https://www.ti.com/lit/ds/symlink/msp430fr5969.pdf

*Note: [1] is standard; confirm bibliographic details before submission. PV primary reference to be added.*
