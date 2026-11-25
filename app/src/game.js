import {
  W, H, S, PLAYER_X, MAX_HEALTH, SPAWN_INTERVAL, ITEM_INTERVAL, MAX_DIFFICULTY, LSD_SECONDS,
  SPEED_TABLE, ENEMIES, WEAPONS, ITEMS, INITIAL_ITEMS, UNLOCKS, SKY_BY_HEALTH, TEXT,
} from './data.js';
import { Herbert } from './herbert.js';
import { settings, store, label, setupCamera, worldPoint } from './ui.js';
import { debugState } from './debug.js';

const rand = (a, b) => a + Math.random() * (b - a);
const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];
const LOOP_SECONDS = 14.715;
const D = { sky: 0, drug: 1, rainbow: 1.5, bgCloud: 2, groundCloud: 5, midCloud: 8, item: 9, shot: 9, enemy: 10, spray: 11, herb: 12, fx: 20, fgCloud: 25, hud: 100 };

export class GameScene extends Phaser.Scene {
  constructor() { super('game'); }

  create() {
    setupCamera(this);
    this.sound.stopAll();
    this.debug = debugState;
    this.t = TEXT[settings.lang];
    this.health = MAX_HEALTH;
    this.points = 0;
    this.shownPoints = 0;
    this.gameSpeed = 1;
    this.baseSpeed = 1;
    this.healthW = null;
    this.spawnBonus = 0;
    this.difficulty = 0;
    this.ammo = Infinity;
    this.cooldown = 0;
    this.lsd = false;
    this.god = false;
    this.dead = false;
    this.running = false;
    this.paused = false;
    this.unlocked = store.get('unlockedItems', INITIAL_ITEMS);
    this.itemLevel = UNLOCKS.findIndex(([, items]) => !items.every((i) => this.unlocked.includes(i)));
    if (this.itemLevel < 0) this.itemLevel = UNLOCKS.length;

    this.enemies = [];
    this.shots = [];
    this.items = [];
    this.scrollers = [];

    this.createSky();
    this.player = new Herbert(this, -150, H / 2 + 28).setDepth(D.herb);
    this.createHud();
    this.createInput();

    for (let i = 0; i < 3; i++) this.addCloud(rand(0, W));
    this.groundClouds();
    this.time.addEvent({ delay: 2900, loop: true, callback: () => this.addCloud() });
    this.time.addEvent({ delay: 600, loop: true, callback: () => this.addParticle() });

    this.countdown();
  }

  // ---------- setup ----------

  createSky() {
    this.sky = this.add.graphics().setDepth(D.sky);
    this.skyColors = { top: SKY_BY_HEALTH[0][1], bottom: SKY_BY_HEALTH[0][2] };
    this.drawSky();
    this.drugBg = this.add.image(W / 2, H / 2, 'drugmode').setDepth(D.drug).setVisible(false).setScale(1.3);
  }

  drawSky() {
    const { top, bottom } = this.skyColors;
    this.sky.clear().fillGradientStyle(top, top, bottom, bottom, 1).fillRect(0, 0, W, H);
  }

  fadeSky() {
    const [, top, bottom] = SKY_BY_HEALTH.find(([min]) => this.health >= min) ?? SKY_BY_HEALTH.at(-1);
    const from = { ...this.skyColors };
    const mix = (a, b, t) => Phaser.Display.Color.Interpolate.ColorWithColor(
      Phaser.Display.Color.ValueToColor(a), Phaser.Display.Color.ValueToColor(b), 100, t * 100);
    this.tweens.addCounter({
      from: 0, to: 1, duration: 1000,
      onUpdate: (tw) => {
        const v = tw.getValue();
        const c1 = mix(from.top, top, v), c2 = mix(from.bottom, bottom, v);
        this.skyColors = { top: Phaser.Display.Color.GetColor(c1.r, c1.g, c1.b), bottom: Phaser.Display.Color.GetColor(c2.r, c2.g, c2.b) };
        this.drawSky();
      },
    });
  }

  createHud() {
    this.healthLife = this.add.image(34, 38, 'health_life').setOrigin(0, 0.5).setDepth(D.hud);
    this.add.image(30, 38, 'clct_ingame', 'health_bar').setOrigin(0, 0.5).setDepth(D.hud);
    this.pauseBtn = this.add.image(150, 38, 'clct_ingame', 'btn_pause').setDepth(D.hud).setInteractive({ useHandCursor: true });
    this.pauseBtn.on('pointerdown', (p, x, y, e) => { e.stopPropagation(); this.togglePause(); });
    this.ammoIcon = this.add.image(W / 2 - 30, 38, 'clct_ingame', 'ammoicon_gagi').setDepth(D.hud);
    this.ammoText = label(this, W / 2 + 10, 40, '', 34).setOrigin(0, 0.5).setDepth(D.hud);
    this.pointsText = label(this, W - 24, 40, '0', 40).setOrigin(1, 0.5).setDepth(D.hud);
  }

