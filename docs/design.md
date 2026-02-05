# Design Doc: Elastic Combat — Isometric ARPG 🎮

## Concept
Isometric ARPG focused on **"Elastic Combat"** — fast, tactile, and expressive melee.

## Visual Identity 🎨
- **Style:** Minimalist Cyber‑Punk; thick outlines and silhouette-driven shapes.
- **Vibe:** High-speed smears, squash-and-stretch, impact frames.
- **Perspective:** Isometric (2:1 ratio).

## Core Mechanics ⚔️
- **Snap Dash:** Character stretches during travel and squashes upon landing.
- **Kinetic Strikes:** Attacks use large triangular smear meshes for 2 frames.
- **Hit Stop:** 0.05s game freeze on impact to emphasize hits.

## Technical Stack 🛠️
- **Engine:** Flutter + Flame
- **Animation:** Rive (State Machines + Mesh Deform)
- **Logic:** Velocity-based stretching

## Implementation Notes 💡
- Drive Rive mesh deformation from character velocity for dynamic stretch/squash.
- Render kinetic smears as triangular mesh overlays timed precisely to 2 frames.
- Centralize timing constants (e.g., hit stop) for consistent cross-platform behavior.
- Keep assets and animation state machines well-documented in `assets/` and `docs/`.

---

*Maintainers:* add ideas, diagrams, and profiling notes here. PRs welcome.