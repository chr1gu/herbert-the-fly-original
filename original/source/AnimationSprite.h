//
//  AnimationSprite.h
//  herbert
//
//  Created by Christoph Ebert on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface AnimationSprite : CCSprite {
}

@property (nonatomic, retain) id mainAction;

+(id)animaionWithSpriteFrameNamePrefix:(NSString*)spriteFrameNamePrefix cachedAnimation:(NSString*)cachedAnimation delay:(float)delay;

-(void)applyNewAnimation:(NSString*)cachedAnimation withDelay:(float)delay;
-(void)restartAnimation;

@end
