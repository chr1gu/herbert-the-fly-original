//
//  Monster.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/29/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Monster.h"
#import "MotionSprite.h"
#import "Herbert.h"
#import "HelloWorldScene.h"

@implementation Monster

@synthesize hp = _curHp;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;
@synthesize strength = _strength;
@synthesize points = _points;
@synthesize speakBubblePos = _speakBubblePos;
@synthesize gameSpeed = _gameSpeed;
@synthesize flightVelocity;
@synthesize flightYRange;
@synthesize flightYMinRange;
@synthesize flightUpdateInterval;
@synthesize flightEaseSteps;
@synthesize duration;
@synthesize isDead;

enum {
    kRemoveObjectTag = 99,
};


- (void) enableBlink
{
    _isBlinking = NO;
    [self setOpacity:255];
}
- (void) blink
{   
    if (!_isBlinking) {
        _isBlinking = YES;
        [self setOpacity:125];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.05],[CCCallFuncN actionWithTarget:self selector:@selector(enableBlink)], nil]];
    }
}

- (void) speedUpdate
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float distance = winSize.width+self.contentSize.width;
    float restDistance = self.position.x+self.contentSize.width/2;
    float restSpeed = self.duration/distance*restDistance;
    self.duration = restSpeed;
    
    self.flightVelocity = ccp(-((restDistance/60/restSpeed)*_gameSpeed), self.flightVelocity.y);
}

- (void) addFlygunListener:(FlyGunShot *)projectile
{
    // if a flygun projectile is attacking this monster..
    if (!flyProjectiles) {
        flyProjectiles = [[NSMutableArray alloc] init];
    }
    [flyProjectiles addObject:projectile];
}

- (void) removeFlygunListener:(FlyGunShot *)projectile {
    // if the flygun projectile dies before attacking this monster.. delete pointer
    NSLog(@"Try to remove projectiles..");
    if (flyProjectiles && projectile) {
        NSLog(@"Remove projectile.. %@", projectile);
        [flyProjectiles removeObject:projectile];
        if (![flyProjectiles count]) {
            [flyProjectiles release];
            flyProjectiles = nil;
        }
    }
}

- (void) removeAllFlygunListener {
    if (flyProjectiles) {
        [flyProjectiles removeAllObjects];
        [flyProjectiles release];
        flyProjectiles = nil;
    }
}

- (void) removeAndCleanup
{
    [self.parent removeChild:self cleanup:YES];
}

- (void) flyEnd
{    
	// mark item as removeable by parent class
    self.tag = kRemoveObjectTag;
    [self.parent.parent enemyRemoved];
    [self unscheduleUpdate];
}

- (void) removeBubble:(id)sender {

	CCSprite *bubble = (CCSprite *)sender;
	[self removeChild:bubble cleanup:YES];
}

-(void) addSpeakbubble {
    bool hasCloud = NO;
    
    for(CCSprite *item in [self children])
    {
        if (item.tag == 5) {
            hasCloud = YES;
            break;
        }
    }
    
    if (!hasCloud) {
        CCSprite *bubble = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"bubble%i.png",(int)(arc4random()%3)]];
        bubble.position = _speakBubblePos;
        bubble.tag = 5;
        [bubble runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.5f],
                           [CCCallFuncN actionWithTarget:self selector:@selector(removeBubble:)], nil]];
        
        [self addChild:bubble];
    }
}

- (void) pauseSchedulerAndActions
{
    [super pauseSchedulerAndActions];
}
- (void) resumeSchedulerAndActions
{
    [super resumeSchedulerAndActions];
}

- (void) fly {
    
	// Determine speed of the target
    int minDuration = self.minMoveDuration;
	int maxDuration = self.maxMoveDuration;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;
    self.duration = actualDuration;
	
	if (!_gameSpeed) {
		_gameSpeed = 1;
	}
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float distance = winSize.width+self.contentSize.width;
    self.flightVelocity = ccp(-((distance/60/actualDuration)*_gameSpeed), self.flightVelocity.y);
}

