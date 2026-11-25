//
//  MotionSprite.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 1/6/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "MotionSprite.h"

@implementation MotionSprite

+(id) motionWithSpriteSheet:(NSString *)filename framename:(NSString *)framename numframes:(int)numframes delay:(float)delay:(bool)cached
{
	return [[[self alloc] initWithParams:filename framename:framename numframes:numframes delay:delay:cached] autorelease];
}

+(id) motionWithSpriteSheet: (NSString *)filename framename: (NSString *)framename numframes:(int)numframes delay:(float)delay
{
	return [self motionWithSpriteSheet:filename framename:framename numframes:numframes delay:delay:NO];
}

-(id) initWithParams: (NSString *)filename framename: (NSString *)framename numframes:(int)numframes delay:(float)delay:(bool)cached
{
	if( (self=[super init] )) {
        
        //NSLog(@"Motionsprite: load %@, framename: %@", filename, framename);
        
		// This loads an image of the same name (but ending in png), and goes through the
        // plist to add definitions of each frame to the cache.
        if (!cached) {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[filename stringByAppendingString:@".plist"]]; 
        }
        
        // Create a sprite for the animation
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[framename stringByAppendingString:@"1.png"]];
        if (frame==nil) {
            // This should not happen.. but at least it prevents the app from crashing!
            NSLog(@"WARNING: Sprite %@ not found!", framename);
            return self;
        }
        
		_motionSprite = [CCSprite spriteWithSpriteFrame:frame];
        
        // Create a sprite sheet with the images
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[filename stringByAppendingString:@".png"]];
        [self addChild:_spriteSheet];
        
        // Load up the frames of our animation
        _animFrames = [NSMutableArray array];
        for(int i = 1; i <= numframes; ++i) {
            [_animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[framename stringByAppendingString:[NSString stringWithFormat:@"%d.png", i]]]];
        }
        _walkAnim = [CCAnimation animationWithFrames:_animFrames delay:delay];
		_playonceAction = [CCAnimate actionWithAnimation:_walkAnim restoreOriginalFrame:NO];
        _repeatAction = [CCRepeatForever actionWithAction:_playonceAction];
        [_spriteSheet addChild:_motionSprite];
		
		[_playonceAction retain];
		[_repeatAction retain];
	}
	return self;
}

-(void) play: (BOOL)restart repeat:(BOOL)repeat {
	if (repeat) {
		[_motionSprite runAction:_repeatAction];
	} else {
		[_motionSprite runAction:_playonceAction];
	}
}

-(void) pause {
    [super pauseSchedulerAndActions];
	[_motionSprite pauseSchedulerAndActions];
}

-(void) resume {
    [super resumeSchedulerAndActions];
	[_motionSprite resumeSchedulerAndActions];
}

-(void) restart: (BOOL)repeat {
	[_motionSprite stopAllActions];
	[self play:YES repeat:YES];	
}

-(void) stop {
	[self pause];
}

-(void) setOpacity:(GLubyte)opacity
{
    [_motionSprite setOpacity:opacity];
    [super setOpacity:opacity];
}

- (void) dealloc
{
	[_playonceAction release];
	[_repeatAction release];
	
	_spriteSheet= nil;
	_walkAnim= nil;
	_repeatAction = nil;
	_playonceAction = nil;
	_motionSprite = nil;
	_animFrames = nil;
    
    //NSLog(@"[dealloc] MotionSprite");
	[super dealloc];
}

@end
