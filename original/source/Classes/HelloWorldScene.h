//
//  HelloWorldLayer.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/31/10.
//  Copyright Etite 2010. All rights reserved.
//

#import "cocos2d.h"
#import "Herbert.h"
#import "SimpleAudioEngine.h"
#import "SFXMenuItemFont.h"
#import "Box2D.h"
#import "Projectile.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "Monster.h"
#import "GameConfig.h"
#import "GameOverScene.h"
#import "Item.h"
#import "LayerGradientAnim.h"
#import "TutorialBriefing.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	NSMutableArray *_items;
	int _projectilesDestroyed;
	
	// GENERAL SPEED:
	float _gameSpeed;
    float _increasedSpawnRate;
	int _gameTimeSeconds;
	int _itemLevel;
	int _difficultyLevel;
    int checkCollisions;
	
	CCSprite *_drugbg;
	
	// Player
	Herbert *_player;
    BOOL _dropWeaponDelayed;
	BOOL _lsdMode;
	BOOL _godMode;
	BOOL _protectMode;
    BOOL _scheduleBulletModeSFX;
	float _lastAccelY;
    BOOL _ueberlightening;
	int _lsdCountdown;
    CGPoint _playerInitPos;
	
	// This affects the players speed..
	float _itemWeight;
	
	// BOX2D
	b2World *_world;
	GLESDebugDraw *_debugDraw;
	MyContactListener *_contactListener;
	
	// Wheapons
	int _wheaponType;
	int _wheaponAmmo;
	int _points;
    int _pointsDisplay;
	BOOL _wheaponReloaded;
	BOOL _bulletMGMode;
	CGPoint _lastBulletLocation;
    CGPoint _lastHerbLocation;
	CGPoint _rocketPosition;
	CCLabelTTF *_ammoBar;
	CCLabelTTF *_pointsBar;
    CCSprite *_ammoLabel;
	AVAudioPlayer *_drugSound;
	Projectile *_laserBeam;
	Projectile *_rainbow;
    
    BOOL minigunWarmedUp;
    
    ALuint _laserNoise;
    ALuint _rainbowNoise;
	
    LayerGradientAnim *_background;
	CCSprite *_flashSprite;
	
    BOOL _tilting;
	BOOL _paused;
    BOOL _hasRainbow;
	CCSprite *_pauseMenu;
	CCMenuItemImage *_tutCloseBtn;
    CCMenuItemImage *_pauseBtn;
    CCMenuItemImage *_pauseMenuSponsor;
	SFXMenuItemFont *_pauseMenuContinue;
	SFXMenuItemFont *_pauseMenuRestart;
	SFXMenuItemFont *_pauseMenuMain;
	
	// health..
	int _health;
	int _maxHealth;
	CCSprite *_healthBar;
    CCSprite *_healthbarRaster;
	
    TutorialBriefing *tut;
    BOOL _tutorialMode;
    int _tutorialLevel;
    
    // performance
    CCSpriteBatchNode *objectBatchNode;
    CCSpriteBatchNode *environmentBatchNode;
    CCParticleBatchNode *particleBatchNode;
    
    // gameover
    GameOverScene *gameOverScene;
    
    // DEBUG..
    BOOL _isIphoneSimulator;
}

- (void) warmupMinigun;

- (void) addItem;
- (void) addItem:(Item *)item;
- (void) addItem:(Item *)item:(bool)forceAdd;
- (void) addBoxBodyForSprite:(CCSprite *)sprite;
- (void) getItem:(Item *)item;
- (void) targetHitsHerbert:(Monster *)monster;
- (void) bulletHitsTarget:(CCSprite *)projectile:(CCSprite *)monster:(NSMutableArray *)objectsToDelete;
- (Item *) chooseItem;
- (Monster *) chooseTarget;

- (void) spriteMoveFinished:(id)sender;
- (void) removeCloud:(id)sender;
- (void) flashMessage:(int)msgType;
- (void) resetEmitter1;
- (void) resetEmitter2;
- (void) resetEmitter3;
- (void) resetEmitter4;
- (void) enemyDeath:(Monster *)enemy;
- (void) killAllEnemies;
- (void) ueberlightening;
- (void) ueberlighteningFinished;
- (void) repeatingGroundClouds;
- (void) vibrate;
- (void) speedUpdate;
- (void) initGameStartCountdown;
- (void) initGameTutorial;
- (void) disableGameControlls;
- (void) gameOverSceneChange;
- (void) clearStage;
- (void) enableGodMode;
- (void) gamePause;
- (void) gameSponsorMenu: (id)sender;
- (void) gamePauseMenu: (id)sender;
- (void) gameMainMenu: (id)sender;
- (void) gameRestart: (id)sender;
- (void) gameResume: (id)sender;
- (void) changeWeaponAmmo;
- (void) changeWeaponAmmo: (int)weaponType;
- (void) backgroundMusicFinished;
- (void) enableGameControlls;
- (void) itemScheduler;
- (void) flyHitHerb:(id)sender;
- (void) hitPlayer:(int)damage;
- (void) reactivateBulletModeSFX;

- (void) cacheAnimations;
- (void) cacheAnimation:(NSString *)name: (NSString *)prefix: (int)framecount;

- (void) enemyRemoved;
- (void) tut4:(id)sender;
- (void) tut3:(id)sender;
- (void) tut2:(id)sender;
- (void) tut1:(id)sender;
- (void) addTutorialObjects;

- (void) delayedDropWeapon;
- (void) dropWeapon;

- (void) clearScene;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
+(id) tutorialMode;

@end