  createInput() {
    this.keys = this.input.keyboard.addKeys('W,S,UP,DOWN,P,ESC,M');
    this.input.keyboard.on('keydown-P', () => this.togglePause());
    this.input.keyboard.on('keydown-ESC', () => this.togglePause());
    this.input.keyboard.on('keydown-M', () => { if (this.paused) this.quitToMenu(); });
    this.input.addPointer(2);
    // Tapping Herbert himself drops the current gun, like in the original.
    this.input.on('pointerup', (pt) => {
      if (!this.running || this.paused || pt.upTime - pt.downTime > 300) return;
      const box = new Phaser.Geom.Rectangle(this.player.x - 80, this.player.y - 80, 160, 160);
      if (box.contains(worldPoint(this, pt, true).x, worldPoint(this, pt, true).y) && box.contains(worldPoint(this, pt).x, worldPoint(this, pt).y)) this.dropWeapon();
    });
    this.targetY = null;

    // Device tilt: the original mapped accelerometer x into a screen position.
    // Calibrates against the first reading, like the original's "moved zero point".
    this.tiltY = null;
    this.tiltZero = null;
    this.onTilt = (e) => {
      if (e.beta === null || e.gamma === null) return;
      const angle = ((screen.orientation?.angle ?? window.orientation ?? 0) + 360) % 360;
      const v = angle === 90 ? -e.gamma : angle === 270 ? e.gamma : e.beta;
      this.tiltZero ??= v;
      this.tiltY = Phaser.Math.Clamp(H / 2 + (v - this.tiltZero) * 16, 60, H - 60);
    };
    window.addEventListener('deviceorientation', this.onTilt);
    this.events.once('shutdown', () => window.removeEventListener('deviceorientation', this.onTilt));
  }

  countdown() {
    this.tweens.add({ targets: this.player, x: PLAYER_X, duration: 1600, ease: 'Sine.out' });
    if (settings.sfx) this.sound.play('herbert_bzzt1');
    const frames = ['cntdwn_3', 'cntdwn_2', 'cntdwn_1', 'cntdwn_0'];
    frames.forEach((f, i) => this.time.delayedCall(i * 600, () => {
      const img = this.add.image(W / 2, H / 2, 'clct_ingame', f).setDepth(D.hud).setScale(0.4);
      this.tweens.add({ targets: img, scale: 1.2, alpha: 0, duration: 600, ease: 'Quad.out', onComplete: () => img.destroy() });
    }));
    this.time.delayedCall(frames.length * 600, () => this.startRun());
  }

  startRun() {
    this.running = true;
    this.playLoop();
    this.levelTimer = this.time.addEvent({ delay: LOOP_SECONDS * 1000, loop: true, callback: () => this.levelUp() });
    this.scheduleSpawn(SPAWN_INTERVAL);
    this.time.addEvent({ delay: ITEM_INTERVAL * 1000, loop: true, callback: () => Math.random() < 0.5 && this.addItem() });
  }

  // ---------- difficulty / music ----------

  playLoop() {
    if (!settings.music || this.lsd) return;
    this.music?.stop();
    const track = `bg_loop${Math.min(10, Math.floor(this.difficulty / 2))}`;
    this.music = this.sound.add(track, { volume: 0.7, loop: this.difficulty >= MAX_DIFFICULTY - 1 });
    this.music.play();
  }

  levelUp() {
    if (this.dead || this.difficulty >= MAX_DIFFICULTY) return;
    this.difficulty++;
    const step = SPEED_TABLE[this.difficulty];
    if (step) {
      [this.baseSpeed, this.spawnBonus] = step;
      if (!this.lsd) this.gameSpeed = this.baseSpeed;
      this.flash(`msg_speed_${settings.lang}`);
    }
    this.playLoop();
  }

  scheduleSpawn(seconds) {
    this.spawnEvent = this.time.delayedCall(seconds * 1000, () => {
      if (this.dead) return;
      if (!this.debug.noSpawn) this.addEnemy();
      let next = SPAWN_INTERVAL + rand(0, 0.4) - this.spawnBonus;
      if (this.difficulty >= 2) next -= 0.3;
      this.points += 25;
      this.checkUnlocks();
      this.scheduleSpawn(next);
    });
  }

  checkUnlocks() {
    const tier = UNLOCKS[this.itemLevel];
    if (!tier || this.points <= tier[0]) return;
    this.itemLevel++;
    const fresh = tier[1].filter((i) => !this.unlocked.includes(i));
    if (!fresh.length) return;
    const item = pick(fresh);
    this.unlocked = [...this.unlocked, item];
    store.set('unlockedItems', this.unlocked);
    this.addItem(item, true);
    this.flash(`msg_wpn_${settings.lang}`);
  }

  flash(frame) {
    const img = this.add.image(W / 2, H / 2 - 60, 'clct_ingame', frame).setDepth(D.hud).setScale(0.2);
    this.tweens.chain({
      targets: img,
      tweens: [
        { scale: 1.1, duration: 250, ease: 'Back.out' },
        { scale: 1, duration: 900 },
        { alpha: 0, y: img.y - 40, duration: 300, onComplete: () => img.destroy() },
      ],
    });
  }

  // ---------- environment ----------

  scroll(obj, crossSeconds, opts = {}) {
    const width = obj.displayWidth || 0;
    obj.vx = -(W + width) / crossSeconds;
    obj.endX = opts.endX ?? -width / 2;
    this.scrollers.push(obj);
    return obj;
  }

  addCloud(x) {
    if (Math.random() < 1 / 3 && !this.rainbow && x === undefined) {
      this.rainbow = this.add.image(0, H / 2, 'rainbow_start').setDepth(D.rainbow).setAlpha(this.lsd ? 0 : 0.9);
      this.rainbow.x = W + this.rainbow.width / 2;
      this.scroll(this.rainbow, 16, { endX: -1500 }).onGone = () => { this.rainbow = null; };
      return;
    }
    const r = Math.floor(Math.random() * 6);
    let c;
    if (r === 0 && x === undefined) {
      c = this.add.image(0, rand(0, H), 'clct_ingame', `cloud_25_${Math.floor(rand(0, 5))}`).setDepth(D.fgCloud).setAlpha(0.85);
      this.scroll(c, rand(3, 5));
    } else if (r > 3) {
      c = this.add.image(0, rand(100 * S, H), 'clct_ingame', `cloud_10_${Math.floor(rand(0, 6))}`).setDepth(D.midCloud);
      this.tweens.add({ targets: c, scale: 0.95, duration: 400, yoyo: true, repeat: -1, hold: 300 });
      this.scroll(c, rand(10, 13));
    } else {
      c = this.add.image(0, rand(0, H), 'clct_ingame', `cloud_3_${Math.floor(rand(0, 5))}`).setDepth(D.bgCloud);
      this.scroll(c, rand(18, 24));
    }
    c.x = x ?? W + c.width / 2;
  }

