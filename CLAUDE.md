# Flutter ARPG - Project Instructions

> Read by Claude Code and GitHub Copilot. Single source of truth for AI assistant context.
> See also: `.claude/rules/` for file-scoped coding and testing rules.

## Project Overview

A 2D isometric action RPG built with Flutter and Flame, focused on **"Elastic Combat"** -- fast, tactile melee with squash-and-stretch animation, hit-stop impact frames, and triangular smear VFX. The player moves with WASD/arrows, dashes with Space, shoots projectiles on click, and fights simple chase-AI enemies.

Design doc: `docs/design.md`

## Tech Stack

- **Framework**: Flutter (Dart SDK ^3.10.8)
- **Game Engine**: Flame ^1.35.0
- **Animation**: Rive ^0.14.2 (planned for mesh deformation; not yet wired up)
- **Linting**: `flutter_lints` ^6.0.0
- **State Management**: None -- game state lives directly on Flame components
- **Platforms**: Scaffolded for Android, iOS, web, Windows, macOS, Linux (primary dev/testing on desktop)

## Project Structure

```text
lib/
  main.dart                      # App entry, fullscreen setup, tap-to-shoot wiring
  arpg_game.dart                 # ARPGGame (FlameGame subclass) -- world, camera, spawning
  game_actions.dart              # GameActions interface (spawnProjectile, hitStop, reset, ...)
  components/
    player_component.dart        # Player: movement, dash, collision, keyboard input, rendering
    enemy_component.dart         # Enemy: chase AI, separation, damage, rendering
    projectile_component.dart    # Projectile: travel, enemy hit detection, smear + hit-stop
    smear_component.dart         # Triangular smear VFX (2-frame lifetime)
  config/
    constants.dart               # All tuning values (speeds, sizes, damage, colors, durations)
    input_bindings.dart          # Keyboard bindings (WASD/arrows, Space=dash, R=reset)
test/
  constants_test.dart            # Sanity tests for constants (positive values, independent copies)
docs/
  design.md                      # Design document with concept, visual identity, mechanics
```

## Architecture & Key Patterns

- **Component architecture**: `ARPGGame` extends `FlameGame`. All entities are `PositionComponent` subclasses living in `game.world`. Components access the game via `HasGameReference<FlameGame>`.
- **GameActions interface**: Components call game-level actions (`spawnProjectile`, `hitStop`, `spawnSmear`, `reset`) through the `GameActions` abstract class, keeping components decoupled from the concrete game class. Usage pattern: `if (game is GameActions) (game as GameActions).hitStop()`.
- **Centralized constants**: All tuning values live in `lib/config/constants.dart` as static members on dedicated classes (`GameConstants`, `PlayerConstants`, `EnemyConstants`, `ProjectileConstants`, `SmearConstants`, `CameraConstants`). Never hard-code magic numbers in components.
- **Input bindings**: Keyboard controls are centralized in `InputBindings` (not hard-coded in components). Currently immutable with `defaultBindings`; designed to be user-editable later.
- **Vector2 defensiveness**: Getter-based `Vector2` properties (like `playerStartPosition`) return fresh instances to prevent shared-mutation bugs. Always `.clone()` positions when passing them to new components.

## Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Methods/variables: `camelCase`
- Private members: prefix with `_`
- Use `const` constructors where possible; prefer `final` for non-reassigned variables
- Avoid `dynamic` -- use strong typing
- See `.claude/rules/code-style.md` and `.claude/rules/testing.md` for additional rules

## Git Workflow

- **Main branch**: `master`
- Branch from `master` for feature work
- Run `flutter analyze` and `flutter test` before committing -- both must pass clean

## Common Commands

```bash
flutter run                    # Run the app (fullscreen game)
flutter test                   # Run tests
flutter analyze                # Run static analysis (must pass before committing)
flutter format .               # Format all Dart files
flutter build apk              # Build Android APK
```

## Important Conventions

- New tuning values (speeds, sizes, durations, colors) go in `lib/config/constants.dart`, not inline
- New game-level actions go through the `GameActions` interface
- New entities should be `PositionComponent` subclasses added to `game.world`
- Test files follow `<source_file>_test.dart` naming in `test/`
- Keyboard controls go through `InputBindings`, not direct key checks

## Documentation Lookup

A pre-baked Flame ^1.35.0 API reference lives in `.claude/rules/flame-docs.md`.
Use it as the primary source when writing or modifying game code.

Only fetch live docs (via the `fetch` MCP tool) when:

- The API is **not covered** in the pre-baked reference
- **Upgrading Flame** to a new version (then update the rule too)
- Working with **Rive** (not yet pre-baked — Rive integration hasn't started)

Reference docs (for live fetching):

- **Flame**: <https://docs.flame-engine.org/latest/>
- **Rive (Flutter)**: <https://rive.app/docs/>
- **Flutter**: <https://api.flutter.dev/>
- **Dart**: <https://api.dart.dev/>

## Known Issues & Gotchas

- Rive is declared as a dependency but not yet integrated -- all visuals are procedural Canvas drawing
- Tap-to-shoot is wired in `main.dart` via `GestureDetector` wrapping `GameWidget`, not through Flame's built-in tap handling
- `hitStop()` uses `pauseEngine()`/`resumeEngine()` with a `Future.delayed` -- this pauses the entire game, not just a single entity
- No asset loading yet -- all visuals are Canvas primitives (circles, rounded rects, paths)
- The game runs fullscreen (`Flame.device.fullScreen()`) with no UI overlay or HUD
