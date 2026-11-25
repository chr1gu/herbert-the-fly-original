//
//  KillAnimation.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 5/6/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "DeathAni.h"

// TODO: Get rid of this class!
@implementation DeathAni

@synthesize target = _target;
@synthesize radian = _radian;

+(id)initWithTarget: (Monster *)target: (int)lifetime{
    
    DeathAni *ani = nil;
    if ((ani = [[[self alloc] init] autorelease])) {
        
        int radian = 100+((int)arc4random()%50); // bogenmass
        
        CGPoint pos = ccp(target.position.x,target.position.y-radian);
        ani.position = pos;
        ani.target = target;
        ani.radian = radian;
        [ani animation];

        [ani schedule:@selector(remove) interval:lifetime];
    }
    return ani;
}

- (void)remove {
    // dealloc..
    [self unschedule:@selector(remove)];
    [self.parent removeChild:self cleanup:YES];
}

- (void)animation {
    //create the dictionary
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    //add keyed data
    [dictionary setObject:@"birdy" forKey:@"Bibi2"];
    [dictionary setObject:@"birdy" forKey:@"Bibi"];
    [dictionary setObject:@"gilbert" forKey:@"BugGilbert"];
    [dictionary setObject:@"ladybug" forKey:@"LadyBug"];
    [dictionary setObject:@"lina" forKey:@"BugLina"];
    [dictionary setObject:@"bob" forKey:@"FlyBob"];
    [dictionary setObject:@"oona" forKey:@"BugOona"];
    [dictionary setObject:@"fred" forKey:@"FlyFred"];
    [dictionary setObject:@"fuckbutton" forKey:@"Fuckbutton"];
    [dictionary setObject:@"robert" forKey:@"FlyRobert"];
    [dictionary setObject:@"sina" forKey:@"FlySina"];
    
    //check if body is existing
    NSString *desc = [dictionary objectForKey:[[self.target class] description]];
    //NSLog(@"%@", desc);
    
    if (!desc) {
        [dictionary release];
        return;
    }
    
    [dictionary release];
    
    // special birdy animation
    if ([desc isEqualToString:@"birdy"]) {
        [self bibiDeath];
        return;
    }
}

- (void) bibiDeath
{
    NSString* desc = @"birdy";
    
    CCSprite *body = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_0.png",desc]];
    body.position = ccp(0, self.radian);
	[self addChild:body z:22];
    
    // fall down enough to be sure we remove the body outside the screen..
    [self runAction:[CCMoveBy actionWithDuration:1.3 position:ccp(50+(arc4random()%80),-300)]];
    [self runAction:[CCSequence actions:
                     [CCRotateBy actionWithDuration:1.3 angle:-45],
                     [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished)],
                     nil]];
    
    // remove container
    [body runAction:[CCRotateBy actionWithDuration:1.3 angle:-40+((int)arc4random()%80)]];
    [body runAction:[CCScaleTo actionWithDuration:1.3f scale:0.8]];
    
    CCSprite *p1 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_1.png",desc]];
    p1.position = ccp(-1, self.radian-56);
	p1.tag = 4;
	[self addChild:p1 z:0];
    [p1 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p1.position.x-((int)arc4random()%60), p1.position.y-150)]];
	[p1 runAction:[CCRotateBy actionWithDuration:1.0f angle:-50+((int)arc4random()%140)]];
    
    
    CCSprite *p2 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_2.png",desc]];
    p2.position = ccp(30, self.radian-46);
	p2.tag = 4;
	[self addChild:p2 z:22];
    [p2 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p2.position.x+((int)arc4random()%60), p2.position.y-150)]];
	[p2 runAction:[CCRotateBy actionWithDuration:1.0f angle:((int)arc4random()%90)]];
    
    CCSprite *p3 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_3.png",desc]];
    p3.position = ccp(-9, self.radian+52);
	p3.tag = 4;
	[self addChild:p3 z:22];
    [p3 runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:0.3 position:ccp(10, 10)],
                   [CCMoveBy actionWithDuration:2.0 position:ccp(p3.position.x+self.radian-(arc4random()%80), p3.position.y-self.radian-60-(arc4random()%60))],
     nil]];

	[p3 runAction:[CCRotateBy actionWithDuration:1.0f angle:(arc4random()%80)]];
    
    CCSprite *p4 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_4.png",desc]];
    p4.position = ccp(47, self.radian-37);
	p4.tag = 4;
	[self addChild:p4 z:0];
    [p4 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p4.position.x+((int)arc4random()%40), p4.position.y-100-((int)arc4random()%80))]];
	[p4 runAction:[CCRotateBy actionWithDuration:1.0f angle:-((int)arc4random()%90)]];
    
    CCSprite *p5 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_5.png",desc]];
    p5.position = ccp(-4, self.radian-21);
	p5.tag = 4;
	[self addChild:p5 z:22];
    [p5 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p5.position.x+(arc4random()%60), p5.position.y-20-(arc4random()%20))]];
	[p5 runAction:[CCRotateBy actionWithDuration:1.0f angle:-((int)arc4random()%120)]];
    
    CCSprite *p6 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_6.png",desc]];
    p6.position = ccp(-35, self.radian-34);
	p6.tag = 4;
	[self addChild:p6 z:22];
    [p6 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p6.position.x+20-((int)arc4random()%40), p6.position.y-20-((int)arc4random()%20))]];
	[p6 runAction:[CCRotateBy actionWithDuration:1.0f angle:80+((int)arc4random()%100)]];
    
    CCSprite *p7 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_7.png",desc]];
    p7.position = ccp(-43, self.radian-26);
	p7.tag = 4;
	[self addChild:p7 z:0];
    [p7 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p7.position.x+20-((int)arc4random()%40), p7.position.y+((int)arc4random()%40))]];
	[p7 runAction:[CCRotateBy actionWithDuration:1.0f angle:-100-((int)arc4random()%80)]];
    
    CCSprite *p8 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_8.png",desc]];
    p8.position = ccp(38, self.radian-29);
	p8.tag = 4;
	[self addChild:p8 z:22];
    [p8 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p8.position.x-20, p8.position.y-140)]];
	[p8 runAction:[CCRotateBy actionWithDuration:1.0f angle:-50]];
    
    
    CCSprite *p9 = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"kill_%@_9.png",desc]];
    p9.position = ccp(-16, self.radian-34);
	p9.tag = 4;
	[self addChild:p9 z:0];
    [p9 runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(p9.position.x-20, p9.position.y+40)]];
	[p9 runAction:[CCRotateBy actionWithDuration:1.0f angle:-180]];
}

- (void) resumeSchedulerAndActions {
    for(id item in self.children) {
        [item resumeSchedulerAndActions];
    }
    [super resumeSchedulerAndActions];
}

- (void) pauseSchedulerAndActions {
    for(id item in self.children) {
        [item pauseSchedulerAndActions];
    }
    [super pauseSchedulerAndActions];
}

-(void)spriteMoveFinished {
	[self.parent removeChild:self cleanup:YES];
}

@end