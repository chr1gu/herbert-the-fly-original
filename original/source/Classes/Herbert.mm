//
//  Herbert.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/2/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Herbert.h"
#import "SimpleAudioEngine.h"

//#define BEAT_RATE 0.06
#define BEAT_RATE 0.0575
#define NEW_BEAT_RATE 0.46

@implementation Herbert

@synthesize offset;
@synthesize hasProtSuit;
@synthesize hasDrugz;

-(void) normalizeTrunk: (ccTime) dt
{
    if (!_leg_front.visible && !_leg_back.visible) {
        // asume we're in drug mode or game overani
        return;
    }
	herbTrunk.visible = YES;
	_trunkShoot.visible = NO;
}

-(void) changeWeapon: (int) weaponType {
    
    if (self.hasDrugz) return;
	
	if (_weaponType != 0) {
		[self dropWeapon];
        [self stopTilting];
	}
	
	switch (weaponType)
	{
		case 0:
			// no weapon
			[self attachLegs:0];
			break;
		case 1:
			// mg;
			[self attachLegs:1];
			break;
		case 2:
			// laser
			[self attachLegs:2];
			break;
		case 3:
			// minigun
			[self attachLegs:2];
			break;
		case 4:
			// shotgun
			[self attachLegs:1];
			break;
		case 5:
			// rocketlauncher
			[self attachLegs:2];
			break;
		case 6:
			// rainbowgun
			[self attachLegs:2];
			break;
		case 7:
			// tabasco
			[self attachLegs:2];
			break;
		case 8:
			// flygun
			[self attachLegs:2];
			break;
		case 9:
			// ubergun
			[self attachLegs:2];
			break;
		case 10:
			// ubergun
			[self attachLegs:2];
			break;
		default:
			// undeclared weapon..
			[self attachLegs:0];
			break;
	}
	
	if (weaponType <= _globalWeaponInfo.count && weaponType != 0) {
		_weaponPos = [[[_globalWeaponInfo objectAtIndex:weaponType-1] objectAtIndex:1] CGPointValue];
		_weapon = [CCSprite spriteWithSpriteFrameName:[[_globalWeaponInfo objectAtIndex:weaponType-1] objectAtIndex:0]];
		_weapon.anchorPoint = [[[_globalWeaponInfo objectAtIndex:weaponType-1] objectAtIndex:2] CGPointValue];
		_weapon.position = [[[_globalWeaponInfo objectAtIndex:weaponType-1] objectAtIndex:1] CGPointValue];
		_weapon.visible = YES;
		[batchContainer addChild:_weapon z:3];
	}
	
	_weaponType = weaponType;
    [herbAnimation restartAnimation];
    [herbTrunk restartAnimation];
}

- (void) enableLSD
{
    if (!self.hasDrugz)
    {
        self.hasDrugz = YES;
        [self stopAction:shot];
        _trunkShoot.visible = NO;
        herbTrunk.visible = NO;
        _leg_front.visible = NO;
        _leg_back.visible = NO;

        [herbAnimation applyNewAnimation:@"herbert_drugz" withDelay:NEW_BEAT_RATE*2];
        [batchContainer runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(batchContainer.position.x+125,batchContainer.position.y)]];
    }
}
- (void) disableLSD
{
    if (self.hasDrugz)
    {
        self.hasDrugz = NO;
        [_leg_back restartAnimation];
        [_leg_front restartAnimation];
        [herbTrunk restartAnimation];
        herbTrunk.visible = YES;
        _leg_front.visible = YES;
        _leg_back.visible = YES;
        
        [herbAnimation applyNewAnimation:@"herbert" withDelay:NEW_BEAT_RATE];
        [batchContainer runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(25,batchContainer.position.y)]];
    }
}

- (void) dropWeapon {
	
	if (!_weapon) {
		return;
	}
    
	CCSprite *weaponCopy = [CCSprite spriteWithSpriteFrame:[_weapon displayedFrame]];
	weaponCopy.position = _weapon.position;
	weaponCopy.anchorPoint = _weapon.anchorPoint;
	weaponCopy.rotation = _weapon.rotation;
	
	[batchContainer addChild:weaponCopy z:3];
	[weaponCopy runAction:[CCSequence actions: 
					[CCMoveTo actionWithDuration:1 position:ccp(weaponCopy.position.x, weaponCopy.position.y-300)],
					[CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)], nil]];
	
	// reset weapon..
	[batchContainer removeChild:_weapon cleanup:YES];
	_weapon = nil;
	_weaponType = 0;
	[self attachLegs:0];
    [self stopTilting];
    [herbAnimation restartAnimation];
    [herbTrunk restartAnimation];
}

