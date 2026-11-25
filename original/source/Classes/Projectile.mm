//
//  Projectile.mm
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/19/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Projectile.h"
#import "MotionSprite.h"

@implementation Projectile

@synthesize b2BodyOffset = _b2BodyOffset;
@synthesize strength = _strength;

- (void) dealloc
{
    [super dealloc];
}

@end

@implementation Rocket
+ (id)projectile {
    Rocket *projectile = nil;
	// TODO: Add custom shape and not empty png..
	if ((projectile = [[[super alloc] initWithFile:@"rocketlaucher_shot_transparent.png"] autorelease])) {
        MotionSprite *ani = [MotionSprite motionWithSpriteSheet:@"clct_bugsgads" framename:@"rocket" numframes:4 delay:0.1:YES];
		ani.position = ccp(22, 10);
		[ani play:YES repeat:YES];
		[projectile addChild:ani];
		//
		projectile.b2BodyOffset = ccp(0.0, -0.1);
		projectile.strength = 8;
    }
    return projectile;
}
@end

@implementation PumpShell
+ (id)projectile {
    PumpShell *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"pumpgun_shot.png"] autorelease])) {
		
		projectile.b2BodyOffset = ccp(2.0f, 0.021875);
		projectile.strength = 2;
    }
    return projectile;
}
@end

@implementation ShitBall
+ (id)projectile {
    ShitBall *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"shot_normal.png"] autorelease])) {
		
		projectile.b2BodyOffset = ccp(0.9f, 0.021875);
		projectile.strength = 2;
    }
    return projectile;
}
@end

@implementation TabascoShots
+ (id)projectile {
    TabascoShots *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"shot_tabasco.png"] autorelease])) {
		
		projectile.b2BodyOffset = ccp(0.9f, 0.021875);
		projectile.strength = 2;
    }
    return projectile;
}
@end

@implementation MiniGunShell
+ (id)projectile {
    MiniGunShell *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"minigun_shot.png"] autorelease])) {
		
		projectile.b2BodyOffset = ccp(1.10f, 0.021875);
		projectile.strength = 2;
    }
    return projectile;
}
@end

@implementation MGShell
+ (id)projectile {
    MGShell *projectile = nil;
    if ((projectile = [[[super alloc] initWithSpriteFrameName:@"kalaschnikov_bullet.png"] autorelease])) {
		
		projectile.b2BodyOffset = ccp(1.2f, 0.021875);
		projectile.strength = 2;
    }
    return projectile;
}
@end

@implementation SprayPoison
+ (id)projectile {
    SprayPoison *projectile = nil;
    // TODO: Add custom shape and not empty png..
    if ((projectile = [[[super alloc] initWithFile:@"rocketlaucher_shot_transparent.png"] autorelease])) {
		projectile.strength = 1;
        
        CCSprite *poison = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"bugspray_poison%d.png", arc4random()%2]];
        poison.scale = 0.2;
        poison.rotation = arc4random()%360;
        poison.position = ccp(25, -5);
		[projectile addChild:poison];
        
        // scale up
        [poison runAction:[CCSequence actions:
                               [CCDelayTime actionWithDuration:0.3],
                               [CCScaleTo actionWithDuration:0.8 scale:1.0f],
                               nil]];
        // move up
        [poison runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:1.1 position:ccp((10+(arc4random()%20)),30)],
                               nil]];
        
        // hide
        [poison runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.6],
                           [CCFadeOut actionWithDuration:0.5],
                           nil]];
    }
    return projectile;
}
@end

@implementation FlyGunShot
@synthesize animbody;

+ (id)projectile:(NSArray *)targets:(CGPoint)location:(int)index:(CCSprite *)player {
    
    FlyGunShot *projectile = nil;
	// TODO: Add custom shape and not empty png..
	if ((projectile = [[[super alloc] initWithFile:@"rocketlaucher_shot_transparent.png"] autorelease])) {
        
		MotionSprite *fly1 = [MotionSprite motionWithSpriteSheet:@"clct_bugsgads" framename:[NSString stringWithFormat:@"flygun%i_",index] numframes:4 delay:0.1:YES];
		fly1.position = ccp(22, 10);
		[fly1 play:YES repeat:YES];
		[projectile addChild:fly1];
        [projectile setTarget:targets:location:player];
        projectile.b2BodyOffset = ccp(0.0, -0.1);
		projectile.strength = 2;
        projectile.animbody = fly1;
        
        // add small delay before attacking..
        float delay = index==0 ? 0 : (float)index/5;
        [projectile runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay], [CCCallFuncN actionWithTarget:projectile selector:@selector(initialAttack)], nil]];
    }
    return projectile;
}

