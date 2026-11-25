import { W, H, LANGS, TEXT } from './data.js';

const ATLASES = ['clct_herbert', 'clct_bugsgads', 'clct_ingame', 'clct_mm', 'clct_tutorial'];
const IMAGES = ['drugmode', 'rainbow_start', 'mm_bg', 'mm_gameover_bg', 'uber-lightning0', 'uber-lightning2', 'uber-lightning3', 'health_life'];
const MUSIC = ['bg_mm', 'bg_gameover', 'bg_drugmode', ...Array.from({ length: 11 }, (_, i) => `bg_loop${i}`)];
const SFX = {
  herb: ['herbert_bzzt1', 'herbert_bzzt2', 'pewpew', 'shitoccino0', 'shitoccino1', 'shitoccino2'],
  enemies: ['birdy_coming', 'birdy_death', 'bug_hit0', 'bug_hit1', 'bug_hit2'],
  items: ['coin_up', 'menu', 'protectionsuit_on', 'protectionsuit_out', 'weapon_up'],
  wpns: ['boom', 'bugspray', 'flygun', 'kalaschnikov', 'lasergun', 'minigun', 'pumpgun_load', 'pumpgun_shot', 'rainbowgun', 'rocketlauncher', 'ubergun'],
};

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

export class BootScene extends Phaser.Scene {
  constructor() { super('boot'); }

  preload() {
    const bar = this.add.rectangle(W / 2 - 200, H / 2, 0, 16, 0xf5d94a).setOrigin(0, 0.5);
    this.add.rectangle(W / 2, H / 2, 404, 20).setStrokeStyle(2, 0x222222);
    this.load.on('progress', (p) => { bar.width = 400 * p; });

    ATLASES.forEach((a) => this.load.atlas(a, `assets/atlas/${a}.png`, `assets/atlas/${a}.json`));
    IMAGES.forEach((i) => this.load.image(i, `assets/img/${i}.png`));
    this.load.bitmapFont('akadylan', 'assets/font/akadylan.png', 'assets/font/akadylan.xml');
    MUSIC.forEach((m) => this.load.audio(m, `assets/audio/music/${m}.mp3`));
    Object.entries(SFX).forEach(([dir, list]) => list.forEach((s) => this.load.audio(s, `assets/audio/sfx/${dir}/${s}.mp3`)));
  }

  create() {
    this.createAnimations();
    this.scene.start('menu');
  }

  anim(key, atlas, prefix, from, to, frameRate, repeat = -1) {
    this.anims.create({
      key, repeat, frameRate,
      frames: this.anims.generateFrameNames(atlas, { prefix, start: from, end: to }),
    });
  }

  createAnimations() {
    const beat = 8 / 0.46;
    this.anim('herbert', 'clct_herbert', 'herb_body_', 1, 8, beat);
    this.anim('herbert_up', 'clct_herbert', 'ani_herb_up_', 1, 8, beat);
    this.anim('herbert_down', 'clct_herbert', 'ani_herb_down_', 1, 8, beat);
    this.anim('herbert_prot', 'clct_herbert', 'herb_body_prot_', 1, 8, beat);
    this.anim('herbert_gover', 'clct_herbert', 'ani_herb_gover', 1, 8, beat, 0);
    this.anim('herbert_drugz', 'clct_herbert', 'herb_drugz', 1, 16, beat / 2);
    this.anim('herbert_trunk', 'clct_herbert', 'snout4', 1, 8, beat);
    ['norm_', 'norm2_', 'wsm1_', 'wsm2_', 'wbg1_', 'wbg2_'].forEach((l) =>
      this.anim(`herb_leg_${l.slice(0, -1)}_anim`, 'clct_herbert', `herb_leg_${l}`, 1, 8, beat));

    const enemyAnims = ['flyfred', 'flysina', 'bugoona', 'buglina', 'buggilbert', 'ladybug', 'flybob', 'flyrobert'];
    enemyAnims.forEach((e) => [0, 1].forEach((v) => this.anim(`${e}${v}`, 'clct_bugsgads', `${e}${v}_`, 1, 8, 8 / 0.6)));
    [0, 1, 2].forEach((v) => this.anim(`fuckbutton${v}`, 'clct_bugsgads', `fuckbutton${v}_`, 1, 8, 8 / 0.6));
    this.anim('bibi0', 'clct_bugsgads', 'bibi0_', 1, 8, 8 / 0.6);
    this.anim('bibi1', 'clct_bugsgads', 'bibi1_', 1, 8, 8 / 0.6);
    this.anim('bibi0_shit', 'clct_bugsgads', 'bibi0_shit', 1, 8, 8 / 0.6);
    ['birdy', 'bob', 'fred', 'fuckbutton', 'gilbert', 'ladybug', 'lina', 'oona', 'robert', 'sina'].forEach((k) =>
      this.anim(`kill_${k}`, 'clct_bugsgads', `kill_${k}_`, 0, 9, 16, 0));

    this.anim('caposhito', 'clct_bugsgads', 'caposhito', 1, 8, 12);
    this.anim('star', 'clct_bugsgads', 'star', 1, 8, 12);
    this.anim('prot_', 'clct_bugsgads', 'prot_', 1, 8, 12);
    this.anim('ring', 'clct_bugsgads', 'ring', 1, 8, 12);
    this.anim('rocket', 'clct_bugsgads', 'rocket', 1, 4, 12);
    [0, 1, 2].forEach((v) => this.anim(`flygun${v}`, 'clct_bugsgads', `flygun${v}_`, 1, 4, 10));
  }
}