// autoremove after animation
-(void)spriteMoveFinished:(id)sender {
	CCSprite *sprite = (CCSprite *)sender;
    if (sprite.tag == 5) {
        [self removeChild:sprite cleanup:YES];
    }
    else {
        [batchContainer removeChild:sprite cleanup:YES];
    }
	
	sprite = nil;
}


- (void) stopShooting {
	
	// Rotate automatic weapons back..
	switch (_weaponType) {
		case 2:
		case 3:
		case 6:
			[_weapon runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
			break;
        case 9:
            [_weapon stopAllActions];
            break;
		default:
			break;
	}
}

// this is mainly used for the fly gun and guns with delayed shoots..
- (void) aimGun: (int) angle
{
    // handle aiming for rainbow, minigun, laser in shooting method
    // ignore bugspray, flygun and ubergun aiming
    if (_weaponType == 2 || _weaponType == 3 || _weaponType == 6 || _weaponType == 7 || _weaponType == 8 || _weaponType == 9 || _weaponType == 10) {
        return;
    }
	_weapon.rotation = angle;
}

- (void) shoot: (int) angle {
	
	switch (_weaponType)
	{
		case 1:
			// pumpgun
			_weapon.rotation = angle;
			// Add punchback
			[_weapon stopAllActions];
			[_weapon runAction:[CCSequence actions:
							[CCMoveTo actionWithDuration:0.1 position:ccp((_weaponPos.x-2), _weaponPos.y)],
							[CCMoveTo actionWithDuration:0.1 position:ccp((_weaponPos.x+2), _weaponPos.y)],
							[CCDelayTime actionWithDuration:0.7],
							[CCRotateTo actionWithDuration:0.2 angle:0],
							nil]];
			break;
			
		case 2:
			// laser
			[_weapon stopAllActions];
			_weapon.rotation = angle;
			break;
			
		case 3:
			// minigun
			_weapon.rotation = angle;
			// Add punchback
			[_weapon runAction:[CCSequence actions:
							[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x-0.5), _weaponPos.y-0.2)],
							[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x+0.5), _weaponPos.y+0.2)], nil]];
			break;
			
		case 4:
			// shotgun
			_weapon.rotation = angle;
			// Add punchback
			[_weapon stopAllActions];
			[_weapon runAction:[CCSequence actions:
							[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-5, _weaponPos.y)],
							[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y)],
						    [CCDelayTime actionWithDuration:1.0],
						    [CCRotateTo actionWithDuration:0.2 angle:0],
							nil]];
			break;
			
		case 5:
			// rocketlauncher
			_weapon.rotation = angle;
			// Add punchback
			[_weapon stopAllActions];
			[_weapon runAction:[CCSequence actions:
								 [CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-5, _weaponPos.y)],
								 [CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y)],
								 [CCDelayTime actionWithDuration:1.7],
								 [CCRotateTo actionWithDuration:0.2 angle:0],
								nil]];
			break;
			
		case 6:
			// rainbowgun
			_weapon.rotation = angle;
			// Add punchback
			[_weapon runAction:[CCSequence actions:
										[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-5, _weaponPos.y)],
										[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y)], nil]];
			break;
		
			
		case 8:
			// flygun
			// shake around..
			[_weapon runAction:[CCSequence actions:
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-5, _weaponPos.y-1)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x+1, _weaponPos.y+2)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-3, _weaponPos.y+5)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y+3)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x+3, _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y)], nil]];
			break;
			
		case 9:
			// übergun
			//_weapon.rotation = angle;
			// Add punchback
			[_weapon runAction:[CCSequence actions:
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+1)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-2)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y+3)],
								[CCMoveTo actionWithDuration:0.05 position:ccp((_weaponPos.x), _weaponPos.y-1)],
								nil]];
			break;
            
        case 10:
            // bugspray
			[_weapon stopAllActions];
			[_weapon runAction:[CCSequence actions:
                                [CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x-5, _weaponPos.y)],
                                [CCMoveTo actionWithDuration:0.1 position:ccp(_weaponPos.x, _weaponPos.y)],
								nil]];
            break;
			
		case 7:
		default:
			// tabasco or no weapon..
			herbTrunk.visible = NO;
			_trunkShoot.visible = YES;
			_trunkShoot.rotation = angle;
			[self stopAction:shot];
			[self runAction:shot];
			break;
	}
}

