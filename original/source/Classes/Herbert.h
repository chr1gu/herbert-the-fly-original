//
//  Herbert.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/2/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MotionSprite.h"
#import "AnimationSprite.h"


@interface Herbert : CCSprite
{
	AnimationSprite *_leg_front;
	AnimationSprite *_leg_back;
    
    // this will hold the animated herb body
    AnimationSprite *herbAnimation;
    AnimationSprite *herbTrunk;
    CCSpriteBatchNode *batchContainer;
    
    CCSprite *_trunkShoot;
	
	float _upAndDownFly;
    float _yPos;
	int _weaponType;
	CCSprite *_weapon;
	CGPoint _weaponPos;
	NSArray *_globalWeaponInfo;
    
    float _positionDelay;
    float _positionTime;
    float _positionX;
	
	// shot action
	CCAction *shot;
}

@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) BOOL hasProtSuit;
@property (nonatomic, assign) BOOL hasDrugz;


-(void) attachLegs: (int)type;

- (void) shoot: (int) angle;
- (void) aimGun: (int) angle;
- (void) stopShooting;
- (void) updatePosition: (float) posY;
- (void) updatePosition: (float) posY: (float) posX: (float) delay: (float) time;
- (void) dropWeapon;
- (void) changeWeapon: (int) weaponType;
- (void) enableLSD;
- (void) disableLSD;
- (void) getProtectSuit;
- (void) dropProtectSuit;
- (void) dropProtectSuitWithAnimation:(BOOL)withAnimation;
- (void) deathAni;
- (void) blink;
- (void) tiltUp;
- (void) tiltDown;
- (void) stopTilting;
- (void) scheduleMovement;
- (void) unscheduleMovement;
- (void) prepareDealloc;

- (float) getContainerXPos;

@end
