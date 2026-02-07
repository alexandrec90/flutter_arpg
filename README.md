# Flutter ARPG -- Elastic Combat

A 2D isometric action RPG built with **Flutter** and **Flame**, focused on fast, tactile melee combat with squash-and-stretch animation, hit-stop impact frames, and triangular smear VFX.

## Getting Started

### Prerequisites

- Flutter SDK (Dart ^3.10.8)
- A desktop, mobile, or web target configured for Flutter

### Run

```bash
flutter pub get
flutter run
```

The game launches fullscreen. Controls:

| Input             | Action                         |
| ----------------- | ------------------------------ |
| WASD / Arrow keys | Move                           |
| Space             | Dash                           |
| Click             | Shoot projectile toward cursor |
| R                 | Reset                          |

### Test & Lint

```bash
flutter test
flutter analyze
flutter format .
```

## Project Structure

```text
lib/
  main.dart              # Entry point and tap-to-shoot wiring
  arpg_game.dart         # FlameGame subclass -- world, camera, spawning
  game_actions.dart      # Interface for game-level actions
  components/            # Player, enemy, projectile, smear VFX
  config/                # Constants and input bindings
test/                    # Unit tests
docs/design.md           # Design document (concept, mechanics, tech stack)
```

## Contributing

- Fork the repo and work on a feature branch off `master`.
- Keep changes small and focused; open issues for large proposals first.
- Follow the existing code style and lint rules (see `analysis_options.yaml`).
- Add tests when adding logic or gameplay features.
- Run `flutter format .` and `flutter analyze` before opening a PR.
