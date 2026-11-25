// Gameplay numbers ported 1:1 from the 2011 Cocos2d source (HelloWorldScene.mm,
// Monster.mm, Herbert.mm, GameConfig.h). Original ran at 480x320 points; the
// prototype renders the retina assets at 960x640, so distances are doubled.

export const W = 960;
export const H = 640;
export const S = 2;

export const PLAYER_X = 40 * S;
// Herbert's Box2D hull (points, y up, relative to his center).
export const HERB_HULL = [[24.7, 18], [-1.2, 25], [-20, 11.7], [-16.7, -13.2], [1.2, -14.7], [21.5, -2.7]];
export const MAX_HEALTH = 300;
export const SPAWN_INTERVAL = 1.2;
export const ITEM_INTERVAL = 5.0;
export const MAX_DIFFICULTY = 20;
export const LSD_SECONDS = 5;

// Difficulty rises every time a 14.7 s music loop ends.
export const SPEED_TABLE = {
  2: [1.5, 0.2], 4: [2.0, 0.3], 6: [2.5, 0.35], 8: [2.75, 0.4], 10: [3.0, 0.45],
  12: [3.25, 0.5], 14: [3.5, 0.55], 16: [3.75, 0.6], 18: [4.0, 0.65], 20: [4.25, 0.7],
};

// minDifficulty = from which difficulty level the enemy joins the spawn pool
// bubble = speech bubble position in points from the sprite's bottom-left corner (y up)
// hull = Box2D polygon (points, y up, from the center); enemies without one use a frame-sized box
export const ENEMIES = {
  FlyFred:    { anim: 'flyfred',    kill: 'fred',       hp: 4,  strength: 50,  points: 127, dur: [4.5, 6],  yRange: 30, yMin: 0,  minDifficulty: 0, bubble: [-25, 38] },
  FlySina:    { anim: 'flysina',    kill: 'sina',       hp: 2,  strength: 50,  points: 118, dur: [4, 5],    yRange: 10, yMin: 30, minDifficulty: 0, bubble: [-15, 35] },
  BugOona:    { anim: 'bugoona',    kill: 'oona',       hp: 4,  strength: 100, points: 207, dur: [4.5, 6],  yRange: 30, yMin: 50, minDifficulty: 0, bubble: [-25, 30] },
  BugLina:    { anim: 'buglina',    kill: 'lina',       hp: 6,  strength: 100, points: 575, dur: [4.5, 6],  yRange: 30, yMin: 30, minDifficulty: 0, bubble: [-25, 30] },
  BugGilbert: { anim: 'buggilbert', kill: 'gilbert',    hp: 2,  strength: 50,  points: 55,  dur: [5, 6.5],  yRange: 0,  yMin: 0,  minDifficulty: 2, follows: true, bubble: [-20, 40],
                hull: [[-8.9, 6.5], [-18.5, -7.3], [-14.6, -18.6], [1.1, -24.8], [13.3, -16.2], [12.8, -4.2]] },
  // The original had Bibi and Bibi2 as copied classes; Bibi2 (look 1) never got the hull or
  // the pooping. Merged into one bird with two looks; weight 2 keeps the original bird rate.
  Bibi:       { anim: 'bibi',       kill: 'birdy',      hp: 10, strength: 150, points: 999, dur: [9, 10],   yRange: 80, yMin: 0,  minDifficulty: 2, bird: true, weight: 2, bubble: [-20, 100],
                poopVariant: 0, hullScale: { 1: [233 / 214, 249 / 238] },
                hull: [[-9, 46.2], [-38.2, 29], [-50.7, -4.5], [-33.2, -42], [12.7, -50], [49.2, -20.5], [42, 25.7], [12.2, 46.2]] },
  Fuckbutton: { anim: 'fuckbutton', kill: 'fuckbutton', hp: 1,  strength: 50,  points: 251, dur: [5, 6.5],  yRange: 30, yMin: 0,  minDifficulty: 4, variantCount: 3, bubble: [0, 0] },
  LadyBug:    { anim: 'ladybug',    kill: 'ladybug',    hp: 5,  strength: 100, points: 332, dur: [4.5, 5.5], yRange: 150, yMin: 0, minDifficulty: 4, bubble: [-30, 30] },
  FlyBob:     { anim: 'flybob',     kill: 'bob',        hp: 4,  strength: 100, points: 213, dur: [4.5, 6],  yRange: 30, yMin: 50, minDifficulty: 6, bubble: [-30, 30] },
  FlyRobert:  { anim: 'flyrobert',  kill: 'robert',     hp: 1,  strength: 50,  points: 69,  dur: [4, 6],    yRange: 30, yMin: 40, minDifficulty: 6, bubble: [-20, 40] },
};

