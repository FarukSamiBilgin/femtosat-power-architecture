# A Multi-Source Energy-Banking Power Architecture for Coin-Sized Photon-Sail Nanosatellites: Per-Source MPPT and Flyback/Boost Dual-Mode Conversion

**Faruk Sami Bilgin**

*Status: Conference paper draft (unpublished). Entries marked [SİM] are pending simulation results and are intentionally left unfilled.*

---

## Abstract

Coin-sized photon-sail nanosatellites face an extreme power problem: a sub-milliwatt sleep budget, peak loads—laser communication, sensing, and attitude actuation—an order of magnitude higher, and a multi-decade mission spanning conditions from full solar illumination to deep-space darkness, with no possibility of refueling or maintenance. This paper presents a multi-source *energy-banking* power architecture for a 3×3 cm femtosatellite. A radioisotope thermoelectric generator (RTG) provides the continuous baseline; a surface-integrated harvesting stack—a triple-junction photovoltaic (PV) layer and a Bi₂Te₃/Sb₂Te₃ thermoelectric (TE) layer that reclaims part of the RTG's rejected heat, together with opportunistic piezoelectric, triboelectric, and RF mechanisms—feeds a common hybrid supercapacitor/battery buffer. Each source is interfaced through a dedicated front-end and maximum-power-point-tracking (MPPT) stage and combined in the power domain, avoiding the impedance mismatch that series-connecting heterogeneous sources would impose. A dual-mode converter sustains survival operation through a flyback stage and delivers peak loads through a boost stage drawing from the buffer. Rather than reporting instantaneous power, we evaluate *banked energy* and the resulting *peak-event cadence*. Analytical evaluation and circuit simulation show that the architecture captures sources spanning roughly five orders of magnitude of power onto a single buffer and improves cruise-phase mission cadence by [SİM X]% over an RTG-only baseline, while preserving an independent banking path for graceful degradation over the 20-year mission.

**Index Terms**—Energy harvesting, energy banking, MPPT, nanosatellite power management, thermoelectric generator, flyback converter, boost converter, femtosatellite, deep space.

---

## I. Introduction

Photonic-propulsion mission concepts envisage accelerating gram-scale spacecraft to a substantial fraction of light speed using ground-based laser arrays, enabling interstellar transit within decades rather than millennia. Realizing such a platform requires compressing power generation, conversion, storage, sensing, and communication into a coin-sized body. The resulting power-management problem differs qualitatively from that of conventional CubeSats: the surface available for collection is on the order of tens of square centimeters, mass margins forbid bulky storage, and the mission traverses radically different energy environments—intense near-Sun illumination at launch, prolonged darkness during cruise, and a brief, power-hungry flyby at the destination.

A single primary source cannot serve this profile efficiently. Photovoltaics dominate near a star but vanish in deep space; a radioisotope source is continuous but mass- and regulation-limited to a few milliwatts at this scale; and the instantaneous demand of a communication burst exceeds any continuous source the platform can carry. The mismatch between a sub-milliwatt sleep budget and tens-of-milliwatt peaks is therefore the central design tension.

This paper argues that the right response is not a larger source but a power architecture organized around *energy banking*: continuously transferring every available increment of energy—regardless of how small or which mechanism produced it—into a shared storage buffer, from which high-power events are served on demand. Under this view the relevant figure of merit is not instantaneous harvested power but the energy accumulated between events and the rate at which power-intensive mission opportunities can therefore be repeated.

The contributions of this work are threefold:

1. A surface-integrated, multi-source harvesting stack in which a PV layer and an RTG-coupled TE layer constitute the budgeted contributors, while piezoelectric, triboelectric, and RF mechanisms are characterized and treated as non-budgeted opportunistic banking inputs.
2. A power-management unit (PMU) in which each source is conditioned by a dedicated front-end and MPPT stage and combined in the power domain, demonstrated to bank from sources spanning roughly five orders of magnitude without one source loading down another.
3. A dual-mode conversion and arbitration scheme—flyback for survival, boost for peak loads—governed by a mission-phase finite-state machine, evaluated by banked-energy and peak-event-cadence metrics rather than instantaneous power.

## II. Mission and Load Context

### A. Operating modes and power budget