  groundClouds() {
    let x = 0;
    while (x < W + 600) {
      const c = this.add.image(0, 0, 'clct_ingame', `cloud_ground${Math.floor(rand(0, 4))}`).setDepth(D.groundCloud);
      c.setPosition(x + c.width / 2, H - c.height / 2 + 6);
      this.scroll(c, 13.5);
      x += c.width * 0.5;
    }
    this.lastGround = this.scrollers.at(-1);
  }

  addParticle() {
    const p = this.add.image(W + 10, rand(0, H), 'clct_ingame', `particle_${Math.floor(rand(0, 17))}`)
      .setDepth(pick([D.bgCloud, D.midCloud])).setAlpha(rand(0.5, 1));
    this.scroll(p, rand(6, 14));
  }

  // ---------- enemies ----------

  addEnemy(forced) {
    const pool = Object.entries(ENEMIES).filter(([, d]) => this.difficulty >= d.minDifficulty);
    const [name, def] = forced ? [forced, ENEMIES[forced]] : pick(pool);
    const variant = def.variants === false ? '' : Math.floor(rand(0, def.variantCount ?? 2));
    const key = `${def.anim}${variant}`;
    const sprite = this.add.sprite(0, rand(30, H - 30), 'clct_bugsgads').play(key).setDepth(D.enemy);
    sprite.x = W + sprite.width / 2;
    if (def.bird && Math.random() < 2 / 3 && settings.sfx) this.sound.play('birdy_coming', { volume: 0.6 });

    const e = {
      sprite, def, name, hp: def.hp, vy: 0, dir: Math.random() < 0.5 ? 1 : -1,
      radius: Math.min(sprite.width, sprite.height) * (def.bird ? 0.36 : 0.34),
      vx: -(W + sprite.width) / rand(...def.dur),
    };
    if (!def.follows) this.wander(e);
    if (def.bird && name === 'Bibi' && Math.random() < 0.25) this.time.delayedCall(3000, () => this.birdPoop(e));
    this.enemies.push(e);
  }

  // Zig-zag flight: alternating direction with a minimum swing (flightYMinRange).
  wander(e) {
    if (e.dead) return;
    e.dir *= -1;
    const swing = (e.def.yMin + rand(0, e.def.yRange)) * S * e.dir;
    const y = Phaser.Math.Clamp(e.sprite.y + swing, 40, H - 40);
    e.wanderTween = this.tweens.add({
      targets: e.sprite, y, duration: 1600, ease: 'Sine.inOut',
      onComplete: () => this.time.delayedCall(400, () => this.wander(e)),
    });
  }

  birdPoop(e) {
    if (e.dead || !e.sprite.active) return;
    e.sprite.play('bibi0_shit');
    this.time.delayedCall(500, () => {
      if (e.dead || !e.sprite.active) return;
      e.poop = { img: this.add.image(0, 0, 'clct_bugsgads', 'birdshit').setDepth(D.enemy - 0.1), t: 0 };
      this.placePoop(e);
    });
    this.time.delayedCall(800, () => e.sprite.active && !e.dead && e.sprite.play('bibi0'));
  }

  // The poop is a child of the bird (Monster.mm startShit): it starts at (83.5, 24.5)pt
  // from the bird's bottom-left, and its anchor sits (-583, -356)pt away from it.
  // Rotating it 45° over 2 s around that distant pivot swings it down in an arc
  // while it keeps flying along with the bird.
  placePoop(e, dt = 0) {
    e.poop.t += dt;
    const { img, t } = e.poop;
    const { x, y, width, height } = e.sprite;
    const start = { x: x - width / 2 + 83.5 * S, y: y + height / 2 - 24.5 * S };
    const pivot = { x: start.x - 583 * S, y: start.y + 356 * S };
    const angle = Phaser.Math.DegToRad(45 * Math.min(1, t / 2));
    const vx = start.x - pivot.x, vy = start.y - pivot.y;
    img.setPosition(pivot.x + vx * Math.cos(angle) - vy * Math.sin(angle), pivot.y + vx * Math.sin(angle) + vy * Math.cos(angle));
    img.setRotation(angle);
  }

  damage(e, amount) {
    if (e.dead) return;
    e.hp -= amount;
    if (e.hp <= 0) { this.killEnemy(e, true); return; }
    e.sprite.setTintFill(0xffffff);
    this.time.delayedCall(60, () => e.sprite.active && e.sprite.clearTint());
    if (Math.random() < 1 / 12 && !e.bubble) {
      e.bubble = this.add.image(0, 0, 'clct_bugsgads', `bubble${Math.floor(rand(0, 3))}`).setDepth(D.enemy + 0.5);
      this.placeBubble(e);
      this.time.delayedCall(500, () => { e.bubble?.destroy(); e.bubble = null; });
    }
  }

  // Bubbles are children of the enemy in the original, offset from its bottom-left corner.
  placeBubble(e) {
    const [bx, by] = e.def.bubble;
    const { x, y, width, height } = e.sprite;
    e.bubble.setPosition(x - width / 2 + bx * S, y + height / 2 - by * S);
  }

