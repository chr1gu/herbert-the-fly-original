//
//  Projectile.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/19/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Monster.h"

@interface Projectile : CCSprite {
	CGPoint _b2BodyOffset;
	int _strength;
}

@property (nonatomic, assign) CGPoint b2BodyOffset;
@property (nonatomic, assign) int strength;
@end

@interface Rocket : Projectile {
}
+(id)projectile;
@end

@interface PumpShell : Projectile {
}
+(id)projectile;
@end

@interface ShitBall : Projectile {
}
+(id)projectile;
@end

@interface MiniGunShell : Projectile {
}
+(id)projectile;
@end

@interface MGShell : Projectile {
}
+(id)projectile;
@end

@interface TabascoShots : Projectile {
}
+(id)projectile;
@end

@interface SprayPoison : Projectile {
}
+(id)projectile;
@end


@interface FlyGunShot : Projectile {
    CCSprite *_player;
    CCSprite *_target;
    NSArray *_targets;
    CGPoint _location;
}
@property (nonatomic, assign) CCSprite *animbody;
+ (id) projectile:(NSArray *)targets:(CGPoint)location:(int)index:(CCSprite *)player;
- (void) setTarget:(NSArray *)targets:(CGPoint)location:(CCSprite *)player;
- (void) initialAttack;
- (void) attackTarget;
- (void) releaseTarget;
@end