// legs: 0 = none, 1 = small weapon grip, 2 = big weapon grip
// offset/origin: the held gun, from Herbert.mm's _globalWeaponInfo (converted to y-down, 2x).
// spawn/anchor: where projectiles start, in original points relative to Herbert (y up),
// and their cocos anchorPoint. An anchor outside 0..1 pushes the sprite ahead of its
// pivot along the aim line, which is how bullets appear at the barrel tip.
// beam: the laser/rainbow sprite, its position (at) and pivot (points from the beam's
// left edge, and up from its middle).
// reload: the original refired held guns every 0.05 s unless a reload delay applied.
export const WEAPONS = {
  0:  { key: 'shitball', name: 'Gagi', ammo: Infinity, reload: 0.5, speed: 350, strength: 2, legs: 0, icon: 'ammoicon_gagi', sfx: 'pewpew',
        projectile: 'shot_normal', spawn: [12, -15], anchor: [-60 / 32, 10 / 32] },
  1:  { key: 'mg', name: 'Kalaschnikov', ammo: 25, reload: 0.1, speed: 300, strength: 2, legs: 1, icon: 'ammoicon_kalaschnikov', sfx: 'kalaschnikov',
        projectile: 'kalaschnikov_bullet', spawn: [8, -13.5], anchor: [-3, 0.5], frame: 'kalaschnikov', offset: [16, 28], origin: [0.318, 0.231] },
  2:  { key: 'laser', name: 'Lasergun', ammo: 30, reload: 0.05, strength: 1, legs: 2, icon: 'ammoicon_laser', sfx: 'lasergun',
        beam: { frame: 'lasershot', at: [-2, -42], pivot: [-32, 5] }, frame: 'lasergun', offset: [-6, 84], origin: [0.32, 0.321] },
  3:  { key: 'minigun', name: 'Minigun', ammo: 50, reload: 0.05, speed: 1200, strength: 2, legs: 2, icon: 'ammoicon_minigun', sfx: 'minigun',
        projectile: 'minigun_shot', spawn: [-10, -44], jitter: 10, anchor: [-9, 0.5], spread: 20, warmup: 0.1, frame: 'minigun', offset: [-14, 90], origin: [0.3, 0.5] },
  4:  { key: 'pumpgun', name: 'Pumpgun', ammo: 8, reload: 1.0, speed: 1800, strength: 2, legs: 1, icon: 'ammoicon_pumpgun', sfx: 'pumpgun_shot',
        projectile: 'pumpgun_shot', spawn: [0, -20], anchor: [-10, 0.7], pellets: 6, frame: 'pumpgun', offset: [10, 46], origin: [0.195, 0.3] },
  5:  { key: 'rocket', name: 'Rocketlauncher', ammo: 5, reload: 1.8, speed: 300, strength: 8, legs: 2, icon: 'ammoicon_rocket', sfx: 'rocketlauncher',
        projectile: 'rocket', spawn: [-5, -45], anchor: [0.5, 0.5], explodes: true, frame: 'rocketlauncher', offset: [-8, 80], origin: [0.415, 0.386] },
  6:  { key: 'rainbow', name: 'Rainbowgun', ammo: 45, reload: 0.05, strength: 1, legs: 2, icon: 'ammoicon_rainbow', sfx: 'rainbowgun',
        beam: { frame: 'rainbowgun_shot', at: [-7, -47], pivot: [-30, 0] }, frame: 'rainbowgun', offset: [-4, 94], origin: [0.4, 0.391] },
  7:  { key: 'tabasco', name: 'Tabasco', ammo: 15, reload: 0.25, speed: 350, strength: 2, legs: 2, icon: 'ammoicon_tabasco', sfx: 'pewpew',
        projectile: 'shot_tabasco', spawn: [12, -15], anchor: [-60 / 32, 10 / 32], frame: 'tabasco', offset: [-32, 70], origin: [0.232, 0.361] },
  8:  { key: 'flygun', name: 'Flygun', ammo: 5, reload: 1.0, strength: 2, legs: 2, icon: 'ammoicon_flygun', sfx: 'flygun',
        homing: 3, spawn: [10, -45], frame: 'flygun', offset: [-20, 80], origin: [0.415, 0.386] },
  9:  { key: 'ubergun', name: 'Übergun', ammo: 3, reload: 0.4, legs: 2, icon: 'ammoicon_uebergun', sfx: 'ubergun',
        lightning: true, frame: 'uebergun', offset: [-6, 92], origin: [0.415, 0.386] },
  10: { key: 'bugspray', name: 'Bugspray', ammo: 30, reload: 0.05, strength: 1, legs: 2, icon: 'ammoicon_bugspray', sfx: 'bugspray',
        spray: true, spawn: [26, -21], frame: 'bugspray', offset: [-6, 92], origin: [0.415, 0.386] },
};