  killEnemy(e, scored) {
    if (e.dead) return;
    e.dead = true;
    e.wanderTween?.stop();
    if (scored) this.points += e.def.points;
    if (settings.sfx && Math.random() < (e.def.bird ? 0.5 : 2 / 3)) {
      this.sound.play(e.def.bird ? 'birdy_death' : `bug_hit${Math.floor(rand(0, 3))}`);
    }
    const { x, y } = e.sprite;
    e.sprite.destroy();
    e.bubble?.destroy();
    e.bubble = null;
    e.poop?.img.destroy();
    if (e.def.bird) this.birdBreakup(x, y);
    else this.bugBurst(e.def.kill, x, y);
  }

  // kill_<name>_0..9 are body parts, not animation frames. The original fired each
  // part as a one-particle CCParticleExplosion: random direction, speed 100±40 px/s,
  // gravity 640 px/s², random spin easing to 0, life 2 s.
  bugBurst(name, x, y) {
    const parts = Array.from({ length: 10 }, (_, i) => {
      const a = rand(0, Math.PI * 2);
      const speed = rand(60, 140);
      const spin = rand(-563, 563);
      return {
        img: this.add.image(x, y, 'clct_bugsgads', `kill_${name}_${i}`).setDepth(D.fx).setAngle(spin),
        vx: Math.cos(a) * speed + 10, vy: Math.sin(a) * speed, spin,
      };
    });
    this.tweens.addCounter({
      from: 0, to: 2, duration: 2000,
      onUpdate: (tw) => {
        const t = tw.getValue();
        for (const p of parts) {
          p.img.setPosition(x + p.vx * t, y + p.vy * t + 320 * t * t);
          p.img.setAngle(p.spin * (1 - t / 2));
        }
      },
      onComplete: () => parts.forEach((p) => p.img.destroy()),
    });
  }

  // Hand-placed bird breakup from DeathAni.m. Offsets are original points (y up);
  // each part's move vector reuses its start position, a quirk kept for the same motion.
  birdBreakup(x, y) {
    const R = rand(100, 150);
    const node = this.add.container(x, y + R * S).setDepth(D.fx);
    const pt = (px, py) => [px * S, -py * S];
    const parts = [
      [1, -1, R - 56, false, (p) => [p.x - rand(0, 60), p.y - 150], 1000, rand(-50, 90)],
      [2, 30, R - 46, true, (p) => [p.x + rand(0, 60), p.y - 150], 1000, rand(0, 90)],
      [3, -9, R + 52, true, (p) => [p.x + R - rand(0, 80), p.y - R - 60 - rand(0, 60)], 2000, rand(0, 80)],
      [4, 47, R - 37, false, (p) => [p.x + rand(0, 40), p.y - 100 - rand(0, 80)], 1000, -rand(0, 90)],
      [5, -4, R - 21, true, (p) => [p.x + rand(0, 60), p.y - 20 - rand(0, 20)], 1000, -rand(0, 120)],
      [6, -35, R - 34, true, (p) => [p.x + 20 - rand(0, 40), p.y - 20 - rand(0, 20)], 1000, 80 + rand(0, 100)],
      [7, -43, R - 26, false, (p) => [p.x + 20 - rand(0, 40), p.y + rand(0, 40)], 1000, -100 - rand(0, 80)],
      [8, 38, R - 29, true, (p) => [p.x - 20, p.y - 140], 1000, -50],
      [9, -16, R - 34, false, (p) => [p.x - 20, p.y + 40], 1000, -180],
    ];
    const behind = [], front = [];
    for (const [i, px, py, inFront, move, ms, rot] of parts) {
      const img = this.add.image(...pt(px, py), 'clct_bugsgads', `kill_birdy_${i}`);
      const [dx, dy] = pt(...move({ x: px, y: py }));
      this.tweens.add({ targets: img, x: img.x + dx, y: img.y + dy, angle: rot, duration: ms });
      (inFront ? front : behind).push(img);
    }
    const body = this.add.image(...pt(0, R), 'clct_bugsgads', 'kill_birdy_0');
    this.tweens.add({ targets: body, angle: rand(-40, 40), scale: 0.8, duration: 1300 });
    node.add([...behind, body, ...front]);
    const [mx, my] = pt(50 + rand(0, 80), -300);
    this.tweens.add({ targets: node, x: node.x + mx, y: node.y + my, angle: -45, duration: 1300, onComplete: () => node.destroy() });
  }

  // ---------- items ----------

  addItem(name, force = false) {
    if (!force && this.items.length >= 2) return;
    name ??= pick(this.unlocked);
    const def = ITEMS[name];
    const sprite = def.anim
      ? this.add.sprite(0, 0, 'clct_bugsgads').play(def.frame)
      : this.add.image(0, 0, 'clct_bugsgads', def.frame);
    sprite.setDepth(D.item);
    sprite.setPosition(W + sprite.width / 2, rand(sprite.height / 2, H - sprite.height / 2));
    const item = { sprite, name, def, phase: rand(0, Math.PI * 2), vx: -(W + sprite.width) / 10, baseY: sprite.y };
    this.items.push(item);
  }

  // The item vanishes at once and a ring of particles bursts out (ItemUpParticle).
  collect(item) {
    const { name, def, sprite } = item;
    if (!this.lsd && name !== 'LsdStar') this.itemBurst(sprite.x, sprite.y, def.burst ?? [13, 14]);
    this.removeItem(item);
    this.applyItem(name);
  }

  itemBurst(x, y, frames) {
    const ring = this.add.container(x + 20, y).setDepth(D.fx);
    for (let i = 1; i <= 12; i++) {
      const a = Phaser.Math.DegToRad((360 / 12) * i);
      const speed = rand(60, 100) * S;
      const p = this.add.image(0, 0, 'clct_ingame', `particle_${pick(frames)}`);
      ring.add(p);
      this.tweens.add({ targets: p, x: Math.cos(a) * speed, y: Math.sin(a) * speed, alpha: 0, duration: 1000 });
    }
    this.tweens.add({ targets: ring, x: ring.x - 80 * S, duration: 1000, onComplete: () => ring.destroy() });
  }

