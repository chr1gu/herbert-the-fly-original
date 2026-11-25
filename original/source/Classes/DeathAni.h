//
//  KillAnimation.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 5/6/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Monster.h"

@interface DeathAni : CCSprite {
    Monster *_target;
    int _radian;
}
+(id)initWithTarget: (Monster *)target: (int)lifetime;

- (void) remove;
- (void) animation;
- (void) bibiDeath;
- (void) spriteMoveFinished;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) int radian;
@end