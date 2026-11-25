//
//  Monster.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/29/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "cocos2d.h"
#import "MotionSprite.h"
#import "Projectile.h"

@interface Monster : CCSprite {
	
    int _curHp;
	int _strength;
	int _points;
    int _minMoveDuration;
    int _maxMoveDuration;
	int _yPos;
	int _smoothness;
	float _gameSpeed;
    float _lVelocity;
    CGPoint _speakBubblePos;
    float _flightEase;
    bool _isBlinking;
    
    NSMutableArray *flyProjectiles;
	
	// pointer of player.
	CCSprite *_followPointer;
}

@property (nonatomic, assign) int points;
@property (nonatomic, assign) int strength;
@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) float flightYRange;
@property (nonatomic, assign) float flightYMinRange;
@property (nonatomic, assign) uint flightEaseSteps;
@property (nonatomic, assign) float flightUpdateInterval;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float gameSpeed;
@property (nonatomic, assign) bool isDead;
@property (nonatomic, assign) CGPoint speakBubblePos;
@property (nonatomic, assign) CGPoint flightVelocity;

- (void) addFlygunListener:(CCSprite *)projectile;
- (void) removeFlygunListener:(CCSprite *)projectile;
- (void) removeAllFlygunListener;
- (void) randomFly;
- (void) randomBibiFly;
- (void) randomFlyEase;
- (void) randomFlyEaseScheduler;
- (void) speedUpdate;
- (void) update: (ccTime)deltaTime;
- (void) removeBubble:(id)sender;
- (void) follow: (id)target;
- (void) addSpeakbubble;
- (void) initWithYPos:(int)yPos;
- (void) blink;
- (void) removeAndCleanup;

@end

@interface FlyBob : Monster {
}

+(id)monster;
@end

@interface BugLina : Monster {
}

+(id)monster;
@end

@interface BugOona : Monster {
}

+(id)monster;
@end

@interface BugGilbert : Monster {
}
+(id)monster;
@end

@interface FlySina : Monster {
}
+(id)monster;
@end

@interface FlyRobert : Monster {
}
+(id)monster;
@end

@interface FlyFred : Monster {
}
+(id)monster;
@end

@interface Fuckbutton : Monster {
}
+(id)monster;
@end

@interface Bibi2 : Monster {
}
+(id)monster;
@end

@interface Bibi : Monster {
}
- (void) randomshit;
+(id)monster;
@end

@interface LadyBug : Monster {
}
+(id)monster;
@end

@interface DummyTarget : Monster {
}
+(id)monster;
@end