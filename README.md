# femtosat-power-architecture

Electrical and power-electronics work for a coin-sized (3 × 3 × 1 cm) photon-sail femtosatellite: a multi-source **energy-banking** power architecture, a betavoltaic-versus-RTG mission-profile comparison, and the undergraduate thesis on flyback converter types that started the project.

Author: Faruk Sami Bilgin (ORCID [0009-0001-9064-4410](https://orcid.org/0009-0001-9064-4410))

## The power problem

A gram-scale, laser-pushed spacecraft has about 30 cm² of external surface (2·(3×3) + 4·(3×1)), no maintenance, and a multi-decade mission running from full sunlight near 1 AU into deep-space darkness. Its load spans a deep-sleep floor of about 0.10 mW up to a 29.1 mW simultaneous peak (communication burst 22.3 mW). No continuous source the platform can carry covers the peaks, so the design target is not a bigger source but **banked energy** and **peak-event cadence**: a communication burst is treated as a fixed energy "bucket" (22.33 mW × 2 s ≈ 44.7 mJ) to be refilled between events.

## Energy-banking architecture (paper 1, `docs/`)

- **RTG baseline** (continuous; ~137 mW thermal, ~7.5 mW electrical in the draft's model).
- **Surface harvesting stack**: triple-junction / CsPbBr₃-class PV layer and a Bi₂Te₃/Sb₂Te₃ thermoelectric layer modelled as recovery of the RTG's *rejected* heat (no double counting), plus opportunistic piezoelectric, triboelectric and RF mechanisms that are explicitly **not budgeted**.
- **Per-source MPPT** (P&O for PV, fractional V_oc for TE, SSHI for piezo, charge pump for tribo, matched rectifier for RF) and power-domain combining instead of a series string.
- **Hybrid supercapacitor ∥ battery buffer**.
- **Dual-mode conversion**: flyback stage for the 3.3 V survival rail, boost stage drawing from the buffer for peak loads, arbitrated by a mission-phase finite-state machine with load shedding.

Numbers stated in the draft: RTG net surplus in cruise ≈ 7.09 mW (≈ 613 J/day); bucket refill time from the RTG alone ≈ 6.3 s; deep-cruise TE contribution ≈ 0.2–0.3 mW. **The quantitative cadence comparison against an RTG-only baseline is pending simulation**; the draft keeps it as an explicit `[SİM]` placeholder and no number is claimed here.

## Betavoltaic vs RTG mission profiles (paper 2, `docs/`)

The second draft makes the same backbone profile-agnostic (gated banking: a source is admitted only if it exceeds its own conditioning quiescent power; low-Iq buck-boost survival rail instead of an isolated flyback) and compares two deep-cruise sources:

| | Profile A: Ni-63 betavoltaic (max velocity) | Profile B: 150 mg Pu-238 RTG + high-ZT recovery (continuous science) |
|---|---|---|
| Terminal velocity (draft model) | 0.19c (minimal) … 0.14c (science) | 0.143c |
| Added mass | 0.1–0.9 g | 0.75 g |
| Deep-cruise power | ~0.7 µW (dormant) | ~5.7 mW (continuous) |

These are analytical, first-order estimates from the draft; circuit-level results are still marked `[SİM]`. `simulations/profile_comparison/` holds the script and figure used for the A/B comparison.

## Undergraduate thesis (`thesis/`)

*Investigation of Flyback Converter Types and Implementation of a Sample Application Circuit*: B.Sc. graduation project, Electrical Engineering, Yildiz Technical University, accepted June 2025. It surveys flyback converter types and implements a sample application circuit. The cover and jury pages were removed from the public copy (they carry an institutional ID number and signature blocks); the content is otherwise complete.

## Repository layout

| Path | Contents |
|---|---|
| `docs/` | Paper 1 draft and Turkish outline; paper 2 draft; Turkish notes on profiles A and B |
| `thesis/` | B.Sc. thesis PDF |
| `simulations/psim/` | PSIM schematics of the flyback and boost stages (`.psimsch`; large `.smv` result files not included) |
| `simulations/matlab_control/`, `simulations/supervised_control/` | MATLAB flyback controller studies (PI, MPC, fuzzy, H2/H∞/µ-synthesis, controller-dataset generators) |
| `simulations/profile_comparison/` | Python A/B profile comparison script and figure |
| `figures/` | Power-system, harvester and PMU PCB-layout SVGs; Mermaid control and block diagrams |
| `ui/` | Browser-based satellite power/swarm dashboard prototypes (single HTML files; load Chart.js and three.js from cdnjs) |

## Status

| Part | Status |
|---|---|
| Paper 1 (energy-banking architecture) | Conference paper draft, unpublished; simulation results pending |
| Paper 2 (betavoltaic vs RTG) | Conference paper draft, unpublished; some references still to be verified; simulation results pending |
| B.Sc. thesis | Completed and graded (2025) |
| PSIM / MATLAB models | Exploratory design files, not a validated hardware model |
| UI | Visual prototype; values shown are illustrative, not telemetry |

AI assistance: AI coding assistants were used for code development and for adversarial review. This repository has no automated test suite; the drafts and thesis are presented as written, and the author is responsible for every claim.

## License

Code (`simulations/`, `ui/`): MIT, see `LICENSE`. Text, figures and the thesis: CC BY 4.0, see `LICENSE-CONTENT`.