- (void) getProtectSuit
{
	if (!self.hasProtSuit)
    {
        self.hasProtSuit = YES;
        [herbAnimation applyNewAnimation:@"herbert_prot" withDelay:NEW_BEAT_RATE];
		[herbTrunk restartAnimation];
		[_leg_back restartAnimation];
		[_leg_front restartAnimation];
	}
}
- (void) dropProtectSuitWithAnimation:(BOOL)withAnimation 
{
    if (self.hasProtSuit)
    {
        self.hasProtSuit = NO;
        [herbAnimation applyNewAnimation:@"herbert" withDelay:NEW_BEAT_RATE];
		[herbTrunk restartAnimation];
		[_leg_back restartAnimation];
		[_leg_front restartAnimation];
        
        // dont show protect suit ani if we're in lsdmode
        if (withAnimation) {
            CCSprite *protFail = [CCSprite spriteWithSpriteFrameName:@"herb_protection_fail.png"];
            protFail.position = ccp(protFail.position.x, herbAnimation.position.x+5);
            [protFail runAction:[CCSequence actions:
                                 [CCMoveBy actionWithDuration:0.2 position:ccp(-50, 0)],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)], nil]];
            [batchContainer addChild:protFail z:10];
        }
	}
}
- (void) dropProtectSuit
{
	[self dropProtectSuitWithAnimation:YES];
}

- (void) blink
{
    [batchContainer runAction:[CCBlink actionWithDuration:2.0 blinks:11]];
}

-(void) attachLegs: (int)type
{	
    BOOL initialRendering = !_leg_back||!_leg_front;
	
	switch (type)
    {
		case 1:
			// small guns
            if (initialRendering) {
                _leg_back = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_wsm1_" cachedAnimation:@"herbert_legs_wsm" delay:NEW_BEAT_RATE];
                _leg_front = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_wsm2_" cachedAnimation:@"herbert_legs_wsm2" delay:NEW_BEAT_RATE];
            } else {
                [_leg_back applyNewAnimation:@"herbert_legs_wsm" withDelay:NEW_BEAT_RATE];
                [_leg_front applyNewAnimation:@"herbert_legs_wsm2" withDelay:NEW_BEAT_RATE];
            }
			_leg_back.position = ccp(-16,-19);
			_leg_front.position = ccp(-4,-19);
			break;
		case 2:
			// big guns
            if (initialRendering) {
                _leg_back = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_wbg1_" cachedAnimation:@"herbert_legs_wbg" delay:NEW_BEAT_RATE];
                _leg_front = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_wbg2_" cachedAnimation:@"herbert_legs_wbg2" delay:NEW_BEAT_RATE];
            } else {
                [_leg_back applyNewAnimation:@"herbert_legs_wbg" withDelay:NEW_BEAT_RATE];
                [_leg_front applyNewAnimation:@"herbert_legs_wbg2" withDelay:NEW_BEAT_RATE];
            }
            _leg_back.position = ccp(-14,-23);
			_leg_front.position = ccp(-2,-23);
			break;
		default:
			// normal legs
            if (initialRendering) {
                _leg_back = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_norm_" cachedAnimation:@"herbert_legs_norm" delay:NEW_BEAT_RATE];
                _leg_front = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_leg_norm2_" cachedAnimation:@"herbert_legs_norm2" delay:NEW_BEAT_RATE];
            } else {
                [_leg_back applyNewAnimation:@"herbert_legs_norm" withDelay:NEW_BEAT_RATE];
                [_leg_front applyNewAnimation:@"herbert_legs_norm2" withDelay:NEW_BEAT_RATE];
            }
			_leg_front.position = ccp(-8,-20);
            _leg_back.position = ccp(-20,-20);
			break;
	}
    
    if (initialRendering) {
        [batchContainer addChild:_leg_front z:0];
        [batchContainer addChild:_leg_back z:10];
    }
}