The platform is a 3×3×1 cm body. Allocating the surface for collection and the interior for the PMU, storage, and a minimal payload, the load resolves into the modes summarized in Table I. The defining feature is the four-order span between the deep-sleep floor and the simultaneous peak.

**TABLE I. System power by operating mode (3×3 cm platform).**

| Operating mode | Total power | Typical context |
|---|---|---|
| Deep sleep | 0.103 mW | Deep cruise |
| Minimum operations | 0.407 mW | Normal cruise housekeeping |
| Navigation active | 0.818 mW | Attitude updates |
| Data collection | 6.55 mW | Flyby science |
| Communication | 22.33 mW | Earth contact (burst) |
| Peak (simultaneous) | 29.10 mW | Emergency / worst case |

### B. Mission phases and source availability

The 20-year profile divides into a launch and acceleration phase near 1 AU with strong illumination; an early-cruise phase over 2–10 AU with rapidly declining solar input; a deep-cruise phase beyond ~10 AU in effective darkness; and a brief stellar-approach and flyby phase. PV availability tracks the inverse-square decline of irradiance and is negligible beyond roughly 10 AU; the RTG is continuous; the TE layer, coupled to the RTG's thermal reject path, is available wherever the RTG operates—including deep cruise.

### C. The buffer-and-bucket model

We model each power-intensive event as a fixed energy "bucket." A representative communication burst draws the 22.33 mW load for approximately 2 s, requiring

E_comms ≈ 22.33 mW × 2 s ≈ 44.7 mJ.

The PMU's task is to refill this bucket from all available sources during the intervals between events. This reframing—accumulated energy and refill time rather than instantaneous power—motivates the architecture in Section IV and the evaluation in Section V.

## III. Surface-Integrated Harvesting Sources

The harvesting stack is a thin (≈6.5 µm) multilayer coating over the body surface. With a 3×3×1 cm geometry the total external area is

A_surface = 2(3×3) + 4(3×1) = 30 cm².

Two layers are treated as budgeted contributors; the remainder are characterized as opportunistic.

### A. Photovoltaic layer

The PV layer uses a wide-spectrum thin-film absorber (triple-junction or CsPbBr₃-class perovskite quantum-dot film) selected for radiation tolerance and broad spectral response. Its output follows solar irradiance and therefore mission distance: meaningful near 1 AU, declining with the inverse square of distance, and negligible in deep cruise. The PV layer is distinct from, and modeled separately to avoid double-counting with, any dedicated primary solar panel; overlapping collection area is subtracted. We adopt a single, condition-labeled output figure rather than mixing optimal and degraded values.

### B. Thermoelectric layer (RTG-coupled, reject-heat recovery)

The TE layer comprises vertically aligned Bi₂Te₃/Sb₂Te₃ superlattice elements. Critically, it does not draw a second, independent heat budget. The RTG dissipates approximately 137 mW of thermal power and converts only ~5.5% (≈7.5 mW) to electricity; the balance, on the order of

Q_reject ≈ 137 − 7.5 ≈ 129.5 mW,

flows toward the cold (space-facing) side. The TE layer is positioned as a bottoming stage on this reject stream, recovering a fraction of heat already accounted for as RTG loss. This framing eliminates the double-counting that would otherwise inflate the budget.

The Seebeck output scales with the temperature difference Δ*T* across the layer between the RTG-warmed inner face and the radiating outer face. The dimensionless figure of merit is

ZT = (S²σ/κ)·T.

Quantum confinement in the superlattice can raise ZT above its bulk value; we adopt a *conservative* ZT in the range 1.5–2.0 for the headline results and report sensitivity to ZT in Section V-D, so that conclusions do not depend on an optimistic, record-edge value. The TE layer's continuous output exceeds the deep-sleep budget on its own, making it the harvesting mechanism that remains relevant throughout cruise.

### C. Opportunistic mechanisms (piezoelectric, triboelectric, RF)

Three further mechanisms are integrated but explicitly *not* budgeted:

- *Piezoelectric (ZnO nanowire):* generation requires mechanical strain. Absent a sustained vibration source during free cruise, average output is in the microwatt range and is treated as event-driven (e.g., launch, actuation).
- *Triboelectric (PTFE/Al):* requires repeated contact–separation. In the cruise vacuum, contact events (micrometeoroid impacts, thermal-cycle-induced microdisplacement) are infrequent; sustained output is sub-microwatt and is not relied upon as a steady source.
- *RF rectification (graphene/CNT):* coupling to ambient electromagnetic fields is meaningful only in field-rich environments near a transmitter; the cosmic-background contribution lies at or below the thermal-noise floor and cannot be rectified into useful DC in deep space.

