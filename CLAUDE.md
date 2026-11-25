# CLAUDE.md

This repo re-creates the 2011 iOS game "Herbert – the misanthropical fly" (Etite, Bern). The owner co-wrote the original. The player-facing overview is in [README.md](README.md). The game design notes, controls and debug mode are in [app/README.md](app/README.md).

## Principles

- **Faithful to the original.** Gameplay values, positions, timings and animations come from the 2011 Cocos2d source in `archive/Herbert the Fly/Cocos 1.0.1/herbert/` (Oct 2011, the newest of the four copies). Before guessing how something worked, read the original code. Name the original file or method in a comment when the "why" isn't obvious.
- **Deviations need a decision.** If the original has a bug or an unfinished part (for example `Bibi2`), explain it and ask the owner before changing behavior. Record the decision in `app/README.md` → Prototype status.
- **Verify visually.** Most bugs here are visual: misplaced sprites, desynced animations. Check with screenshots, not only state.

## Layout

| Path | Contents |
|---|---|
| `app/` | The game. Phaser 3.80.1, vendored in `app/vendor/`. Plain ES modules, no build step. |
| `web/` | The site root at https://herbert.ebrt.ch/. Currently a placeholder landing page with Herbert's original first-person story. |
| `archive/` | The original 2011 project files: Cocos2d source, art sources, the 12-track OST and `wayback-snapshots/` of the old websites. **Gitignored, local only.** Never commit it, and don't describe its contents beyond this in public files. |

| File in `app/src/` | Role |
|---|---|
| `data.js` | All ported numbers: enemies, weapons, items, unlocks, the speed table |
| `game.js` | The game scene |
| `herbert.js` | Herbert's multi-part rig |
| `scenes.js` | Boot, menu and game-over scenes |
| `collide.js` | SAT polygon overlap for the original Box2D shapes |
| `debug.js` | The `?debug` panel |
| `ui.js` | Settings, storage, labels, camera zoom, asset versioning |

`app/tools/convert_assets.py` and `app/tools/build_bitmap_font.py` regenerate `app/assets/` from `archive/`.

## Converting original values

The original ran at 480×320 points with y up, and cocos anchor points. This game runs in 960×640 world units with y down, so:

- **Points and offsets:** a point offset `(x, y)` becomes `(2x, -2y)`. Distances and speeds double (`S = 2` in `data.js`).
- **Anchors:** `anchorPoint (ax, ay)` becomes Phaser `setOrigin(ax, 1 - ay)`. Anchors outside 0..1 are real; that's how bullets appear at the barrel tip.
- **Child sprites:** cocos children are positioned from the parent's bottom-left corner, not its center.
- **Rotation:** cocos rotation and Phaser angle are both clockwise in degrees, so values carry over unchanged.

## Gotchas we already hit

- **Scene reuse:** Phaser reuses the scene object on restart. Anything created lazily (sprites, graphics, sounds) must be reset in `GameScene.create()`. See the `Object.assign(this, { ... })` reset block there.
- **Rig sync:** Herbert's body, snout and legs are separate 8-frame loops. Every animation change must restart them together (`Herbert.refreshBody`).
- **High-DPI rendering:** high-DPI screens render at 2x through zoomed cameras (`ZOOM` in `ui.js`). Convert pointer positions with `worldPoint()`, never `pointer.x`/`downX` directly.
- **Font file:** never commit the akaDylan `.ttf`. The game ships only the rendered glyph sheet built by `app/tools/build_bitmap_font.py`. Keep the lettering credit in `README.md` and on the landing page.
- **Caching:** GitHub Pages caches each file for 10 minutes. The deploy workflow stamps `?v=<commit>` onto all module URLs, and `asset()` in `ui.js` adds it to assets. New loaders must use `asset()`.

## Run and verify

- **Run locally:** `cd app && python3 -m http.server 8765`, then open http://localhost:8765/?debug.
- **Debug panel:** it can equip any gun, apply items, spawn enemies, and toggle god mode, infinite ammo, spawns and hitboxes. It's the quickest way to reproduce a report.
- **Automated checks:** these have so far been throwaway Playwright scripts using the system Chrome (`channel: 'chrome'`, at deviceScaleFactor 1 and 2). They covered: a bot playthrough to game over, firing every gun twice, the debug toggles, and screenshots of the affected feature.

## Git and deploy

- **Remote:** the public repo is https://github.com/chr1gu/herbert-the-fly-original, on branch `main`.
- **Commit identity:** this repo's local git config sets the noreply email `610551+chr1gu@users.noreply.github.com`. The global git config uses the owner's work email, which must never appear in this public history. Check `git config user.email` before committing.
- **Deploy:** every push to `main` deploys through `.github/workflows/pages.yml`, with separate build and deploy jobs. A single job intermittently failed to find the artifact.
- **Domain:** `herbert.ebrt.ch` is a Cloudflare CNAME to `chr1gu.github.io` set to DNS only, with HTTPS enforced. `chr1gu/herbert-the-fly-original-old-private` is a stale private copy that can be deleted.

## Backlog

- **Website re-creation in `web/`:** rebuild the original landing page (`archive/web`) and the remix album page at `/rmx` (`archive/herbert_rmx`, with mouse-parallax layers). Add the 12 OST MP3s as downloads at that point, from `archive/Justin Lassen Presents Herbert Original Soundtrack`; the owner wants them added then, not before. The remix album audio isn't in the backups and still has to be found.
- **Original features not ported yet:** the 3-part tutorial (`TutorialBriefing`), options, credits, named highscores and the language-choice screen.
- **Long-term platform:** web vs native/engine is still undecided. Ask before committing to one.