  applyItem(name) {
    const def = ITEMS[name];
    const sfx = (k) => settings.sfx && this.sound.play(k);
    if (name === 'Capushito') { this.health = Math.min(MAX_HEALTH, this.health + 100); this.updateHealth(); sfx(`shitoccino${Math.floor(rand(0, 3))}`); }
    if (name === 'Coin') { this.points += 200; sfx('coin_up'); }
    if (name === 'LsdStar') this.startLsd();
    if (name === 'ProtectSuit' && !this.player.hasSuit && !this.lsd) { this.player.setSuit(true); sfx('protectionsuit_on'); }
    if (def.weapon && !this.lsd) {
      const w = WEAPONS[def.weapon];
      if (this.player.weaponType === def.weapon) this.ammo += w.ammo;
      else { this.stopBeam(); this.player.changeWeapon(def.weapon); this.ammo = w.ammo; }
      this.updateAmmo();
      sfx('weapon_up');
    }
  }

  removeItem(item) {
    item.sprite.destroy();
    this.items = this.items.filter((i) => i !== item);
  }

  // ---------- LSD star ----------

  startLsd() {
    if (this.lsd) return;
    this.lsd = true;
    this.stopBeam();
    this.player.setSuit(false);
    this.player.setDrugs(true);
    this.ammo = Infinity;
    this.gameSpeed = (this.baseSpeed ?? 1) * 2;
    this.drugBg.setVisible(true).setAngle(0);
    this.drugTween = this.tweens.add({ targets: this.drugBg, angle: 120, duration: LSD_SECONDS * 1000 });
    if (this.rainbow) this.rainbow.setAlpha(0);
    this.music?.pause();
    if (settings.music) {
      this.drugMusic = this.sound.add('bg_drugmode', { loop: true, volume: 0.8 });
      this.drugMusic.play();
    }
    this.lsdLeft = LSD_SECONDS;
    this.ammoIcon.setVisible(false);
    this.ammoText.setText(this.lsdLeft);
    this.lsdTick = this.time.addEvent({ delay: 1000, repeat: LSD_SECONDS - 1, callback: () => this.ammoText.setText(--this.lsdLeft) });
    this.trail = this.time.addEvent({ delay: 40, loop: true, callback: () => {
      const r = this.add.image(this.player.x + 200, this.player.y + 10, 'clct_ingame', 'drugmode_rainbow').setDepth(D.herb - 1);
      this.scroll(r, 3);
      this.tweens.add({ targets: r, alpha: 0, duration: 1000 });
    } });
    this.time.delayedCall(LSD_SECONDS * 1000, () => this.endLsd());
  }

  endLsd() {
    if (!this.lsd) return;
    this.lsd = false;
    this.trail.remove();
    this.drugBg.setVisible(false);
    this.player.setDrugs(false);
    this.gameSpeed = this.baseSpeed ?? 1;
    this.drugMusic?.stop();
    if (this.rainbow) this.rainbow.setAlpha(0.9);
    if (settings.music) this.music ? this.music.resume() : this.playLoop();
    this.ammoIcon.setVisible(true);
    this.updateAmmo();
  }

  // ---------- player ----------

  hitPlayer(dmg) {
    if (this.god || this.dead || this.debug.god) return;
    this.cameras.main.shake(150, 0.01);
    this.health -= dmg;
    this.updateHealth();
    if (this.health > 0) return;
    this.health = 0;
    this.dead = true;
    this.running = false;
    this.stopBeam();
    this.player.die();
    this.gameSpeed /= 2;
    this.music?.stop();
    this.spawnEvent?.remove();
    this.levelTimer?.remove();
    this.time.delayedCall(1500, () => this.scene.start('gameover', { points: this.points }));
  }

  updateHealth() {
    const ratio = Phaser.Math.Clamp(this.health / MAX_HEALTH, 0, 1);
    const { width, height } = this.healthLife.frame;
    this.tweens.addCounter({
      from: this.healthW ?? width, to: width * ratio, duration: 200,
      onUpdate: (tw) => { this.healthW = tw.getValue(); this.healthLife.setCrop(0, 0, this.healthW, height); },
    });
    this.fadeSky();
  }

  updateAmmo() {
    const w = WEAPONS[this.player.weaponType];
    this.ammoIcon.setFrame(w.icon);
    this.ammoText.setText(this.ammo === Infinity ? '' : Math.max(0, this.ammo));
  }

  togglePause() {
    if (this.dead || !this.running) return;
    this.paused = !this.paused;
    if (this.paused) {
      this.stopBeam();
      this.tweens.pauseAll();
      this.time.paused = true;
      this.anims.pauseAll();
      this.sound.pauseAll();
      this.pauseLayer = this.add.container(0, 0, [
        this.add.rectangle(W / 2, H / 2, W, H, 0x000000, 0.45),
        label(this, W / 2, H / 2 - 30, this.t.paused, 72),
        label(this, W / 2, H / 2 + 50, 'P = continue   M = menu', 26),
      ]).setDepth(D.hud + 1);
    } else {
      this.pauseLayer.destroy();
      this.tweens.resumeAll();
      this.time.paused = false;
      this.anims.resumeAll();
      this.sound.resumeAll();
    }
  }

  quitToMenu() {
    this.sound.stopAll();
    this.scene.start('menu');
  }

  // ---------- shooting ----------

  // Original points relative to Herbert (y up) -> world position.
  fromPlayer([px, py], jitter = 0) {
    const j = jitter ? [rand(0, jitter), -rand(0, jitter)] : [0, 0];
    return { x: this.player.x + (px + j[0]) * S, y: this.player.y - (py + j[1]) * S };
  }

