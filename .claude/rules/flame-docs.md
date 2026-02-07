---
globs: lib/**/*.dart
---

Use this pre-baked Flame API reference (for Flame ^1.35.0) when writing or modifying
game code. Only fetch live docs for APIs not covered here or when upgrading Flame.

Live docs (for anything not covered below):

- Flame: <https://docs.flame-engine.org/latest/>
- Rive Flutter: <https://rive.app/docs/runtimes/flutter/>

---

## FlameGame

Extends `Game`. The top-level game class with a built-in `world` and `camera`.

```dart
class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks {
  // ...
}
```

**Key properties:**

| Property | Type | Description |
|----------|------|-------------|
| world | World | Default world; add all game entities here |
| camera | CameraComponent | Default camera paired with world |
| size | Vector2 | Current viewport size |
| paused | bool | Whether the game loop is paused |
| isMounted | bool | Whether the game has been mounted |

**Lifecycle methods:**

```dart
Future<void> onLoad() async {}    // Async init (runs once)
void update(double dt) {}         // Per-tick logic
void render(Canvas canvas) {}     // Drawing
void onGameResize(Vector2 size) {} // Viewport resize
```

**Engine control:**

```dart
void pauseEngine()    // Pause game loop
void resumeEngine()   // Resume game loop
```

---

## PositionComponent

Base class for all positioned game entities.

**Constructor:**

```dart
PositionComponent({
  Vector2? position,          // default: Vector2(0, 0)
  Vector2? size,
  Vector2? scale,             // default: Vector2(1, 1)
  double? angle,              // radians, default: 0
  double? nativeAngle,        // default: 0
  Anchor? anchor,             // default: Anchor.topLeft
  int? priority,              // z-index, default: 0
  List<Component>? children,
  ComponentKey? key,
})
```

**Key properties:**

| Property | Type | Description |
|----------|------|-------------|
| position | Vector2 | Anchor location relative to parent |
| size | Vector2 | Dimensions (unaffected by parent scale) |
| scale | Vector2 | Scale multiplier for component + children |
| angle | double | Rotation around anchor (radians) |
| anchor | Anchor | Reference point (topLeft, center, etc.) |
| priority | int | Render order (higher = front) |
| parent | Component? | Parent in component tree |
| children | ComponentSet | Child components |
| isMounted | bool | Whether currently in the tree |

**Lifecycle methods:**

```dart
Future<void> onLoad() async {}              // Async init (once)
void onMount() {}                            // Added to tree
void onRemove() {}                           // Before removal
void onGameResize(Vector2 size) {}           // Screen resize
void onParentResize(Vector2 size) {}         // Parent resized
void update(double dt) {}                    // Per-tick
void render(Canvas canvas) {}                // Draw (origin at top-left of component)
```

**Important methods:**

```dart
void add(Component c)                        // Add child
void addAll(List<Component> cs)              // Add multiple children
void remove(Component c)                     // Remove child
void removeFromParent()                      // Remove self from parent
FlameGame findGame()                         // Get game instance
Iterable<Component> ancestors()              // Ancestor chain
Rect toRect()                                // Bounding box
void flipHorizontally()                      // Mirror around anchor
void flipVertically()                        // Flip around anchor
```

**Rendering note:** `render()` receives a canvas with origin at the component's
top-left (0,0). Position, angle, and scale transforms are applied automatically.
Draw relative to (0,0), not screen coordinates.

---

## HasGameReference\<T>

Mixin giving a component access to the game instance.

```dart
class MyComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  void example() {
    game.world;       // Access the world
    game.camera;      // Access the camera
    game.pauseEngine();
  }
}
```

The `game` getter returns the typed game instance. Throws if accessed before mounting.

---

## CameraComponent

Renders a World through a viewport. Default instance available as `game.camera`.

**Key children:**

| Child | Type | Purpose |
|-------|------|---------|
| viewfinder | Viewfinder | Controls position, zoom, angle |
| viewport | Viewport | The visible window |

**Viewfinder properties:**

```dart
camera.viewfinder.position   // Vector2 — where camera looks in world
camera.viewfinder.zoom       // double — zoom level (1.0 = default)
camera.viewfinder.anchor     // Anchor — logical center of viewport
camera.viewfinder.angle      // double — rotation in radians
```

**Methods:**