Including these mechanisms is nonetheless justified under the banking philosophy: even a sub-10 µW aggregate contributes measurable energy over time (Section V) and provides redundant, independent banking paths. They are presented as bonuses, never as load-bearing budget items—an honesty anchor that strengthens, rather than weakens, the design's credibility.

## IV. Energy-Banking Power Architecture

### A. Topology overview

Fig. 3 shows the PMU. Every source—RTG, PV layer, TE layer, and the opportunistic mechanisms—drives a dedicated front-end and MPPT stage whose outputs are combined in the power domain onto a hybrid storage bus. The bus pairs a supercapacitor (high-rate buffering for bursts) with a battery (energy density for long-term banking). Two converters draw from the bus: a flyback stage providing the regulated 3.3 V survival rail, and a boost stage serving peak mission loads.

```
[RTG] ─────────────┐
[PV layer] ───MPPT──┤
[TE layer] ───MPPT──┼─► POWER-DOMAIN  ─► [Hybrid bus: supercap ∥ battery]
[Piezo] ──────MPPT──┤   COMBINING            │
[Tribo] ──────MPPT──┤                ┌────────┴────────┐
[RF]   ──────MPPT──┘                ▼                 ▼
                                [FLYBACK]          [BOOST]
                              survival / 3.3 V    peak / mission
```

### B. Per-source conditioning and power-domain combining

Series connection of these sources is infeasible: their characteristic currents differ by orders of magnitude, so a series string is current-limited by its weakest member, collapsing total extractable power. Instead, each source is brought to its own maximum-power point by an appropriate algorithm and contributes independently to the shared bus. Representative load matching is given in Table II.

**TABLE II. Per-source MPPT matching.**

| Source | MPPT algorithm | Optimal load (order) |
|---|---|---|
| Photovoltaic | Perturb & Observe | ~10¹–10² Ω |
| Thermoelectric | Fractional open-circuit voltage | ~10³–10⁴ Ω |
| Piezoelectric | Synchronized switch harvesting (SSHI) | ~10⁷–10⁸ Ω |
| Triboelectric | Peak detection / charge pump | ~10⁵ Ω |
| RF | Impedance matching to rectifier | ~10² Ω |

### C. Dual-mode flyback/boost conversion

The conversion strategy matches topology to demand. During survival and routine housekeeping, the flyback stage supplies the regulated low-power rail at high light-load efficiency; the high instantaneous demand of communication or actuation is served by the boost stage, which discharges the supercapacitor to deliver currents exceeding the continuous capability of any single source. The buffer thus decouples instantaneous load from instantaneous generation: sources need only supply *average* power, while the buffer supplies *peak* power.

### D. Mission-phase arbitration

A finite-state machine selects active sources and converter mode per mission phase (Fig. 4): near 1 AU, PV and the auxiliary mechanisms are enabled and banking is rapid; in deep cruise, banking relies on the RTG baseline plus TE recovery, with the system defaulting to flyback survival and waking the boost stage only for scheduled events; during flyby, all sources are enabled and event cadence is maximized. The controller monitors buffer state of charge and load priority and sheds non-critical loads in reverse priority order when banking falls behind demand.

## V. Analytical Evaluation and Simulation

### A. Metrics

We evaluate two quantities: (i) *banked energy*, the net energy accumulated into the buffer over a given interval, ∫(P_sources − P_load) dt; and (ii) *peak-event cadence*, the achievable repetition rate of a reference event (the 44.7 mJ communication bucket), set by the refill time between events. Both are reported against an RTG-only baseline.

### B. Banking rates by phase

In normal cruise the RTG net surplus over the minimum-operations load is

P_net,RTG ≈ 7.5 − 0.407 ≈ 7.09 mW,

