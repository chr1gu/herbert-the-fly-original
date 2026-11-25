import { W, H } from './data.js';
import { BootScene, MenuScene, GameOverScene } from './scenes.js';
import { GameScene } from './game.js';
import { ZOOM } from './ui.js';

const game = new Phaser.Game({
  type: Phaser.AUTO,
  parent: 'game',
  width: W * ZOOM,
  height: H * ZOOM,
  backgroundColor: '#f6fdff',
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  input: { activePointers: 3 },
  // Text and sprites are drawn well below their 64px/retina source size; mipmaps keep them smooth.
  render: { mipmapFilter: 'LINEAR_MIPMAP_LINEAR' },
  scene: [BootScene, MenuScene, GameScene, GameOverScene],
});

// iOS only delivers tilt events after an explicit permission prompt from a user gesture.
window.addEventListener('pointerdown', () => {
  if (typeof DeviceOrientationEvent?.requestPermission === 'function') {
    DeviceOrientationEvent.requestPermission().catch(() => {});
  }
}, { once: true });

window.herbert = game;