- (void) setTarget:(NSArray *)targets:(CGPoint)location:(CCSprite *)player {
    
    // release target pointer if we have no more objects on stage..
    if (!targets && !player) {
        _target = nil;
    }
    
    _targets = targets;
    _location = location;
    _player = player;
}

- (void) initialAttack {
    [self runAction:[CCMoveTo actionWithDuration:0.3 position:ccp(self.position.x+50, self.position.y+10)]];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.3], [CCCallFuncN actionWithTarget:self selector:@selector(attackTarget)], nil]];
    
    // up and down fly..
    id flightAction = [CCRepeatForever actionWithAction:
                       [CCSequence actions:
                        [CCMoveTo actionWithDuration:0.5 position:ccp(self.animbody.position.x, self.animbody.position.y-10)],
                        [CCMoveTo actionWithDuration:0.5 position:ccp(self.animbody.position.x, self.animbody.position.y+10)],
                        nil]];
    
    [self.animbody runAction:flightAction];
}

- (void) attackTarget {

    Monster *flygunTarget = nil;
    
    if (!_targets && !_player) {
        // should not happen anymore just in case..
        return;
    }
    
    // select target you wanna attack 
    for (Monster *target in _targets) {
        
        // get closest enemy
        if (!flygunTarget) {
            flygunTarget = target;
        } else {
            
            float horLast = _location.x>flygunTarget.position.x ? _location.x-flygunTarget.position.x : flygunTarget.position.x-_location.x;
            float vertLast = _location.y>flygunTarget.position.y ? _location.y-flygunTarget.position.y : flygunTarget.position.y-_location.y;
            float horCur = _location.x>target.position.x ? _location.x-target.position.x : target.position.x-_location.x;
            float vertCur = _location.y>target.position.y ? _location.y-target.position.y : target.position.y-_location.y;
            
            // current target is closer..
            if ((horLast+vertLast)>(horCur+vertCur)) {
                flygunTarget = target;
            }
        }
    }
    
    if (!flygunTarget) {
        // No enemy on stage attack player/herb..
        _target = _player;
        [self schedule:@selector(updateProjectile)];
        return;
    }
    
    // target monster gets a reference of the current projectile (just in case it would die earlier it can inform us about that..)
    [flygunTarget addFlygunListener:self];
    _target = flygunTarget;
    
    // update interval
    [self schedule:@selector(updateProjectile)];
}

- (void) releaseTarget {
    
    // target is dead.. update location and attack next enemy..
    _location = _target.position;
    _target = nil;
    [self unschedule:@selector(updateProjectile)];
    
    // attack next one..
    [self attackTarget];
}

- (void) updateProjectile {
    
    if (!_target) {
        // target is dead.. release it..
        [self releaseTarget];
        return;
    }
    
    Monster *enemy = (Monster *)_target;
    CGPoint newPos = ccp(0,0);
    CGPoint enemyPos = ccp(enemy.position.x, enemy.position.y);
    
    // prevent flickering..
    if (self.position.y>enemyPos.y-15 && self.position.y<enemyPos.y+15) {
        newPos.y = self.position.y;
    } else {
        // fly up/down..
        newPos.y = self.position.y<enemyPos.y ? self.position.y+3 : self.position.y-3;
    }
    if (self.position.y>enemyPos.x-15 && self.position.y<enemyPos.x+15) {
        newPos.x = self.position.x;
    } else {
        newPos.x = self.position.x<enemyPos.x ? self.position.x+3 : self.position.x-3;
    }
    
    // projectile hits herb..
    if (_target == _player) {
        if (self.position.y<=_player.position.y+30 && self.position.y>=_player.position.y-30 && self.position.x<=_player.position.x+30 && self.position.x>=_player.position.x-30) {
            
            // Hit player and remove it...
            [self unschedule:@selector(updateProjectile)];
            [self.parent flyHitHerb:self];
        }
    }
    
    self.position = newPos;
}

- (void) dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    //if (_target && _target!=_player) {
        // extremly rare case..
        // then don't call dealloc again because it gets removed twice!!
        //NSLog(@"Projectile collided with something else..");
        //[_target removeFlygunListener:self];
    //}
    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