- (void) initWithYPos:(int)yPos
{
	_yPos = yPos;
	[self fly];
}

// Follow action..
- (void) followScheduler
{
	if (_yPos) {
        
        // dont follow if herb has prot suit..
        if ([_followPointer isKindOfClass:[Herbert class]]) {
            Herbert *herb = (Herbert *)_followPointer;
            if (herb.hasProtSuit) {
                return;
            }
        }
		
		if (self.position.y < _followPointer.position.y-10) {
            self.flightVelocity = ccp(self.flightVelocity.x, 0.5);
			//_lVelocity = _lVelocity+_gameSpeed*0.8;
		} else if (self.position.y > _followPointer.position.y+10) {
            self.flightVelocity = ccp(self.flightVelocity.x, -0.5);
			//_lVelocity = _lVelocity-_gameSpeed*0.8;
		}
        else {
            self.flightVelocity = ccp(self.flightVelocity.x, 0);
        }

	}
}
- (void) follow: (id)target {
	_followPointer = target;
	[self schedule:@selector(followScheduler)];
}

- (void) update: (ccTime)deltaTime
{
    float yPos = _flightEase ? self.flightVelocity.y+_flightEase : self.flightVelocity.y;
    yPos = round(10.0f*yPos)/10.0f;
    //NSLog(@"%f",yPos);
    
    self.position = ccpAdd(self.position, 
                           ccp(self.flightVelocity.x, yPos));
    
    // monster reached end of stage..
    if (self.position.x<-self.contentSize.width/2) {
        [self flyEnd];
    }
}

- (void) randomFlyEaseScheduler
{
    float easeDuration = self.flightUpdateInterval*0.4;
    
    if (!self.flightEaseSteps) {
        self.flightEaseSteps = 5;
    }
    
    _flightEase = 0;
    [self schedule:@selector(randomFlyEase) interval:easeDuration/(self.flightEaseSteps*1.8)];
}

- (void) randomFlyEase
{
    float maxVelYEase = (self.flightVelocity.y)*-1;
    float velYEase = (maxVelYEase/self.flightEaseSteps);
    //NSLog(@"vel: %f ease: %f, combined: %f", self.flightVelocity.y,_flightEase, (self.flightVelocity.y+_flightEase));
    
    _flightEase += velYEase;
}

- (void) randomFly
{
    // fix opacity bug
    [self setOpacity:255];
    
    if (!self.flightUpdateInterval) {
        self.flightUpdateInterval = 2;
    }
    float flightYTarget = ((((arc4random()%(int)self.flightYRange*2)-self.flightYRange)/2)/(60*self.flightUpdateInterval));
    
    if (self.flightYMinRange)
    {
        self.flightYMinRange = self.flightYMinRange*-1;
        if ((flightYTarget<0&&self.flightYMinRange>0)||(flightYTarget>0&&self.flightYMinRange<0))
        {
            flightYTarget = flightYTarget*-1;
        }
        float range = self.flightYMinRange/(60.0f*self.flightUpdateInterval);
        flightYTarget += range;
    }
    
    self.flightVelocity = ccp(self.flightVelocity.x, flightYTarget);
    [self unschedule:@selector(randomFlyEase)];
    
	[self runAction: [CCSequence actions:
                      [CCDelayTime actionWithDuration:self.flightUpdateInterval*0.6],
                      [CCCallFuncN actionWithTarget:self selector:@selector(randomFlyEaseScheduler)],
                      [CCDelayTime actionWithDuration:self.flightUpdateInterval*0.4],
                      [CCCallFuncN actionWithTarget:self selector:@selector(randomFly)], 
                      nil]];
}

