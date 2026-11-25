//
//  Item.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/2/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Item.h"
#import "MotionSprite.h"


@implementation Item
@synthesize animbody;

- (void) updateLevitation {
	if (_lVelocity>-_lDistance && _lForce) {
		_lVelocity = _lVelocity-_lSpeed;
	} else if (_lForce) {
		_lForce = 0;
	} else if (_lVelocity<_lDistance && !_lForce) {
		_lVelocity = _lVelocity+_lSpeed;
	} else {
		_lForce = 1;
	}
	self.position = ccp(self.position.x, self.position.y+_lVelocity);
}

- (void) levitate {
	_lVelocity = 1.0;
	_lForce = 1;
	_lDistance = 5;
	_lSpeed = 0.4;
	[self schedule:@selector(updateLevitation)];
}

- (void) pauseSchedulerAndActions {
    if (self.animbody) {
        [self.animbody pause];
    }
    [super pauseSchedulerAndActions];
}

- (void) resumeSchedulerAndActions {
    if (self.animbody) {
        [self.animbody resume];
    }
    [super resumeSchedulerAndActions];
}

- (void) dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    if (self.animbody) {
        [self.animbody stopAllActions];
        [self.animbody unscheduleAllSelectors];
        [self.animbody removeAllChildrenWithCleanup:YES];
        [self removeChild:self.animbody cleanup:YES];
        self.animbody = nil;
    }
    //NSLog(@"[dealloc] item");
    [super dealloc];
}

@end


@implementation Capushito

+ (id)item {
    Capushito *item = nil;
    
    if ((item = [[[super alloc] initWithSpriteFrameName:@"caposhito1.png"] autorelease]))
    {
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:@"item_shit"];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [item runAction:repeatAction];   
        }
        
		[item levitate];
    }
    return item;
}

@end

@implementation LsdStar

+ (id)item {
    LsdStar *item = nil;
    
    if ((item = [[[super alloc] initWithSpriteFrameName:@"star1.png"] autorelease]))
    {
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:@"item_star"];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [item runAction:repeatAction];   
        }
        
		[item levitate];
    }
    return item;
}

@end

@implementation ProtectSuit

+ (id)item {
    ProtectSuit *item = nil;
    
    if ((item = [[[super alloc] initWithSpriteFrameName:@"prot_1.png"] autorelease]))
    {
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:@"item_prot"];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [item runAction:repeatAction];   
        }
        
		[item levitate];
    }
    return item;
}

@end

@implementation Kalaschnikov

+ (id)item {
    Kalaschnikov *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_kalaschnikov.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation MiniGun

+ (id)item {
    MiniGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_minigun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation PumpGun

+ (id)item {
    PumpGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_pumpgun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation LaserGun

+ (id)item {
    LaserGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_lasergun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation RocketLauncher

+ (id)item {
    RocketLauncher *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_rocketlauncher.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation RainbowGun

+ (id)item {
    RainbowGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_rainbowgun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation TabascoShot

+ (id)item {
    TabascoShot *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_tabasco.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end


@implementation FlyGun

+ (id)item {
    FlyGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_flygun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation UberGun

+ (id)item {
    UberGun *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_ubergun.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation BugSpray

+ (id)item {
    BugSpray *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"icon_bugspray.png"] autorelease])) {
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"weap_plate.png"];
        [bg runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
        bg.position = ccp(18, 16);
        [item addChild:bg z:-1];
		[item levitate];
    }
    return item;
}

@end

@implementation Coin

+ (id)item {
    Coin *item = nil;
    if ((item = [[[super alloc] initWithSpriteFrameName:@"ring1.png"] autorelease]))
    {
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:@"item_coin"];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [item runAction:repeatAction];   
        }
        
		[item levitate];
    }
    return item;
}

@end
