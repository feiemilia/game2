# Decision Log

## D-001 — Education and delivery priorities

- Date: 2026-11-24
- Decision owner: user
- Status: confirmed
- Learning priority: Learning-first profile (wL=.50, wE=.15, wM=.10, wA=.25).
- Guessing/exploitation penalty pG=.30 and cognitive-overload penalty pC=.30 (maximum diagnostic penalties).
- The user specified strong penalties but did not request hard-gate thresholds; therefore G/C remain severe penalties with explicit review flags, not hard gates.
- Local Web export files are required; public hosting is not requested.
- Evidence mapping frozen before concept scoring: L=pre/post matched prompt accuracy and explanation/strategy quality; E=completion and voluntary replay interpreted with context; M=brief competence/retry self-report; A=task success, recoverable errors, and help use; G=random/rapid answer patterns, answer copying, or skipping reasoning; C=confusion reports, instruction rereads, repeated errors, and inability to explain choices.

## D-002 — Existing game is an incumbent, not an approved winner

- Date: 2026-11-24
- Status: recorded
- Prior project implementation may be included in the tournament as the incumbent. Formal gameplay approval remains with the user after seeing the blind shortlist.

## D-003 — Reference handling

- Date: 2026-11-24
- Status: confirmed from user brief
- The supplied game page/images guide atmosphere and broad visual tone only. Create original characters, props, and room layouts.

## D-004 — Public GitHub deployment

- Date: 2026-11-24
- Decision owner: user
- Status: confirmed
- Supersedes the earlier no-public-hosting assumption: deploy the project and Web build to `https://github.com/feiemilia/game2.git`, and publish the Web build through GitHub Pages.
- Repository `main` received the initial project commit. GitHub currently reports Pages disabled; its first run stopped at the Pages configuration step. Repository owner must set Pages Source to GitHub Actions before rerunning.
