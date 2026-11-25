# Remix page layout (2011 brief)

Specs from the original design brief for herbert.etite.ch/rmx.

**Layers.** The page centers these images at the top. They're listed from front to back; `p` means plus, `m` means minus:

| Layer | Image | Parallax (follows the mouse like the main Herbert site) |
|---|---|---|
| p2 | `layer_p2_downloadbtn.png` | moves right the most |
| p1 | `layer_p1_cover.png` | moves right a little less |
| 0 | `layer_0_logo_rmx.png` | doesn't move (the zero point) |
| m1 | `layer_m1_clouds.png` | moves left a little |
| m2 | `layer_m2_clouds.png` | moves left more |

`layer_m3_lightning.png` is also in `code/img/`, but the brief doesn't mention it.

**Grid.** Two columns of 384px make a 768px page. The grid is only used to align the footer images and the text.

**Footer:**
- 105px high, colored `#f5d94a`
- `footer_icon.png` and `footer_herbertgame.png` both sit right-aligned at the 768px edge, 35px from the bottom
- the icon links to the App Store page

**Colors.** The background is solid `#161616`. Shadows are solid `#696969`.

The share snippets, meta tags and track list are in `workflow/`. The finished page is in `code/`, and an identical copy is in `../web/rmx/`.
