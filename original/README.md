# original

This folder holds the parts of the 2011 project that the re-creation still uses. Everything else stays in the local, untracked `archive/`, including the iOS project files, builds, signing files, PSD/AI sources, scans and older code copies.

| Folder | Contents | Used by |
|---|---|---|
| `source/` | The newest game code (Oct 2011, v1.2): Cocos2d + Box2D, Objective-C. The Facebook SDK and the engine libraries are not included. | The reference for every ported value and behavior |
| `resources/` | Retina sprite sheets (`_retina/`, TexturePacker plists) and the `.caf` audio | `app/tools/convert_assets.py` |
| `art-ipad3/` | All game art as single PNGs at iPad 3 resolution, about 2x the retina sheets | A possible sharper art upgrade |
| `press/` | Logo and characters, screenshots, the Swiss trailer, portfolio images, and the German press text (`infotext_de.txt`, without the contact details and bios) | Website re-creation |
| `web/` | The 2011 game website (app.etite.ch/herbert), with its `fb/` and `rmx/` pages. `wayback-snapshots/` holds archived copies of the old sites and the App Store page | Website re-creation |
| `web-rmx/` | The remix album page project. `LAYOUT.md` has the design specs | `/rmx` re-creation |
| `soundtrack/` | "Justin Lassen Presents Herbert Original Soundtrack": 12 MP3s, covers and a playlist | Downloads on `/rmx` |

The lettering font (akaDylan) isn't included. The game uses a rendered glyph sheet built from a local copy (`app/tools/build_bitmap_font.py`).