- (void) tiltUp
{
    if (self.hasProtSuit || self.hasDrugz || _weaponType != 0) return;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/herb/herbert_bzzt1.caf"];
    
    [herbAnimation applyNewAnimation:@"herbert_up" withDelay:NEW_BEAT_RATE];
    [_leg_front restartAnimation];
    [_leg_back restartAnimation];
    [herbTrunk restartAnimation];
    _leg_back.position = ccp(-20,-18);
    _leg_front.position = ccp(-8,-22);
}

- (void) tiltDown
{
    if (self.hasProtSuit || self.hasDrugz || _weaponType != 0) return;

    [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/herb/herbert_bzzt2.caf"];
    
    [herbAnimation applyNewAnimation:@"herbert_down" withDelay:NEW_BEAT_RATE];
    [_leg_front restartAnimation];
    [_leg_back restartAnimation];
    [herbTrunk restartAnimation];
    _leg_back.position = ccp(-20,-22);
    _leg_front.position = ccp(-8,-18);
}

- (void) stopTilting
{
    if (self.hasProtSuit || self.hasDrugz) return;

    if (_weaponType == 0) {
        _leg_back.position = ccp(-20,-20);
        _leg_front.position = ccp(-8,-20);
    }
    
    [herbAnimation applyNewAnimation:@"herbert" withDelay:NEW_BEAT_RATE];
    [_leg_front restartAnimation];
    [_leg_back restartAnimation];
    [herbTrunk restartAnimation];
}

-(id) init
{
	if( (self=[super init]) ) {

		_weaponType = 0;
        self.offset = ccp(0,-10);
		
		_trunkShoot = [CCSprite spriteWithSpriteFrameName:@"herbert_shooting.png"];
		_trunkShoot.position = ccp(16.2, -3);
		_trunkShoot.visible = NO;		
		
		// Weapon-Info of all Guns..
		// obj[0] = name
		// obj[1] = position
		// obj[2] = anchorpoint
		
		// Anchor Point calculation:
		// _tabasco.anchorPoint = ccp(((_tabasco.contentSize.width/2)-11)/_tabasco.contentSize.width,
        //    ((_tabasco.contentSize.height/2)+5)/_tabasco.contentSize.height);
        //_tabasco.position = ccp(-5-11, -30+5);

		_weapon = nil;
		_globalWeaponInfo = [[NSArray alloc] initWithObjects:
							 // mg
							 [NSArray arrayWithObjects:@"kalaschnikov.png",
							  [NSValue valueWithCGPoint:CGPointMake(18-10, -11+7)],
							  [NSValue valueWithCGPoint:CGPointMake(0.318182, 0.769231)],
							  nil],
							 // laser
							 [NSArray arrayWithObjects:@"lasergun.png",
							  [NSValue valueWithCGPoint:CGPointMake(8-11, -37+5)],
							  [NSValue valueWithCGPoint:CGPointMake(0.319672, 0.678571)],
							  nil],
							 // minigun
							 [NSArray arrayWithObjects:@"minigun.png",
							  [NSValue valueWithCGPoint:CGPointMake(-7, -35)],
							  [NSValue valueWithCGPoint:CGPointMake(0.3, 0.5)],
							  nil],
							 // shotgun
							 [NSArray arrayWithObjects:@"pumpgun.png",
							  [NSValue valueWithCGPoint:CGPointMake(23-18, -17+4)],
							  [NSValue valueWithCGPoint:CGPointMake(0.194915, 0.700000)],
							  nil],
							 // rocketlauncher
							 [NSArray arrayWithObjects:@"rocketlauncher.png",
							  [NSValue valueWithCGPoint:CGPointMake(0-4, -34+4)],
							  [NSValue valueWithCGPoint:CGPointMake(0.414894, 0.614286)],
							  nil],
							 // rainbow gun
							 [NSArray arrayWithObjects:@"rainbowgun.png",
                              [NSValue valueWithCGPoint:CGPointMake(-2, -37)],
							  [NSValue valueWithCGPoint:CGPointMake(0.4, 0.608696)],
							  nil],
							 // tabasco
							 [NSArray arrayWithObjects:@"tabasco.png",
							  [NSValue valueWithCGPoint:CGPointMake(-5-11, -30+5)],
							  [NSValue valueWithCGPoint:CGPointMake(0.231707, 0.638889)],
							  nil],
							 // flygun
							 [NSArray arrayWithObjects:@"flygun.png",
							  [NSValue valueWithCGPoint:CGPointMake(0-10, -34+4)],
							  [NSValue valueWithCGPoint:CGPointMake(0.414894, 0.614286)],
							  nil],
							 // ubergun
							 [NSArray arrayWithObjects:@"uebergun.png",
							  [NSValue valueWithCGPoint:CGPointMake(7-10, -40+4)],
							  [NSValue valueWithCGPoint:CGPointMake(0.414894, 0.614286)],
							  nil],
							 // bugspray
							 [NSArray arrayWithObjects:@"bugspray.png",
							  [NSValue valueWithCGPoint:CGPointMake(7-10, -40+4)],
							  [NSValue valueWithCGPoint:CGPointMake(0.414894, 0.614286)],
							  nil],
							 nil];
		
		shot = [CCSequence actions:
				[CCDelayTime actionWithDuration:0.2f],
				[CCCallFunc actionWithTarget:self selector:@selector(normalizeTrunk:)],
				nil];
		[shot retain];
		
		_upAndDownFly = 3;
		
		// put dummy rect for attaching boxBody for hitdetection..
		[self setTextureRect:CGRectMake(0, 0, 50, 40)];
		[self setOpacity:0];
		
        batchContainer = [CCSpriteBatchNode batchNodeWithFile:@"clct_herbert.png"];
        batchContainer.position = ccp(batchContainer.position.x+25, batchContainer.position.y+10);

        [self addChild:batchContainer z:10];
		
		// add body parts
        herbTrunk = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"snout4" cachedAnimation:@"herbert_trunk" delay:NEW_BEAT_RATE];
        herbTrunk.position = ccp(8, -8);
        
        // adddd trunk
        herbAnimation = [AnimationSprite animaionWithSpriteFrameNamePrefix:@"herb_body_" cachedAnimation:@"herbert" delay:NEW_BEAT_RATE];
        herbAnimation.position = ccp(herbAnimation.position.x, herbAnimation.position.y+13);
        
        [batchContainer addChild:herbAnimation z:9];
        [batchContainer addChild:herbTrunk z:10];
		[batchContainer addChild:_trunkShoot z:10];
        [self scheduleMovement];
	}
	return self;
}

