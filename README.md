# Herbert – the misanthropical fly

This repo re-creates the 2011 iOS game by Etite, a two-person studio from Bern: Dani Rolli (design) and Christoph Ebert (code). It also aims to rebuild the game's websites.

| Folder | Contents |
|---|---|
| `app/` | Playable web re-creation of the game, using the original art and audio. See [app/README.md](app/README.md). |
| `web/` | The website: a placeholder landing page for now. The re-creations of the original herbert.etite.ch site and the remix album page are planned. |
| `archive/` | Original backups: the Cocos2d source, PSD/AI files, press kit and soundtrack. **Not in git.** It stays local only because of its size, the Apple certificate and the provisioning profiles. |

`app/tools/convert_assets.py` rebuilds `app/assets/` from `archive/`. The converted assets are committed, so the game runs without the archive.

## Publishing

On every push to `main`, GitHub Pages publishes `web/` at the site root and `app/` under `/game/` (see `.github/workflows/pages.yml`).

## Font

The game's lettering uses akaDylan by James Milligan (akaType, 2005). Its freeware license doesn't allow bundling the font file into another product, so the `.ttf` is not in this repo. `app/tools/build_bitmap_font.py` renders it from the local archive into the glyph sheet `app/assets/font/akadylan.png`.
