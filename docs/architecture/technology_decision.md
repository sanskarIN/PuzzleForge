# Technology Decision Record: Flutter and Dart

- Status: accepted
- Date: 2026-08-14
- Scope: Android-first PuzzleForge application

## Decision

Use Flutter 3.44.7 stable and Dart 3.12.2. Keep pure rule logic separate from Flutter UI and use platform plugins only at narrow service boundaries.

## Rationale

PuzzleForge needs custom 2D boards, strong semantics, adaptable layouts, localization, animation control, deterministic unit tests, and rapid Android iteration. Flutter satisfies those requirements with one coherent toolchain. Dart's immutable-data patterns and seeded `Random` support fit deterministic generators.

## Alternatives

- Godot offers a stronger traditional game loop but adds complexity for settings-heavy, semantics-rich application screens.
- Kotlin/Compose offers excellent native integration but slower future cross-platform expansion and more custom work for shared board rendering.
- Unity is unnecessary for the 2D offline scope and would increase runtime and licensing complexity.

## Consequences

The app uses Material 3 while drawing puzzle-specific components. Release builders must install the pinned Flutter version and JDK 17. The engine avoids depending on widget context so it can later be packaged or tested independently.