- (void) randomBibiFly
{
    // fix opacity bug
    [self setOpacity:255];
    
    float updateDuration = 2;
    self.flightVelocity = ccp(self.flightVelocity.x, (((arc4random()%(int)self.flightYRange*2)-self.flightYRange)/(60*updateDuration)));
    
	[self runAction: [CCSequence actions:
                      [CCDelayTime actionWithDuration:updateDuration*1.0],
                      [CCCallFuncN actionWithTarget:self selector:@selector(randomBibiFly)], 
                      nil]];
}


- (void) dealloc
{
    // projectile dies but has a flygun projectile attacking him.. inform it!
    if (flyProjectiles) {
        for (FlyGunShot*fly in flyProjectiles) {
            [fly releaseTarget];
        }
        [flyProjectiles release];
        flyProjectiles = nil;
    }
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    //NSLog(@"[dealloc] %@", self);
    [super dealloc];
}

@end

@implementation Bibi

+ (id) monster {
	
    Bibi *monster = nil;
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:@"bibi0_1.png"] autorelease])) {
        
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"bibi0"]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
    
		monster.hp = 10;
		monster.strength = 150;
		monster.points = 999;
        monster.minMoveDuration = 9;
        monster.maxMoveDuration = 10;
        monster.speakBubblePos = ccp(-20, 100);
        monster.flightYRange = 80;
        
        [monster randomBibiFly];
        [monster scheduleUpdate];
        
		// randomly shit..
		if (arc4random() %4 == 0) {
            [monster randomshit];
		}
	}
    return monster;
}

- (void) randomshit
{
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0f], [CCCallFunc actionWithTarget:self selector:@selector(playAni)],nil]];
}

- (void) playAni
{
    CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"bibi0_shit"]];
    
    if (ani) {
        id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
        id repeatAction = [CCRepeatForever actionWithAction:animateAction];
        [self stopAllActions];
        [self runAction:repeatAction];   
    } else {
        return;
    }
    
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8f], [CCCallFunc actionWithTarget:self selector:@selector(stopAni)],nil]];
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(startShit)],nil]];
}

- (void) startShit
{
	// gagi
	CCSprite *gagi = [CCSprite spriteWithSpriteFrameName:@"birdshit.png"];
	gagi.anchorPoint = ccp(((gagi.contentSize.width/2)-583)/gagi.contentSize.width,
						   ((gagi.contentSize.height/2)-356)/gagi.contentSize.height);
	gagi.position = ccp(83.5-583, 24.5-356);
	[self addChild:gagi z:0];
	[gagi runAction:[CCRotateBy actionWithDuration:2 angle:45]];
}	

- (void) stopAni
{    
    [self stopAllActions];
    CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"bibi0"]];
    if (ani) {
        id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
        id repeatAction = [CCRepeatForever actionWithAction:animateAction];
        [self runAction:repeatAction];   
    }
}

@end

@implementation Bibi2

+ (id) monster {
	
    Bibi2 *monster = nil;
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:@"bibi1_1.png"] autorelease])) {
		
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"bibi1"]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
		
        monster.hp = 10;
		monster.strength = 150;
		monster.points = 999;
        monster.minMoveDuration = 9;
        monster.maxMoveDuration = 10;
        monster.speakBubblePos = ccp(-20, 100);
        monster.flightYRange = 80;
        [monster randomBibiFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation FlyBob

+ (id) monster {
	
    FlyBob *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"flybob%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"flybob%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }

        monster.hp = 4;
		monster.strength = 100;
		monster.points = 213;
        monster.speakBubblePos = ccp(-30, 30);
        
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 6;
        monster.flightYRange = 30;
        monster.flightYMinRange = 50;
        monster.flightUpdateInterval = 2;
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    
    return monster;
}

@end

@implementation BugOona

