//
//  AnimationSprite.m
//  herbert
//
//  Created by Christoph Ebert on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimationSprite.h"


@implementation AnimationSprite

@synthesize mainAction;

enum {
	kMainAnimTag = 1
};

+(id)animaionWithSpriteFrameNamePrefix:(NSString*)spriteFrameNamePrefix cachedAnimation:(NSString*)cachedAnimation delay:(float)delay
{
    AnimationSprite *sprite = [super spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@1.png",spriteFrameNamePrefix]];
	
	NSAssert1(sprite!=nil, @"Invalid spriteFrameNamePrefix: %@", spriteFrameNamePrefix);
    
    CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:cachedAnimation];
    
    NSAssert1(ani!=nil, @"Cached Animation not found: %@", cachedAnimation);
    
    id animateAction = [CCAnimate actionWithDuration:delay animation:ani restoreOriginalFrame:YES];
    
    [sprite setMainAction:[[CCRepeatForever actionWithAction:animateAction] retain]];
    [sprite runAction:sprite.mainAction]; 
    
	return sprite;
}

-(void)applyNewAnimation:(NSString*)cachedAnimation withDelay:(float)delay
{
    CCAnimation *ani = [[CCAnimationCache sharedAnimationCache] animationByName:cachedAnimation];
    
    NSAssert1(ani!=nil, @"Cached Animation not found: %@", cachedAnimation);
    
    id animateAction = [CCAnimate actionWithDuration:delay animation:ani restoreOriginalFrame:YES];
    
    [self stopAction:mainAction];
    [self setMainAction:[[CCRepeatForever actionWithAction:animateAction] retain]];
    [self runAction:mainAction];
}

-(void)restartAnimation
{
    [self stopAction:mainAction];
    [self runAction:mainAction];
}

-(void)dealloc
{
    NSLog(@"Dealloc..");
    [mainAction release];
    [super dealloc];
}

@end