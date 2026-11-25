# Herbert – the misanthropical fly (web prototype)

A browser rebuild of the 2011 iOS game (Etite, Bern; v1.2, Oct 2011), using the original art and audio. The gameplay numbers come from the Cocos2d source in `../archive/Herbert the Fly/Cocos 1.0.1/herbert` (Oct 15 2011, the newest of the four copies).

## Run

```sh
cd ~/Development/herbert-the-fly-original/app
python3 -m http.server 8765    # then open http://localhost:8765
```

To regenerate `assets/` from the original resources, run `python3 tools/convert_assets.py` (needs `ffmpeg`) and `python3 tools/build_bitmap_font.py` (needs Pillow). Both read from `../archive/`.

**Controls**

| Action | Input |
|---|---|
| Fly up/down | `W`/`S` or arrow keys, device tilt, or dragging along the left screen edge |
| Shoot | Click or tap and hold; Herbert fires toward the pointer |
| Pause | `P` or `Esc`, then `M` for the menu |

## Debug mode

Add `?debug` to the URL, for example https://herbert.ebrt.ch/game/?debug or http://localhost:8765/?debug. A panel at the top right lets you:

| Section | Actions |
|---|---|
| Run | Start or restart a run, jump to the next speed level, kill all enemies, die |
| Toggles | God mode, infinite ammo, stop enemy spawns, show hitboxes |
| Weapons | Equip any of the 11 guns |
| Items | Apply the protection suit, LSD star, cappuccino or coin directly, or drop pickups to collect |
| Health | Heal fully, or take 50 damage |
| Spawn enemy | Spawn any of the 11 enemy types |
| Save data | Unlock all items, or reset unlocks and highscore |

The bottom of the panel shows HP, points, speed level, gun, ammo and object counts. Click the panel header to collapse it.

## What the game actually is

It is not a platformer. It's an endless, horizontally scrolling, one-screen shooter in the spirit of a "tilt & tap" arcade game.

- **Story:** Herbert is a fat mayfly (Eintagsfliege) having the worst day of his one-day life. He loses his job, and his wife leaves him for "one of these yellow balloonheads" (the Bibi birds). He freaks out. You don't play Herbert, you only *control* him.
- **Layout:** Herbert stays at the left edge (x = 40pt). Enemies and pickups drift in from the right over a sky gradient with parallax clouds.
- **Controls (iOS):** the accelerometer sets Herbert's height, and a tap fires toward the touch point. v1.2 added auto-fire on touch-move.
- **Health:** 300 HP. The sky gradient darkens in 6 steps as HP drops. Ramming an enemy kills it, scores its points, *and* costs HP.
- **Difficulty is music-driven:** every 14.7 s background loop that ends raises the level by one. Every second level speeds the game up (1.0 → 1.5 → 2.0 … → 4.25×), spawns enemies faster, adds new enemy types, and switches to the next `bg_loopN` track.
- **Score:** +25 per spawn tick, +20 per hit, enemy points on a kill, +150 per rocket hit, +200 per coin.
- **Unlocks persist between runs:** passing 5k / 10k / 20k / 40k points unlocks new pickups, each shown with a "new gun unlocked" message.

### Enemies

There are 11 classes. Most come in 2–3 color variants, which explains the App Store's "20 unique enemies".

| Enemy | HP | Damage | Points | From level |
|---|---|---|---|---|
| FlyFred, FlySina, BugOona, BugLina | 2–6 | 50–100 | 118–575 | 0 |
| BugGilbert (follows Herbert), Bibi/Bibi2 (birds, can poop) | 2 / 10 | 50 / 150 | 55 / 999 | 2 |
| Fuckbutton, LadyBug | 1 / 5 | 50 / 100 | 251 / 332 | 4 |
| FlyBob, FlyRobert | 4 / 1 | 100 / 50 | 213 / 69 | 6 |

### Weapons

The default weapon is the "Gagi" (a poop ball shot from Herbert's snout) with infinite ammo. The other 10 are pickups:

| Weapon | Ammo | Behavior |
|---|---|---|
| Kalaschnikov | 25 | Rapid fire |
| Lasergun | 30 | Continuous beam |
| Minigun | 50 | Spins up first, then sprays |
| Pumpgun | 8 | 6-pellet spread |
| Rocketlauncher | 5 | Explosive, with area damage |
| Rainbowgun | 45 | Beam |
| Tabasco | 15 | Single shots |
| Flygun | 5 | Fires 3 homing flies per shot |
| Übergun | 3 | Lightning that kills everything on screen |
| Bugspray | 30 | Short-range poison cloud |

### Items

| Item | Effect |
|---|---|
| Cappuccino ("Caposhito") | +100 HP |
| Protection suit | Absorbs one hit |
| Coin | +200 points |
| LSD star | 5 s drug mode: double speed, invincible, rainbow trail, spinning psychedelic background, drug-mode music, no shooting |

### Other original features not in the prototype yet

- A 3-part tutorial: a target, then dodging birds, then a bird showdown
- Highscores with a player name
- Facebook score sharing
- Options for music and SFX
- Credits
- A "5 lives" lite edition with a buy screen
- An iPad build
- A sponsor overlay (Red Bull "guerilla tour")
- Language choice: EN, DE, and Berndeutsch (CH). It was marketed as perhaps the first game playable fully in Bernese German.

## Prototype status

**Ported:** the core loop, all 11 enemy types with their stats and spawn tiers, all 11 weapons, the 4 items, LSD mode, the protection suit, persistent unlocks, the music-driven speed-ups, the health-tinted sky, parallax clouds and the rainbow, the countdown, pause, game over with highscore, and EN/DE/CH flash messages.

**Approximated:**
- Enemy zig-zag flight, simplified from the per-frame easing.
- Collision radii. The original used Box2D sprite boxes.
- Beam damage is ticked per 0.1 s.
- Weapon muzzle points.
