import { WEAPONS } from './data.js';
import { settings } from './ui.js';

// Herbert is a rig of separately animated parts (body, snout, two legs, gun),
// exactly like the original batch node. Offsets are from Herbert.mm, y-down, 2x.
const LEGS = {
  0: { back: 'herb_leg_norm_', front: 'herb_leg_norm2_', b: [-40, 60], f: [-16, 60] },
  1: { back: 'herb_leg_wsm1_', front: 'herb_leg_wsm2_', b: [-32, 58], f: [-8, 58] },
  2: { back: 'herb_leg_wbg1_', front: 'herb_leg_wbg2_', b: [-28, 66], f: [-4, 66] },
};

export class Herbert extends Phaser.GameObjects.Container {
  constructor(scene, x, y) {
    super(scene, x, y);
    this.rig = scene.add.container(0, 0);
    this.add(this.rig);

    this.legFront = scene.add.sprite(0, 0, 'clct_herbert');
    this.weapon = scene.add.sprite(0, 0, 'clct_herbert').setVisible(false);
    this.bodySprite = scene.add.sprite(0, -6, 'clct_herbert');
    this.snout = scene.add.sprite(16, 36, 'clct_herbert');
    this.snoutShoot = scene.add.sprite(32, 26, 'clct_herbert', 'herbert_shooting').setVisible(false);
    this.legBack = scene.add.sprite(0, 0, 'clct_herbert');
    this.rig.add([this.legFront, this.weapon, this.bodySprite, this.snout, this.snoutShoot, this.legBack]);

    this.weaponType = 0;
    this.tilt = 0;
    this.hasSuit = false;
    this.onDrugs = false;
    this.setLegs(0);
    scene.add.existing(this);
  }

  get bodyAnim() {
    if (this.onDrugs) return 'herbert_drugz';
    if (this.hasSuit) return 'herbert_prot';
    if (this.tilt < 0) return 'herbert_up';
    if (this.tilt > 0) return 'herbert_down';
    return 'herbert';
  }

  // Body, snout and legs are separate 8-frame loops whose bounce only lines up
  // when they run in lockstep, so every change restarts all of them together
  // (AnimationSprite restartAnimation in the original).
  refreshBody(force = false) {
    const key = this.bodyAnim;
    if (!force && this.bodySprite.anims.currentAnim?.key === key) return;
    const l = LEGS[this.legGrip];
    this.bodySprite.play(key);
    this.snout.play('herbert_trunk');
    this.legBack.play(l.back.replace(/_$/, '') + '_anim');
    this.legFront.play(l.front.replace(/_$/, '') + '_anim');
  }

  setLegs(type) {
    this.legGrip = type;
    this.placeLegs();
    this.refreshBody(true);
  }

  placeLegs() {
    const l = LEGS[this.legGrip];
    let b = l.b, f = l.f;
    if (this.legGrip === 0 && this.tilt < 0) { b = [-40, 56]; f = [-16, 64]; }
    if (this.legGrip === 0 && this.tilt > 0) { b = [-40, 64]; f = [-16, 56]; }
    this.legBack.setPosition(...b);
    this.legFront.setPosition(...f);
  }

  // Like the original, tilt poses only exist for the unarmed, suitless, sober Herbert.
  setTilt(dir) {
    if (this.weaponType !== 0 || this.hasSuit || this.onDrugs) dir = 0;
    if (dir === this.tilt) return;
    this.tilt = dir;
    if (dir !== 0 && settings.sfx) this.scene.sound.play(dir < 0 ? 'herbert_bzzt1' : 'herbert_bzzt2', { volume: 0.5 });
    this.placeLegs();
    this.refreshBody();
  }

  changeWeapon(type) {
    if (this.onDrugs) return;
    if (this.weaponType !== 0) this.dropWeapon(false);
    this.weaponType = type;
    this.tilt = 0;
    const w = WEAPONS[type];
    this.setLegs(w.legs);
    if (type === 0) return;
    this.weapon.setFrame(w.frame).setOrigin(...w.origin).setPosition(...w.offset).setAngle(0).setVisible(true);
  }

  dropWeapon(animate = true) {
    if (this.weaponType === 0) return;
    if (animate) {
      const m = this.getWorldTransformMatrix();
      const ghost = this.scene.add.image(m.tx + this.weapon.x, m.ty + this.weapon.y, 'clct_herbert', this.weapon.frame.name)
        .setOrigin(this.weapon.originX, this.weapon.originY).setAngle(this.weapon.angle).setDepth(this.depth);
      this.scene.tweens.add({ targets: ghost, y: ghost.y + 600, angle: ghost.angle + 90, duration: 1000, onComplete: () => ghost.destroy() });
    }
    this.weapon.setVisible(false);
    this.weaponType = 0;
    this.setLegs(0);
  }

  aim(angleDeg) {
    // Beam/spray guns don't rotate in the original, only the projectile guns do.
    if ([1, 4, 5].includes(this.weaponType)) this.weapon.setAngle(angleDeg);
  }

  shootFx(angleDeg) {
    if (this.weaponType === 0) {
      this.snout.setVisible(false);
      this.snoutShoot.setVisible(true).setAngle(angleDeg * 0.5);
      this.scene.time.delayedCall(120, () => { this.snout.setVisible(!this.onDrugs); this.snoutShoot.setVisible(false); });
      return;
    }
    this.aim(angleDeg);
    const [ox, oy] = WEAPONS[this.weaponType].offset;
    this.scene.tweens.add({ targets: this.weapon, x: ox - 10, duration: 60, yoyo: true, onComplete: () => this.weapon.setPosition(ox, oy) });
  }

  setSuit(on, broken = false) {
    if (on === this.hasSuit) return;
    this.hasSuit = on;
    this.refreshBody();
    if (!broken) return;
    const fail = this.scene.add.image(0, 10, 'clct_herbert', 'herb_protection_fail');
    this.rig.add(fail);
    this.scene.tweens.add({ targets: fail, x: -100, duration: 200, onComplete: () => fail.destroy() });
  }

  setDrugs(on) {
    this.onDrugs = on;
    [this.legBack, this.legFront, this.snout].forEach((p) => p.setVisible(!on));
    if (on) this.dropWeapon(false);
    this.refreshBody();
    this.scene.tweens.add({ targets: this.rig, x: on ? 250 : 0, duration: 500 });
  }

  // CCBlink: 11 hard on/off blinks over 2 s.
  blink(ms = 2000, times = 11) {
    this.scene.time.addEvent({ delay: ms / (times * 2), repeat: times * 2 - 1, callback: () => this.rig.setVisible(!this.rig.visible) });
    this.scene.time.delayedCall(ms + 20, () => this.rig.setVisible(true));
  }

  die() {
    this.dropWeapon();
    [this.legBack, this.legFront, this.snout, this.snoutShoot].forEach((p) => p.setVisible(false));
    this.bodySprite.play('herbert_gover');
    this.scene.tweens.add({ targets: this.rig, angle: 60, duration: 1000 });
    this.scene.tweens.add({ targets: this.rig, x: 800, y: 800, duration: 4000 });
  }

  // Hit box roughly matching the 30x60pt rect used for item pickups.
  get hitRect() {
    const ox = this.onDrugs ? 250 : 0;
    return new Phaser.Geom.Rectangle(this.x + ox - 50, this.y - 50, 100, 90);
  }
}
