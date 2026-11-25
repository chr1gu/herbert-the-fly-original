//
//  Item.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/2/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MotionSprite.h"

@interface Item : CCSprite {
	
	float _lVelocity;
	float _lSpeed;
	int _lForce;
	int _lDistance;
}

@property (nonatomic, assign) MotionSprite *animbody;

@end

@interface Capushito : Item {
}
+(id)item;
@end

@interface LsdStar : Item {
}
+(id)item;
@end

@interface ProtectSuit : Item {
}
+(id)item;
@end

@interface Kalaschnikov : Item {
}
+(id)item;
@end

@interface LaserGun : Item {
}
+(id)item;
@end

@interface MiniGun : Item {
}
+(id)item;
@end

@interface PumpGun : Item {
}
+(id)item;
@end

@interface RocketLauncher : Item {
}
+(id)item;
@end

@interface RainbowGun : Item {
}
+(id)item;
@end

@interface TabascoShot : Item {
}
+(id)item;
@end

@interface FlyGun : Item {
}
+(id)item;
@end

@interface UberGun : Item {
}
+(id)item;
@end

@interface BugSpray : Item {
}
+(id)item;
@end

@interface Coin : Item {
}
+(id)item;
@end
