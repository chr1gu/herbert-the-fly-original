import { W, H } from './data.js';
import { BootScene, MenuScene, GameOverScene } from './scenes.js';
import { GameScene } from './game.js';

const game = new Phaser.Game({
  type: Phaser.AUTO,
  parent: 'game',
  width: W,
  height: H,
  backgroundColor: '#f6fdff',
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  input: { activePointers: 3 },
  scene: [BootScene, MenuScene, GameScene, GameOverScene],
});

// iOS only delivers tilt events after an explicit permission prompt from a user gesture.
window.addEventListener('pointerdown', () => {
  if (typeof DeviceOrientationEvent?.requestPermission === 'function') {
    DeviceOrientationEvent.requestPermission().catch(() => {});
  }
}, { once: true });

window.herbert = game;