export class MenuScene extends Phaser.Scene {
  constructor() { super('menu'); }

  create() {
    this.add.image(W / 2, H / 2, 'mm_bg').setDisplaySize(W, H);
    this.add.image(170, H - 120, 'clct_mm', 'mm_main_cloud_left');
    this.add.image(W - 170, H - 120, 'clct_mm', 'mm_main_cloud_right');
    const logo = this.add.image(W / 2, 170, 'clct_mm', 'mm_main_logo');
    this.add.image(W / 2, 270, 'clct_mm', 'mm_main_logo_misantropical');
    this.tweens.add({ targets: logo, scale: 1.04, duration: 460, yoyo: true, repeat: -1, ease: 'Sine.inOut' });

    const herb = this.add.sprite(W / 2, 400, 'clct_herbert').play('herbert');
    this.add.sprite(W / 2 + 16, 442, 'clct_herbert').play('herbert_trunk');
    this.tweens.add({ targets: herb, y: 390, duration: 700, yoyo: true, repeat: -1, ease: 'Sine.inOut' });

    const t = TEXT[settings.lang];
    const play = label(this, W / 2, 530, t.play, 44);
    this.tweens.add({ targets: play, alpha: 0.4, duration: 600, yoyo: true, repeat: -1 });

    this.langLabels = LANGS.map((l, i) => {
      const lbl = label(this, W - 210 + i * 76, 40, l.toUpperCase(), 26, l === settings.lang ? 0xf5d94a : 0xffffff)
        .setInteractive({ useHandCursor: true });
      lbl.on('pointerdown', (p, x, y, e) => { e.stopPropagation(); settings.lang = l; this.scene.restart(); });
      return lbl;
    });
    const music = label(this, 24, 40, settings.music ? 'music on' : 'music off', 26).setOrigin(0, 0.5).setInteractive({ useHandCursor: true });
    music.on('pointerdown', (p, x, y, e) => {
      e.stopPropagation();
      settings.music = !settings.music;
      music.setText(settings.music ? 'music on' : 'music off');
      settings.music ? this.playMusic() : this.sound.stopAll();
    });

    this.add.text(W / 2, H - 28, 'move: W/S · ↑/↓ · tilt · drag left edge      shoot: click & hold to aim      pause: P', {
      fontFamily: 'sans-serif', fontSize: '17px', fontStyle: 'bold', color: '#ffffff', stroke: '#222222', strokeThickness: 4,
    }).setOrigin(0.5);

    this.playMusic();
    this.input.once('pointerdown', () => this.start());
    this.input.keyboard.once('keydown-SPACE', () => this.start());
    this.input.keyboard.once('keydown-ENTER', () => this.start());
  }

  playMusic() {
    this.sound.stopAll();
    if (settings.music) this.sound.play('bg_mm', { loop: true, volume: 0.7 });
  }

  start() {
    if (settings.sfx) this.sound.play('menu');
    this.sound.stopAll();
    this.scene.start('game');
  }
}

export class GameOverScene extends Phaser.Scene {
  constructor() { super('gameover'); }

  create({ points }) {
    const best = Math.max(points, store.get('highscore', 0));
    store.set('highscore', best);
    const t = TEXT[settings.lang];

    this.add.image(W / 2, H / 2, 'mm_gameover_bg').setDisplaySize(W, H);
    const herb = this.add.image(W - 200, H + 200, 'clct_mm', 'mm_gameover_herb');
    this.tweens.add({ targets: herb, y: H / 2 + 60, duration: 900, ease: 'Back.out' });

    label(this, W / 2 - 100, 140, t.died, 48);
    label(this, W / 2 - 100, 195, t.subtitle, 24);
    label(this, W / 2 - 100, 300, `${t.score}: ${points}`, 56, 0xf5d94a);
    label(this, W / 2 - 100, 370, `${t.best}: ${best}`, 32);
    const retry = label(this, W / 2 - 100, 500, t.retry, 36);
    this.tweens.add({ targets: retry, alpha: 0.4, duration: 600, yoyo: true, repeat: -1 });

    this.sound.stopAll();
    if (settings.music) this.sound.play('bg_gameover', { volume: 0.7 });

    // Short delay so the tap that killed Herbert doesn't skip the screen.
    this.time.delayedCall(700, () => {
      this.input.once('pointerdown', () => this.scene.start('game'));
      this.input.keyboard.once('keydown-SPACE', () => this.scene.start('game'));
      this.input.keyboard.once('keydown-M', () => this.scene.start('menu'));
    });
  }
}
