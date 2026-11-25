# Herbert – the misanthropical fly

This repo re-creates the 2011 iOS game by Etite, a two-person studio from Bern: Dani Rolli (design) and Christoph Ebert (code). It also aims to rebuild the game's websites.

| Folder | Contents |
|---|---|
| `app/` | Playable web re-creation of the game, using the original art and audio. See [app/README.md](app/README.md). |
| `web/` | The website: a placeholder landing page for now. The re-creations of the original herbert.etite.ch site and the remix album page are planned. |
| `archive/` | The original 2011 project files. Not part of this repo; the tools in `app/tools/` read from it. |

`app/tools/convert_assets.py` rebuilds `app/assets/` from `archive/`. The converted assets are committed, so the game runs without the archive.

## Publishing

On every push to `main`, GitHub Pages publishes `web/` at the site root and `app/` under `/game/` (see `.github/workflows/pages.yml`).

## Credits

- Original game: Etite, Bern (2011)
- Soundtrack: Justin Lassen
- Lettering: akaDylan by James Milligan (akaType)
