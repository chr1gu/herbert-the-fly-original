//
//  MotionSprite.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 1/6/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MotionSprite : CCSprite {
	CCSpriteBatchNode *_spriteSheet;
	CCAnimation *_walkAnim;
	CCAction *_repeatAction;
	CCActionInterval *_playonceAction;
	CCSprite *_motionSprite;
	NSMutableArray *_animFrames;
}

+(id) motionWithSpriteSheet:(NSString *)filename framename:(NSString *)framename numframes:(int)numframes delay:(float)delay:(bool)cached;

+(id) motionWithSpriteSheet:(NSString *)filename framename:(NSString *)framename numframes:(int)numframes delay:(float)delay;

-(id) initWithParams: (NSString *)filename framename: (NSString *)framename numframes:(int)numframes delay:(float)delay:(bool)cached;

-(void) play: (BOOL)restart repeat:(BOOL)repeat;
-(void) restart: (BOOL)repeat;
-(void) pause;
- (void) resume;
-(void) stop;

@end