  aimAngle(from, pointer) {
    const aim = worldPoint(this, pointer);
    return Phaser.Math.Clamp(Math.atan2(aim.y - from.y, Math.max(20, aim.x - from.x)), -1.3, 1.3);
  }

  fire(pointer) {
    const type = this.player.weaponType;
    const w = WEAPONS[type];
    const from = w.spawn ? this.fromPlayer(w.spawn) : { x: this.player.x, y: this.player.y };
    const angle = this.aimAngle(from, pointer);
    const deg = Phaser.Math.RadToDeg(angle);
    const sfx = (k, cfg) => settings.sfx && this.sound.play(k, cfg);

    if (w.warmup && !this.warm) {
      this.warmStart ??= this.time.now;
      this.player.aim(deg);
      if (this.time.now - this.warmStart < w.warmup * 1000) return;
      this.warm = true;
    }

    this.player.shootFx(deg);
    this.cooldown = w.reload;

    if (w.beam) {
      this.beamAngle = this.aimAngle(this.player, pointer);
      this.updateBeam(w.beam);
      this.beamHits(w.strength);
      if (!this.beamSound?.isPlaying && settings.sfx) { this.beamSound = this.sound.add(w.sfx, { loop: true, volume: 0.6 }); this.beamSound.play(); }
    } else if (w.lightning) {
      this.lightning();
      sfx(w.sfx);
    } else if (w.homing) {
      for (let i = 0; i < w.homing; i++) this.time.delayedCall(i * 200, () => this.spawnFly(i, this.fromPlayer(w.spawn)));
      sfx(w.sfx);
    } else if (w.spray) {
      this.spawnSpray(from);
      sfx(w.sfx, { volume: 0.5 });
    } else {
      const pellets = w.pellets ?? 1;
      for (let i = 0; i < pellets; i++) {
        let a = angle;
        if (pellets > 1) a += Phaser.Math.DegToRad((i - (pellets - 1) / 2) * 4 + rand(-2, 2));
        if (w.spread) a += Phaser.Math.DegToRad(rand(-3, 3));
        const at = w.jitter ? this.fromPlayer(w.spawn, w.jitter) : from;
        this.spawnBullet(w, at, a, w.speed * S * (pellets > 1 ? rand(0.9, 1.1) : 1));
      }
      sfx(w.sfx, { volume: type === 3 ? 0.35 : 0.7 });
      if (type === 4) this.time.delayedCall(500, () => settings.sfx && this.sound.play('pumpgun_load', { volume: 0.6 }));
    }

    if (type === 0 || this.debug.infiniteAmmo) return;
    this.ammo -= 1;
    this.updateAmmo();
    if (this.ammo <= 0) this.time.delayedCall(700, () => { if (this.ammo <= 0 && this.player.weaponType === type) this.dropWeapon(); });
  }

  dropWeapon() {
    if (this.player.weaponType === 0) return;
    this.stopBeam();
    this.player.dropWeapon();
    this.ammo = Infinity;
    this.updateAmmo();
  }

  spawnBullet(w, at, angle, speed) {
    const s = w.projectile === 'rocket'
      ? this.add.sprite(at.x, at.y, 'clct_bugsgads').play('rocket')
      : this.add.image(at.x, at.y, 'clct_ingame', w.projectile);
    s.setOrigin(w.anchor[0], 1 - w.anchor[1]).setDepth(D.shot).setRotation(angle);
    const shot = { sprite: s, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed, strength: w.strength, radius: 14, rocket: !!w.explodes };
    if (shot.rocket) {
      shot.smoke = this.time.addEvent({ delay: 50, loop: true, callback: () => {
        if (!s.active) return;
        const puff = this.add.image(s.x - Math.cos(angle) * 40, s.y - Math.sin(angle) * 40, 'clct_ingame', 'cloud_rocket').setDepth(D.shot - 0.1);
        this.tweens.add({ targets: puff, alpha: 0, scale: 1.8, duration: 500, onComplete: () => puff.destroy() });
      } });
    }
    this.shots.push(shot);
  }

  // SprayPoison: a cloud that drifts out and back while it rises, grows and fades.
  spawnSpray(at) {
    const s = this.add.image(at.x + 5, at.y + 29, 'clct_ingame', `bugspray_poison${Math.floor(rand(0, 2))}`)
      .setDepth(D.spray).setScale(0.2).setAngle(rand(0, 360));
    const drift = { dx: 0 };
    const rise = { x: 0, y: 0 };
    this.tweens.add({ targets: s, scale: 1, delay: 300, duration: 800 });
    this.tweens.add({ targets: s, alpha: 0, delay: 600, duration: 500 });
    this.tweens.add({ targets: rise, x: rand(-30, 10), y: -70, duration: 1100 });
    this.tweens.chain({ targets: drift, tweens: [{ dx: 100, duration: 500 }, { dx: 60, duration: 600 }], onComplete: () => this.removeShot(s) });
    this.shots.push({ sprite: s, strength: 1, radius: 30, drift, rise, baseX: s.x, baseY: s.y });
  }

  spawnFly(i, at) {
    const s = this.add.sprite(at.x, at.y, 'clct_bugsgads').play(`flygun${i}`).setDepth(D.shot).setScale(1.4);
    this.shots.push({ sprite: s, strength: 2, radius: 20, homing: true, vx: 300, vy: rand(-80, 80), age: 0 });
  }

  // One sprite per beam gun, pivoting around the original anchor next to the gun.
  updateBeam(beam) {
    this.beams ??= {};
    let b = this.beams[beam.frame];
    if (!b) {
      b = this.beams[beam.frame] = this.add.image(0, 0, 'clct_ingame', beam.frame).setDepth(D.shot);
      b.setOrigin((beam.pivot[0] * S) / b.width, 0.5 - (beam.pivot[1] * S) / b.height);
    }
    const at = this.fromPlayer(beam.at);
    b.setPosition(at.x, at.y).setRotation(this.beamAngle).setVisible(true);
    this.beam = b;
  }

