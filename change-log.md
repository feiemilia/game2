# Change Log

## 2026-11-25 — Reference-inspired Web presentation

- Added a responsive custom Godot Web shell inspired by the user reference: sky palette, rounded HUD, score/KEY progress, operation guidance, and mobile layout.
- Connected stage, score, key, and hint updates from both learning levels to the page HUD while preserving the existing finance puzzles and scoring rules.
- Excluded the standalone HTML shell source from the exported PCK; the Web preset uses it as the page shell.


## 2026-11-24 — Requirements baseline and design workflow

- Recorded the user's education priority, strong guessing/overload penalties, and local Web delivery scope.
- Added project brief, state ledger, and decision log to make the DT-SDLC / Design Thinking handoff traceable.
- Began the game-design concept tournament. No gameplay direction or visual style has been approved yet.

## 2026-11-24 — Godot Web export and GitHub deployment

- Added Godot 4.7.2 Web Release preset and exported the current incumbent game to `web-export/`.
- Added a local preview server and repeatable export command.
- Added a GitHub Pages Actions workflow and pushed the project plus Web build to `feiemilia/game2` on `main` (initial project commit `87ac6de`). Follow-up commits documented Pages setup and export verification. Blender portable runtime and Godot caches were excluded.
- GitHub Pages was enabled, and deployment run `45430656023` succeeded on 2026-11-24. The homepage and JS/WASM/PCK assets returned HTTP 200.
