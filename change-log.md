# Change Log

## 2026-11-24 — Requirements baseline and design workflow

- Recorded the user's education priority, strong guessing/overload penalties, and local Web delivery scope.
- Added project brief, state ledger, and decision log to make the DT-SDLC / Design Thinking handoff traceable.
- Began the game-design concept tournament. No gameplay direction or visual style has been approved yet.

## 2026-11-24 — Godot Web export and GitHub deployment

- Added Godot 4.7.2 Web Release preset and exported the current incumbent game to `web-export/`.
- Added a local preview server and repeatable export command.
- Added a GitHub Pages Actions workflow and pushed the project plus Web build to `feiemilia/game2` on `main` (commit `87ac6de`). Blender portable runtime and Godot caches were excluded.
- GitHub Pages is disabled in repository settings. The first deploy run (`45413713178`) stopped at Configure GitHub Pages; configure Pages Source as GitHub Actions, then rerun.