  beamHits(strength) {
    const b = this.beam;
    const start = { x: b.x - b.displayOriginX * Math.cos(b.rotation), y: b.y - b.displayOriginX * Math.sin(b.rotation) };
    const line = new Phaser.Geom.Line(start.x, start.y, start.x + Math.cos(b.rotation) * b.width, start.y + Math.sin(b.rotation) * b.width);
    for (const e of this.enemies) {
      if (e.dead) continue;
      const c = new Phaser.Geom.Circle(e.sprite.x, e.sprite.y, e.radius + b.height * 0.3);
      if (Phaser.Geom.Intersects.LineToCircle(line, c)) { this.points += 20; this.damage(e, strength); }
    }
  }

  stopBeam() {
    Object.values(this.beams ?? {}).forEach((b) => b.setVisible(false));
    this.beam = null;
    this.beamSound?.stop();
    this.beamSound = null;
    this.warm = false;
    this.warmStart = null;
  }

  lightning() {
    const imgs = ['uber-lightning0', 'uber-lightning2', 'uber-lightning3'];
    imgs.forEach((k, i) => this.time.delayedCall(300 + i * 100, () => {
      const img = this.add.image(W / 2, H / 2, k).setDepth(i === 2 ? D.midCloud : D.fgCloud).setAlpha(0);
      this.tweens.add({ targets: img, alpha: 1, duration: 50, yoyo: true, onComplete: () => img.destroy() });
      if (i === 0) this.cameras.main.shake(200, 0.015);
      if (i === 1) this.enemies.forEach((e) => this.killEnemy(e, true));
    }));
    this.sky.setAlpha(1);
    this.tweens.chain({ targets: this.sky, tweens: [{ alpha: 0, duration: 200 }, { alpha: 1, delay: 500, duration: 200 }] });
  }

  explode(x, y) {
    if (settings.sfx) this.sound.play('boom');
    this.points += 150;
    const i = Math.floor(rand(0, 6));
    const cloud = this.add.image(x, y, 'clct_ingame', `boom_cloud${i}`).setDepth(D.fx).setScale(0.5);
    const word = this.add.image(x, y - 40, 'clct_ingame', `boom_label${Math.floor(rand(0, 6))}`).setDepth(D.fx + 1).setScale(0.2);
    this.tweens.add({ targets: cloud, scale: 2.2, alpha: 0, duration: 600, onComplete: () => cloud.destroy() });
    this.tweens.add({ targets: word, scale: 0.6, duration: 200, ease: 'Back.out' });
    this.tweens.add({ targets: word, alpha: 0, delay: 600, duration: 300, onComplete: () => word.destroy() });
    this.cameras.main.shake(180, 0.012);
    for (const e of this.enemies) {
      if (!e.dead && Phaser.Math.Distance.Between(x, y, e.sprite.x, e.sprite.y) < 170) this.damage(e, 8);
    }
  }

  removeShot(sprite) {
    const shot = this.shots.find((s) => s.sprite === sprite);
    shot?.smoke?.remove();
    sprite.destroy();
    this.shots = this.shots.filter((s) => s.sprite !== sprite);
  }

  // ---------- debug ----------

  killAll() {
    this.enemies.forEach((e) => this.killEnemy(e, true));
  }

  drawHitboxes() {
    if (!this.debug.hitboxes) { this.hitboxGfx?.clear(); return; }
    this.hitboxGfx ??= this.add.graphics().setDepth(D.hud - 1);
    const g = this.hitboxGfx.clear().lineStyle(2, 0xff0066, 0.9);
    const r = this.player.hitRect;
    g.strokeRect(r.x, r.y, r.width, r.height);
    this.enemies.forEach((e) => !e.dead && g.strokeCircle(e.sprite.x, e.sprite.y, e.radius));
    g.lineStyle(2, 0x00aa55, 0.9);
    this.shots.forEach((s) => { if (s.sprite.active) { const c = s.sprite.getCenter(); g.strokeCircle(c.x, c.y, s.radius); } });
    this.items.forEach((i) => g.strokeRectShape(i.sprite.getBounds()));
  }

  // ---------- main loop ----------

  update(time, deltaMs) {
    if (this.paused) return;
    this.drawHitboxes();
    const dt = Math.min(deltaMs, 50) / 1000;

    this.moveWorld(dt);
    if (this.dead) return;
    this.movePlayer(dt);
    if (!this.running) return;

    this.handleShooting(dt);
    this.moveShots(dt);
    this.moveEnemies(dt);
    this.moveItems(dt);

    if (this.shownPoints !== this.points) {
      this.shownPoints += Math.ceil((this.points - this.shownPoints) * 0.2);
      this.pointsText.setText(this.shownPoints);
    }
  }

  moveWorld(dt) {
    for (const o of this.scrollers) {
      o.x += o.vx * this.gameSpeed * dt;
      if (o.x < o.endX || !o.active) o.gone = true;
    }
    const gone = this.scrollers.filter((o) => o.gone);
    if (gone.length) {
      gone.forEach((o) => { o.onGone?.(); if (o.active) o.destroy(); });
      this.scrollers = this.scrollers.filter((o) => !o.gone);
    }
    if (this.lastGround && this.lastGround.x + this.lastGround.width / 2 < W + 300) {
      const c = this.add.image(0, 0, 'clct_ingame', `cloud_ground${Math.floor(rand(0, 4))}`).setDepth(D.groundCloud);
      c.setPosition(this.lastGround.x + this.lastGround.width * 0.5, H - c.height / 2 + 6);
      this.scroll(c, 13.5);
      this.lastGround = c;
    }
  }