- (void) unscheduleMovement
{
    [self unschedule:@selector(moveHerbert)];
}
- (void) scheduleMovement
{
    [self schedule:@selector(moveHerbert) interval:0.08];
}

- (void) moveHerbert {
    if (!_yPos) return;
    
    if (_positionTime && _positionDelay) {
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:_positionDelay],
                         [CCMoveTo actionWithDuration:_positionTime position:ccp(_positionX, _yPos)],
                         nil]];
        
        _positionTime = nil;
        _positionDelay = nil;
        return;
    }
    
    [self runAction:[CCMoveTo actionWithDuration:0.08 position:ccp(self.position.x, _yPos)]];
}

- (void) updatePosition: (float) posY: (float) posX: (float) delay: (float) time {
    _positionTime = time;
    _positionDelay = delay;
    _positionX = posX;
    _yPos = posY;
    
    [self unscheduleMovement];
    [self moveHerbert];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay+time],[CCCallFuncN actionWithTarget:self selector:@selector(scheduleMovement)],nil]];
}

- (void) updatePosition: (float) posY {
    _yPos = posY;
}

-(void) deathAni
{
    [herbAnimation applyNewAnimation:@"herbert_gover" withDelay:NEW_BEAT_RATE];
    _leg_front.visible = NO;
	_leg_back.visible = NO;
    _trunkShoot.visible = NO;
    herbTrunk.visible = NO;
    
    [batchContainer runAction:[CCRotateTo actionWithDuration:1 angle:60]];
    [batchContainer runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:4 position:ccp(batchContainer.position.x+400, batchContainer.position.y-400)],
      nil]];
    
    [herbAnimation runAction:[CCMoveTo actionWithDuration:3 position:ccp(herbAnimation.position.x+300, herbAnimation.position.y)]];
}

- (float) getContainerXPos {
    return batchContainer.position.x;
}

- (void) prepareDealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [_globalWeaponInfo release];
    [shot release];
    _globalWeaponInfo = nil;
	_trunkShoot = nil;
    shot = nil;
    
    [self removeChild:herbTrunk cleanup:YES];
    [self removeChild:herbAnimation cleanup:YES];
    [self removeChild:batchContainer cleanup:YES];
}

- (void)dealloc
{
    NSLog(@"[dealloc] Herbert");
	[super dealloc];
}

@end
