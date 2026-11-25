//
//  Clouds.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/31/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

@synthesize index = _index;
@synthesize speed = _speed;

- (void) dealloc
{
    //NSLog(@"[dealloc] cloud");
    [super dealloc];
}

@end

@implementation MiddleCloud

+ (id)cloud {
	
    MiddleCloud *cloud = nil;
	NSString *str = [NSString stringWithFormat:@"cloud_10_%d.png", arc4random()%6];
    
    if ((cloud = [super spriteWithSpriteFrameName:str])) {
		int minDuration = 10;
		int maxDuration = 13;
		int rangeDuration = maxDuration - minDuration;
		float actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
        cloud.index = 8;
		cloud.speed = actualDuration;
		
		// cloud pumping..
		id repeatingCloudAction = [CCRepeatForever actionWithAction:[CCSequence actions:
																	 [CCScaleTo actionWithDuration:0.4f scale:0.95f],
																	 [CCScaleTo actionWithDuration:0.3f scale:1.0],nil]];
		[cloud runAction:repeatingCloudAction];
		
    }
	
    return cloud;
}

- (void) dealloc {
    [self stopAllActions];
    [super dealloc];
}

@end

@implementation BackgroundCloud

+ (id)cloud {
	
    BackgroundCloud *cloud = nil;
    NSString *str = [NSString stringWithFormat:@"cloud_3_%d.png", arc4random()%4];
    
    if ((cloud = [super spriteWithSpriteFrameName:str])) {
		int minDuration = 18;
		int maxDuration = 24;
		int rangeDuration = maxDuration - minDuration;
		float actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
		cloud.index = 2;
		cloud.speed = actualDuration; 
    }
    return cloud;
}

@end

@implementation ForegroundCloud

+ (id)cloud {
	
    ForegroundCloud *cloud = nil;
    NSString *str = [NSString stringWithFormat:@"cloud_25_%d.png", arc4random()%5];
    
    if ((cloud = [super spriteWithSpriteFrameName:str])) {
		int minDuration = 3;
		int maxDuration = 5;
		int rangeDuration = maxDuration - minDuration;
		int actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
        cloud.index = 25;
		cloud.speed = actualDuration;
    }
    return cloud;
}

@end

@implementation GroundCloud

+ (id)cloud {
	
    GroundCloud *cloud = nil;
    NSString *str = [NSString stringWithFormat:@"cloud_ground%d.png", arc4random()%4];
    
    if ((cloud = [super spriteWithSpriteFrameName:str])) {
		int minDuration = 13;
		int maxDuration = 14;
		int rangeDuration = maxDuration - minDuration;
		int actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
        cloud.index = 5;
		cloud.speed = actualDuration;
    }
    return cloud;
}

@end

@implementation Rainbow

+ (id)cloud
{	
    Rainbow *cloud = nil;
    
    if ((cloud = [[[super alloc] init] autorelease])) {
		
		int actualDuration = 50;
        cloud.index = 1;
		cloud.speed = actualDuration;
        [cloud addRainbow];
        [cloud schedule:@selector(checkPosition) interval:1];
    }
    return cloud;
}

- (void) addRainbow
{
    rainbow = [CCSprite spriteWithFile:@"rainbow_start.png"];
    [rainbow setTextureRect:CGRectMake(0, 0, 512, 320)];
    rainbow.position = ccp(rainbow.contentSize.width/2, rainbow.contentSize.height/2);
    [self addChild:rainbow];
}

- (void) checkPosition
{
    if (self.position.x<-320) {
        [self changeTexture];
        [self unschedule:@selector(checkPosition)];
    }
}

- (void) changeTexture
{
    [rainbow setTexture:[[CCSprite spriteWithFile:@"rainbow_end.png"] texture]];
    rainbow.position = ccp(1200, rainbow.contentSize.height/2);
}

- (void) dealloc
{
    [super dealloc];
}

@end