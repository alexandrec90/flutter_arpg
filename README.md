# flutter_arpg

A new Flutter project.

---

## Design Doc: Elastic Combat — Isometric ARPG 🎮

### Concept

- **Isometric ARPG** focusing on **"Elastic Combat"** — fast, tactile, and expressive melee.

### Visual Identity 🎨

- **Style:** Minimalist Cyber‑Punk; thick outlines and silhouette-driven shapes.
- **Vibe:** High-speed smears, squash-and-stretch, impact frames.
- **Perspective:** Isometric (`2:1` ratio).

### Core Mechanics ⚔️

- **Snap Dash:** Character stretches during travel and squashes upon landing.
- **Kinetic Strikes:** Attacks use large triangular smear meshes for 2 frames.
- **Hit Stop:** `0.05s` game freeze on impact to emphasize hits.

> **Note:** Hit stop tuned to `0.05s` to create palpable impact without interrupting flow.

### Technical Stack 🛠️

- **Engine:** Flutter + Flame
- **Animation:** Rive (State Machines + Mesh Deform)
- **Logic:** Velocity-based stretching

### Implementation Notes 💡

- Tie Rive mesh deformation to character velocity for dynamic stretch/squash.
- Render kinetic smears as triangular mesh overlays timed to 2 frames.
- Centralize timing constants (e.g., hit stop) for consistent cross-platform behavior.

---

Contributions, feedback, and PRs welcome.