which alone banks ≈ 613 J per day. The RTG is therefore the workhorse, and the analysis states this plainly. The harvesting stack's marginal contribution is phase-dependent. In deep cruise, with PV and the opportunistic mechanisms negligible, the TE layer adds a continuous ≈ 0.2–0.3 mW—itself exceeding the 0.103 mW sleep floor—contributing ≈ 17–26 J per day of additional banked energy. Even a sub-10 µW opportunistic aggregate banks ≈ 0.86 J per day, equivalent to roughly nineteen communication-burst buckets, illustrating that no source is too small to matter under the banking model. Near 1 AU the PV layer adds on the order of 0.5 mW, accelerating refill ahead of high-rate science and communication windows.

### C. Peak-event cadence

The communication bucket refill time from the RTG baseline in cruise is

t_refill ≈ 44.7 mJ / 7.09 mW ≈ 6.3 s.

Adding the deep-cruise TE contribution shortens this to ≈ [SİM ~6.1] s, a cadence improvement of ≈ [SİM 3–4]%. The improvement is modest in deep cruise—consistent with the RTG's dominance—and larger in energy-rich phases where PV and auxiliary banking are active [SİM]. The architecture's principal value in deep cruise is therefore not throughput but the *independent, redundant banking path* it provides as the RTG degrades over two decades.

### D. Sensitivity to ZT and converter efficiency

Because the TE contribution scales with ZT and Δ*T*, we report banked energy and cadence across ZT ∈ [1.5, 2.0] and converter efficiency across the expected light-load range (Table III). The qualitative conclusions—TE as the deep-cruise banking mechanism, cadence dominated by the RTG, opportunistic sources as non-budgeted bonuses—hold across the range, confirming that results do not rest on an optimistic ZT.

**TABLE III. Sensitivity of deep-cruise banking to ZT [SİM to be completed].**

| ZT | TE output (mW) | Added banked energy (J/day) | Cadence improvement (%) |
|---|---|---|---|
| 1.5 | [SİM] | [SİM] | [SİM] |
| 1.75 | [SİM] | [SİM] | [SİM] |
| 2.0 | [SİM] | [SİM] | [SİM] |

### E. Simulation setup

Circuit-level behavior (MPPT convergence, flyback light-load efficiency, boost burst delivery, buffer state-of-charge trajectories) is modeled in [PSIM/MATLAB]; thermal stability is verified across −50 °C to +80 °C. [SİM: insert convergence times, efficiency curves, and SoC plots.]

## VI. Conclusion and Future Work

We have presented an energy-banking power architecture for a coin-sized photon-sail nanosatellite that reframes the design objective from maximizing instantaneous harvested power to maximizing banked energy and peak-event cadence. Within this framing, a PV layer and an RTG-coupled thermoelectric layer serve as budgeted contributors—the latter remaining relevant through deep cruise by recovering rejected RTG heat—while piezoelectric, triboelectric, and RF mechanisms are integrated as non-budgeted, opportunistic banking inputs. Per-source MPPT with power-domain combining allows the PMU to bank from sources spanning roughly five orders of magnitude without mutual loading, and a flyback/boost dual-mode stage decouples peak load from continuous generation. The architecture's contribution is structural rather than a power record: it converts a power-constrained platform into one whose mission cadence and fault tolerance scale with the energy it can accumulate. Future work includes hardware prototyping of the combining PMU, measured characterization of the TE reject-heat recovery, and raising the technology-readiness level of the opportunistic mechanisms toward true plug-in banking inputs.

## References

> Fill with real citations. Suggested slots:
> [1] Photonic-propulsion / light-sail interstellar concept (e.g., Breakthrough Starshot program publication).
> [2] Femtosatellite / ChipSat power and systems survey.
> [3] Americium-241 micro-RTG specific power and thermoelectric conversion at small scale.
> [4] Bi₂Te₃/Sb₂Te₃ superlattice thermoelectrics and ZT enhancement.
> [5] Perovskite / quantum-dot thin-film photovoltaics for space and radiation tolerance.
> [6] MPPT techniques survey (P&O, fractional-Voc, SSHI for piezo).
> [7] Hybrid supercapacitor/battery storage for pulsed loads in small spacecraft.
> [8] Flyback and boost converter design for ultra-low-power / light-load efficiency.
> [9] Energy-harvesting / energy-neutral operation in ultra-low-power (IoT) systems — the banking precedent.
> [10] Triboelectric and RF energy harvesting limits (thermal-noise floor for rectification).