```dart
// Follow a component (smooth tracking)
camera.follow(
  PositionComponent target,
  {double maxSpeed = double.infinity,  // pixels/sec cap
   bool horizontalOnly = false,
   bool verticalOnly = false,
   bool snap = false}                  // instant jump to target
);

// Constrain camera to world bounds
camera.setBounds(
  Shape bounds,                // e.g. Rectangle.fromLTWH(0, 0, w, h)
  {bool considerViewport = false}
);

// Coordinate conversion
Vector2 globalToLocal(Vector2 point)   // Screen -> world coords
Vector2 localToGlobal(Vector2 point)   // World -> screen coords

// Movement
camera.moveTo(Vector2 point)
camera.moveBy(Vector2 offset)
camera.stop()                          // Stop following/moving

// Query
bool canSee(PositionComponent c)       // Is component visible?
Rect get visibleWorldRect              // Currently visible area
```

---

## Keyboard Input

**Game-level:** Mix `HasKeyboardHandlerComponents` into `FlameGame` to enable
keyboard events on components.

**Component-level:** Mix `KeyboardHandler` into any component:

```dart
class Player extends PositionComponent with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // event types: KeyDownEvent, KeyUpEvent, KeyRepeatEvent
    // Return true to propagate, false to consume
    return true;
  }
}
```

**Important:** Do not mix both `KeyboardEvents` (game-level) and
`HasKeyboardHandlerComponents` on the same game — they conflict.

---

## Tap Events

**On components:** Mix `TapCallbacks` into any `PositionComponent`:

```dart
class MyComponent extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    event.localPosition;    // In component's local space
    event.canvasPosition;   // In game canvas space
    event.pointerId;        // Multi-touch ID
    event.continuePropagation = true;  // Pass to components below
  }

  @override
  void onTapUp(TapUpEvent event) {}

  @override
  void onTapCancel(TapCancelEvent event) {}

  @override
  void onLongTapDown(TapDownEvent event) {}  // 300ms hold
}
```

**On game:** Mix `TapCallbacks` into `FlameGame` for global taps.

**Alternative:** Wrap `GameWidget` with Flutter's `GestureDetector` and use
`camera.globalToLocal()` to convert screen taps to world coordinates.

---

## Collision Detection

**Enable on game:**

```dart
class MyGame extends FlameGame with HasCollisionDetection {}
```

**On components:** Mix `CollisionCallbacks` and add hitbox children:

```dart
class MyEntity extends PositionComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    add(CircleHitbox());              // Fills parent size
    // or: add(RectangleHitbox());
    // or: add(PolygonHitbox(vertices));
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {}

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {}

  @override
  void onCollisionEnd(PositionComponent other) {}
}
```

**CollisionType** (on hitboxes):

| Type | Behavior |
|------|----------|
| active | Collides with active + passive (default) |
| passive | Only collides with active (static objects) |
| inactive | No collision checks |

**ScreenHitbox:** `add(ScreenHitbox())` for viewport-edge collisions.

---

## GameWidget

Flutter widget that renders a Flame game.

```dart
GameWidget(
  game: myGame,                          // Required: Game instance
  overlayBuilderMap: {'hud': (ctx, game) => HudWidget()},
  initialActiveOverlays: ['hud'],
  loadingBuilder: (ctx) => LoadingWidget(),
  errorBuilder: (ctx, error) => ErrorWidget(),
  autofocus: true,                       // Default: true
)
```

**Note:** GameWidget does not clip canvas content. Wrap with `ClipRect` if needed.

**Overlays** (controlled from game code):

```dart
game.overlays.add('hud');
game.overlays.remove('hud');
```

---

## Common Anchor Values

| Anchor | Description |
|--------|-------------|
| Anchor.topLeft | Default for PositionComponent |
| Anchor.center | Position = visual center |
| Anchor.topCenter, bottomCenter, etc. | Edge anchors |

---

## Vector2 Quick Reference

```dart
Vector2.zero()                // (0, 0)
Vector2.all(v)                // (v, v)
Vector2(x, y)                 // Explicit
v.clone()                     // Defensive copy
v.length                      // Magnitude
v.normalized()                // Unit vector (new instance)
v.normalize()                 // Mutates in place
v.distanceTo(other)           // Distance between two vectors
v.setFrom(other)              // Copy values from another vector
v.clamp(min, max)             // Clamp each component
```