+ (id) monster {
	
    BugOona *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"bugoona%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"bugoona%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
        
        monster.hp = 4;
		monster.strength = 100;
		monster.points = 207;
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 6;
        monster.flightYRange = 30;
        monster.flightYMinRange = 50;
        monster.flightUpdateInterval = 2;
        monster.speakBubblePos = ccp(-25, 30);
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation BugLina

+ (id) monster {
	
    BugLina *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"buglina%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"buglina%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
		
        monster.hp = 6;
		monster.strength = 100;
		monster.points = 575;
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 6;
        monster.flightYRange = 30;
        monster.flightYMinRange = 30;
        monster.flightUpdateInterval = 2;
        monster.speakBubblePos = ccp(-25, 30);
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation FlySina

+ (id) monster {
	
    FlySina *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"flysina%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"flysina%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
		
        monster.hp = 2;
		monster.strength = 50;
        monster.points = 118;
        monster.minMoveDuration = 4;
        monster.maxMoveDuration = 5;
        monster.flightYRange = 10;
        monster.flightYMinRange = 30;
        monster.flightUpdateInterval = 1.2;
        monster.speakBubblePos = ccp(-15, 35);
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation FlyRobert

+ (id) monster {
	
    FlyRobert *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"flyrobert%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"flyrobert%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }

        monster.hp = 1;
		monster.strength = 50;
		monster.points = 69;
        monster.minMoveDuration = 4;
        monster.maxMoveDuration = 6;
        monster.flightYRange = 30;
        monster.flightYMinRange = 40;
        monster.flightUpdateInterval = 3;
        monster.speakBubblePos = ccp(-20, 40);
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation BugGilbert

+ (id) monster {
	
    BugGilbert *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"buggilbert%i_1.png", bugid]] autorelease])) {
        
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"gilbert%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
		
        monster.hp = 2;
		monster.strength = 50;
		monster.points = 55;
        monster.minMoveDuration = 5;
        monster.maxMoveDuration = 6.5;
        monster.speakBubblePos = ccp(-20, 40);
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation FlyFred

+ (id) monster {
	
    FlyFred *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"flyfred%i_1.png", bugid]] autorelease])) {

        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"flyfred%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }

        monster.hp = 4;
		monster.strength = 50;
		monster.points = 127;
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 6;
        monster.speakBubblePos = ccp(-25, 38);
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation Fuckbutton

+ (id) monster {
	
    Fuckbutton *monster = nil;
    int bugid = (int)(arc4random()%3);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"fuckbutton%i_1.png", bugid]] autorelease])) {
		
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"fuckbutton%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }
        
        monster.hp = 1;
		monster.strength = 50;
		monster.points = 251;
        monster.minMoveDuration = 5;
        monster.maxMoveDuration = 6.5;
        monster.flightYRange = 30;
        //monster.flightYMinRange = 10;
        monster.flightUpdateInterval = 1;
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end

@implementation LadyBug

+ (id) monster {
	
    LadyBug *monster = nil;
    int bugid = (int)(arc4random()%2);
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"ladybug%i_1.png", bugid]] autorelease])) {
		
        // TODO: what happens if animation is nil?
        CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"ladybug%i", bugid]];
        if (ani) {
            id animateAction = [CCAnimate actionWithDuration:0.6 animation:ani restoreOriginalFrame:NO];
            id repeatAction = [CCRepeatForever actionWithAction:animateAction];
            [monster runAction:repeatAction];   
        }

        monster.hp = 5;
		monster.strength = 100;
		monster.points = 332;
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 5.5;
        monster.flightYRange = 150;
        //monster.flightYMinRange = 10;
        monster.flightUpdateInterval = 1.8;
        monster.speakBubblePos = ccp(-30, 30);
        
        [monster randomFly];
        [monster scheduleUpdate];
    }
    return monster;
}

@end


@implementation DummyTarget

+ (id) monster {
	
    DummyTarget *monster = nil;
    
    if ((monster = [[[super alloc] initWithSpriteFrameName:@"tut_target_blank.png"] autorelease])) {
        monster.hp = 1;
		monster.strength = 0;
		monster.points = 0;
        monster.minMoveDuration = 4.5;
        monster.maxMoveDuration = 5.5;
        [monster scheduleUpdate];
    }
    return monster;
}

@end