  movePlayer(dt) {
    const p = this.player;
    const up = this.keys.W.isDown || this.keys.UP.isDown;
    const down = this.keys.S.isDown || this.keys.DOWN.isDown;
    const steer = this.input.manager.pointers.find((pt) => pt.isDown && worldPoint(this, pt, true).x < 140);
    let target = null;
    if (steer) target = worldPoint(this, steer).y;
    else if (up || down) target = p.y + (down ? 1 : -1) * 400;
    else if (this.tiltY !== null) target = this.tiltY;

    // Carrying a weapon makes Herbert heavier (kFilterFactor 0.07 -> 0.045).
    const maxSpeed = (p.weaponType ? 650 : 900);
    let vy = 0;
    if (target !== null) {
      const diff = target - p.y;
      vy = Phaser.Math.Clamp(diff * 8, -maxSpeed, maxSpeed);
    }
    p.y = Phaser.Math.Clamp(p.y + vy * dt, 50, H - 70);
    p.setTilt(vy < -250 ? -1 : vy > 250 ? 1 : 0);
  }

  handleShooting(dt) {
    this.cooldown -= dt;
    const shooter = this.input.manager.pointers.find((pt) => pt.isDown && worldPoint(this, pt, true).x >= 140 && worldPoint(this, pt).y > 80);
    if (!shooter || this.lsd) {
      if (this.beam || this.warm) this.stopBeam();
      return;
    }
    // The beam follows Herbert and the pointer every frame, not only on fire ticks.
    const { beam } = WEAPONS[this.player.weaponType];
    if (this.beam && beam) {
      this.beamAngle = this.aimAngle(this.player, shooter);
      this.updateBeam(beam);
    }
    if (this.cooldown <= 0) this.fire(shooter);
  }

  moveShots(dt) {
    for (const s of [...this.shots]) {
      const sp = s.sprite;
      if (!sp.active) { this.shots = this.shots.filter((x) => x !== s); continue; }
      if (s.homing) this.steerFly(s, dt);
      if (s.drift) sp.setPosition(s.baseX + s.drift.dx + s.rise.x, s.baseY + s.rise.y);
      else if (!s.static) { sp.x += s.vx * dt; sp.y += s.vy * dt; }
      // Bullets are drawn ahead of their pivot (anchor outside the sprite), so hit-test the visible center.
      const c = sp.getCenter();
      if (c.x > W + 100 || c.x < -100 || c.y < -100 || c.y > H + 100) { this.removeShot(sp); continue; }
      const hit = this.enemies.find((e) => !e.dead && Phaser.Math.Distance.Between(c.x, c.y, e.sprite.x, e.sprite.y) < e.radius + s.radius);
      if (!hit) continue;
      this.points += 20;
      if (s.rocket) this.explode(c.x, c.y);
      this.damage(hit, s.strength);
      this.removeShot(sp);
    }
  }

  steerFly(s, dt) {
    s.age += dt;
    if (s.age < 0.3) return;
    const target = this.enemies.filter((e) => !e.dead)
      .sort((a, b) => Phaser.Math.Distance.Between(s.sprite.x, s.sprite.y, a.sprite.x, a.sprite.y) - Phaser.Math.Distance.Between(s.sprite.x, s.sprite.y, b.sprite.x, b.sprite.y))[0];
    if (!target) { s.vx = 500; s.vy *= 0.9; return; }
    const a = Phaser.Math.Angle.Between(s.sprite.x, s.sprite.y, target.sprite.x, target.sprite.y);
    s.vx = Phaser.Math.Linear(s.vx, Math.cos(a) * 600, 0.1);
    s.vy = Phaser.Math.Linear(s.vy, Math.sin(a) * 600, 0.1);
  }

  moveEnemies(dt) {
    const herb = this.player.hitRect;
    for (const e of this.enemies) {
      if (e.dead) continue;
      const sp = e.sprite;
      sp.x += e.vx * this.gameSpeed * dt;
      if (e.def.follows && !this.player.hasSuit) {
        if (sp.y < this.player.y - 20) sp.y += 60 * dt;
        else if (sp.y > this.player.y + 20) sp.y -= 60 * dt;
      }
      if (e.bubble) this.placeBubble(e);
      if (e.poop) this.placePoop(e, dt);
      if (sp.x < -sp.width / 2) { e.dead = true; e.wanderTween?.stop(); e.bubble?.destroy(); e.poop?.img.destroy(); sp.destroy(); continue; }

      const circle = new Phaser.Geom.Circle(sp.x, sp.y, e.radius);
      if (!Phaser.Geom.Intersects.CircleToRectangle(circle, herb)) continue;
      this.killEnemy(e, true);
      if (this.lsd) continue;
      if (this.player.hasSuit) {
        this.player.setSuit(false, true);
        if (settings.sfx) this.sound.play('protectionsuit_out');
        this.god = true;
        this.player.blink(2000);
        this.time.delayedCall(2000, () => { this.god = false; });
      } else {
        this.hitPlayer(e.def.strength);
      }
    }
    this.enemies = this.enemies.filter((e) => !e.dead);
  }

  moveItems(dt) {
    const herb = this.player.hitRect;
    for (const item of [...this.items]) {
      const sp = item.sprite;
      sp.x += item.vx * this.gameSpeed * dt;
      item.phase += dt * 5;
      sp.y = item.baseY + Math.sin(item.phase) * 14;
      if (sp.x < -sp.width / 2) { this.removeItem(item); continue; }
      if (Phaser.Geom.Intersects.RectangleToRectangle(herb, sp.getBounds())) this.collect(item);
    }
  }
}
