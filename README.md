# Herbert – the misanthropical fly

This repo re-creates the 2011 iOS game by Etite, a two-person studio from Bern: Dani Rolli (design) and Christoph Ebert (code). It also aims to rebuild the game's websites.

**Play it:** https://herbert.ebrt.ch/game/ · Website: https://herbert.ebrt.ch/

| Folder | Contents |
|---|---|
| `app/` | Playable web re-creation of the game, using the original art and audio. See [app/README.md](app/README.md). |
| `web/` | The website: a placeholder landing page for now. The re-creations of the original herbert.etite.ch site and the remix album page are planned. |
| `original/` | The parts of the 2011 project the re-creation uses: game code, sprite sheets, audio, art, press kit, old websites and soundtrack. See [original/README.md](original/README.md). |
| `archive/` | The full original backups. Kept locally, not part of this repo. |

`app/tools/convert_assets.py` rebuilds `app/assets/` from `original/resources/`.

## Publishing

On every push to `main`, GitHub Pages publishes `web/` at the site root and `app/` under `/game/` (see `.github/workflows/pages.yml`).

## Credits

- Original game: Etite, Bern (2011)
- Soundtrack: Justin Lassen
- Lettering: akaDylan by James Milligan (akaType)

## License

The code is free for non-commercial use under the [PolyForm Noncommercial License 1.0.0](LICENSES/PolyForm-Noncommercial-1.0.0.md). The illustrations, sound and all other content are all rights reserved. Details and third-party credits are in [LICENSE.md](LICENSE.md).
