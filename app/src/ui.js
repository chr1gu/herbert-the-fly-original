import { W, H } from './data.js';

// Game logic runs in 960x640 world units. On high-DPI screens the canvas renders at 2x
// and every camera zooms in, so text and sprites stay sharp instead of being upscaled.
export const ZOOM = Math.min(2, Math.max(1, Math.round(window.devicePixelRatio || 1)));

export function setupCamera(scene) {
  scene.cameras.main.setZoom(ZOOM).centerOn(W / 2, H / 2);
}

export function worldPoint(scene, pointer, useDown = false) {
  return scene.cameras.main.getWorldPoint(useDown ? pointer.downX : pointer.x, useDown ? pointer.downY : pointer.y);
}

export const settings = {
  get lang() { return store.get('lang', 'en'); },
  set lang(v) { store.set('lang', v); },
  get music() { return store.get('music', true); },
  set music(v) { store.set('music', v); },
  get sfx() { return store.get('sfx', true); },
  set sfx(v) { store.set('sfx', v); },
};

export const store = {
  get(key, fallback) {
    try {
      const v = localStorage.getItem(`herbert.${key}`);
      return v === null ? fallback : JSON.parse(v);
    } catch { return fallback; }
  },
  set(key, value) {
    try { localStorage.setItem(`herbert.${key}`, JSON.stringify(value)); } catch { /* storage unavailable */ }
  },
};

// Glyphs are white with a dark outline, so a tint recolors the fill and keeps the outline dark.
export function label(scene, x, y, text, size = 40, color = 0xffffff) {
  return scene.add.bitmapText(x, y, 'akadylan', String(text), size).setOrigin(0.5).setTint(color);
}
