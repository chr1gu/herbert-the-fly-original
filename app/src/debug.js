import { ENEMIES, WEAPONS, ITEMS, UNLOCKS, INITIAL_ITEMS } from './data.js';
import { store } from './ui.js';

// Shared with GameScene; survives restarts within the page session.
export const debugState = { god: false, infiniteAmmo: false, noSpawn: false, hitboxes: false };

export const debugEnabled = new URLSearchParams(location.search).has('debug');

const WEAPON_ITEM = Object.fromEntries(Object.entries(ITEMS).filter(([, d]) => d.weapon).map(([k, d]) => [d.weapon, k]));

export function initDebug(game) {
  if (!debugEnabled) return;

  const scene = () => game.scene.getScene('game');
  const inGame = () => game.scene.isActive('game');
  const ensureGame = () => {
    if (inGame()) return true;
    game.scene.getScenes(true)[0]?.scene.start('game');
    return false;
  };
  const act = (fn) => () => { if (ensureGame()) fn(scene()); };

  const panel = document.createElement('div');
  panel.id = 'debug';
  panel.innerHTML = `
    <style>
      #debug { position: fixed; top: 8px; right: 8px; z-index: 10; max-height: calc(100vh - 16px); overflow: auto;
        width: 260px; padding: 8px 10px; border-radius: 10px; background: rgba(22,22,22,.88); color: #eee;
        font: 12px/1.3 system-ui, sans-serif; user-select: none; }
      #debug.collapsed { width: auto; }
      #debug.collapsed > :not(header) { display: none; }
      #debug header { display: flex; justify-content: space-between; align-items: center; gap: 8px; font-weight: 700; cursor: pointer; }
      #debug h4 { margin: 10px 0 4px; font-size: 11px; text-transform: uppercase; letter-spacing: .06em; color: #f5d94a; }
      #debug .row { display: flex; flex-wrap: wrap; gap: 4px; }
      #debug button { padding: 4px 7px; border: 1px solid #555; border-radius: 6px; background: #333; color: #eee; font: inherit; cursor: pointer; }
      #debug button:hover { background: #444; }
      #debug button.on { background: #f5d94a; color: #222; border-color: #f5d94a; }
      #debug .status { margin-top: 8px; color: #aaa; white-space: pre; font-family: ui-monospace, monospace; font-size: 11px; }
    </style>
    <header><span>Herbert debug</span><span class="toggle">–</span></header>
  `;
  document.body.append(panel);
  if (innerWidth < 700) panel.classList.add('collapsed');
  panel.querySelector('header').onclick = () => {
    panel.classList.toggle('collapsed');
    panel.querySelector('.toggle').textContent = panel.classList.contains('collapsed') ? '+' : '–';
  };
  // Keep keyboard focus on the game so space/WASD don't trigger panel buttons.
  panel.addEventListener('mousedown', (e) => e.preventDefault());

  const section = (title, buttons) => {
    const h = document.createElement('h4');
    h.textContent = title;
    const row = document.createElement('div');
    row.className = 'row';
    for (const [text, onClick, isOn] of buttons) {
      const b = document.createElement('button');
      b.textContent = text;
      b.tabIndex = -1;
      b.onclick = () => { onClick(); refresh(); };
      if (isOn) b.dataset.toggle = '1';
      b._isOn = isOn;
      row.append(b);
    }
    panel.append(h, row);
  };

  const toggle = (key) => () => { debugState[key] = !debugState[key]; };

  section('Run', [
    ['Start / restart', () => game.scene.getScenes(true)[0]?.scene.start('game')],
    ['Speed up', act((g) => { g.levelUp(); g.levelUp(); })],
    ['Kill all', act((g) => g.killAll())],
    ['Die', act((g) => { debugState.god = false; g.hitPlayer(9999); })],
  ]);
  section('Toggles', [
    ['God mode', toggle('god'), () => debugState.god],
    ['∞ ammo', toggle('infiniteAmmo'), () => debugState.infiniteAmmo],
    ['No spawns', toggle('noSpawn'), () => debugState.noSpawn],
    ['Hitboxes', toggle('hitboxes'), () => debugState.hitboxes],
  ]);
  section('Weapons', Object.entries(WEAPONS).map(([type, w]) => [
    w.name,
    act((g) => (Number(type) === 0 ? g.dropWeapon() : g.applyItem(WEAPON_ITEM[type]))),
  ]));
  section('Items', [
    ['Protection suit', act((g) => g.applyItem('ProtectSuit'))],
    ['LSD star', act((g) => g.applyItem('LsdStar'))],
    ['Cappuccino', act((g) => g.applyItem('Capushito'))],
    ['Coin', act((g) => g.applyItem('Coin'))],
    ['Drop pickups', act((g) => ['ProtectSuit', 'LsdStar', 'Capushito', 'Kalaschnikov'].forEach((i) => g.addItem(i, true)))],
  ]);
  section('Health', [
    ['Heal', act((g) => { g.health = 300; g.updateHealth(); })],
    ['Hurt 50', act((g) => { const god = debugState.god; debugState.god = false; g.hitPlayer(50); debugState.god = god; })],
  ]);
  section('Spawn enemy', Object.keys(ENEMIES).map((name) => [name, act((g) => g.addEnemy(name))]));
  section('Save data', [
    ['Unlock all items', () => store.set('unlockedItems', [...INITIAL_ITEMS, ...UNLOCKS.flatMap(([, i]) => i)])],
    ['Reset save', () => { ['unlockedItems', 'highscore'].forEach((k) => store.set(k, k === 'highscore' ? 0 : INITIAL_ITEMS)); }],
  ]);

  const status = document.createElement('div');
  status.className = 'status';
  panel.append(status);

  function refresh() {
    panel.querySelectorAll('button[data-toggle]').forEach((b) => b.classList.toggle('on', b._isOn()));
  }
  refresh();

  setInterval(() => {
    if (!inGame()) { status.textContent = 'not in game – press Start'; return; }
    const g = scene();
    status.textContent = [
      `hp ${g.health}  pts ${g.points}`,
      `level ${g.difficulty}  speed ${g.gameSpeed}x`,
      `gun ${WEAPONS[g.player.weaponType].name}  ammo ${g.ammo === Infinity ? '∞' : g.ammo}`,
      `enemies ${g.enemies.length}  shots ${g.shots.length}  items ${g.items.length}`,
    ].join('\n');
  }, 250);
}