// Pickup items. Weapon pickups refill ammo if the same gun is already held.
// burst = the two particle frames of the pickup ring (ItemUpParticle).
export const ITEMS = {
  Capushito:      { frame: 'caposhito', anim: true, burst: [15, 16] },
  LsdStar:        { frame: 'star', anim: true },
  ProtectSuit:    { frame: 'prot_', anim: true, burst: [1, 8] },
  Coin:           { frame: 'ring', anim: true, burst: [0, 6] },
  Kalaschnikov:   { frame: 'icon_kalaschnikov', weapon: 1 },
  LaserGun:       { frame: 'icon_lasergun', weapon: 2 },
  MiniGun:        { frame: 'icon_minigun', weapon: 3 },
  PumpGun:        { frame: 'icon_pumpgun', weapon: 4 },
  RocketLauncher: { frame: 'icon_rocketlauncher', weapon: 5 },
  RainbowGun:     { frame: 'icon_rainbowgun', weapon: 6 },
  TabascoShot:    { frame: 'icon_tabasco', weapon: 7 },
  FlyGun:         { frame: 'icon_flygun', weapon: 8 },
  UberGun:        { frame: 'icon_ubergun', weapon: 9 },
  BugSpray:       { frame: 'icon_bugspray', weapon: 10 },
};

export const INITIAL_ITEMS = ['LsdStar', 'ProtectSuit', 'Capushito'];

// Score thresholds that unlock new pickups (persisted between runs, as on iOS).
export const UNLOCKS = [
  [5000, ['TabascoShot', 'FlyGun', 'BugSpray']],
  [10000, ['Kalaschnikov', 'PumpGun', 'LaserGun']],
  [20000, ['MiniGun', 'RainbowGun', 'RocketLauncher']],
  [40000, ['UberGun']],
];

// Sky gradient darkens as Herbert loses health (updateHealthBar).
export const SKY_BY_HEALTH = [
  [300, 0xf6fdff, 0xade0f5],
  [250, 0xf2fbf5, 0xa1d1e3],
  [200, 0xeffaed, 0x96c3ca],
  [150, 0xecf9e2, 0x8bb5c4],
  [100, 0xe9f8db, 0x81a7b3],
  [50, 0xe8f8d8, 0x6b8c95],
  [0, 0xe8f8d8, 0x526b73],
];

export const LANGS = ['en', 'de', 'ch'];

export const TEXT = {
  en: { play: 'tap to play', retry: 'tap to try again', score: 'score', best: 'best', paused: 'paused', died: 'Herbert is dead.', subtitle: 'he only had one day anyway.' },
  de: { play: 'tippen zum spielen', retry: 'nochmal versuchen', score: 'punkte', best: 'rekord', paused: 'pause', died: 'Herbert ist tot.', subtitle: 'er hatte eh nur einen Tag.' },
  ch: { play: 'tippä zum spilä', retry: 'nomau probierä', score: 'pünkt', best: 'rekord', paused: 'pause', died: 'Dr Herbert isch tot.', subtitle: 'är het ja eh nume ei Tag gha.' },
};
