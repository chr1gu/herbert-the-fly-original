//
//  Clouds.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/31/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "Particles.h"

@implementation Particles

@synthesize index = _index;
@synthesize speed = _speed;

@end

@implementation ForegroundParticle

@synthesize animbody;

+ (id)particle {
	
    ForegroundParticle *particle = nil;
    
    if ((particle = [[[super alloc] init] autorelease])) {
		int minDuration = 3;
		int maxDuration = 6;
		int rangeDuration = maxDuration - minDuration;
		float actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
        particle.index = 8;
		particle.speed = actualDuration;
        
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"particle_%d.png", arc4random()%13]];
        
        particle.animbody = [CCSprite spriteWithSpriteFrame:frame];
        
		[particle setTextureRect:CGRectMake(0,0, 10, 10)];
		[particle setOpacity:0];
        [particle addChild:particle.animbody];
		
        [particle randomFly:particle.animbody];
        
		// particle pumping..
		/*id repeatingParticleAction = [CCRepeatForever actionWithAction:[CCSequence actions:
																	 [CCScaleTo actionWithDuration:0.4f scale:0.95f],
																	 [CCScaleTo actionWithDuration:0.3f scale:1.0],nil]];*/
		//[particle runAction:repeatingParticleAction];
		
    }
	
    return particle;
}

- (void) pauseSchedulerAndActions {
    [self.animbody pauseSchedulerAndActions];
    [super pauseSchedulerAndActions];
}
- (void) resumeSchedulerAndActions {
    [self.animbody resumeSchedulerAndActions];
    [super resumeSchedulerAndActions];
}

- (void) randomFly:(id)sender {
	CCSprite *target = (CCSprite *)sender;
	[target runAction: [CCSequence actions:
                        [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2 position:ccp(target.position.x, arc4random()%100)]],
                        [CCCallFuncN actionWithTarget:self selector:@selector(randomFly:)], 
                        nil]];
}

@end


@implementation MenuParticle
@synthesize animbody;

+ (id)particle {
	
    MenuParticle *particle = nil;
    if ((particle = [[[super alloc] init] autorelease])) {
		int minDuration = 3;
		int maxDuration = 6;
		int rangeDuration = maxDuration - minDuration;
		float actualDuration = (arc4random() % rangeDuration) + minDuration;
		//
        particle.index = 8;
		particle.speed = actualDuration;
        
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"mm_particle_%d.png", arc4random()%11]];
        
        particle.animbody = [CCSprite spriteWithSpriteFrame:frame];
		[particle setTextureRect:CGRectMake(0,0, 10, 10)];
		[particle setOpacity:0];
        [particle addChild:particle.animbody];
        [particle randomFly:particle.animbody];		
    }
    return particle;
}

- (void) randomFly:(id)sender {
	CCSprite *target = (CCSprite *)sender;
	[target runAction: [CCSequence actions:
                        [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2 position:ccp(target.position.x, arc4random()%100)]],
                        [CCCallFuncN actionWithTarget:self selector:@selector(randomFly:)], 
                        nil]];
}
@end


@implementation ExplosionParticle

+ (id)initWithFile:(NSString *)file:(CGPoint)pos; {
	
    ExplosionParticle *particle = nil;
    
    if ((particle = [super spriteWithSpriteFrameName:file]))
    {
        int streufaktor = 70;
        int distanceX = 150;
        int distanceY = 180;
        
        particle.scale = 0.1;
        
        CGPoint movepos = ccp(arc4random()%distanceX,arc4random()%distanceY);
        CGPoint startpos = ccp(arc4random()%streufaktor,arc4random()%streufaktor);
        
        [particle runAction:[CCSpawn actions:
                             [CCMoveBy actionWithDuration:0.01 position:ccp(startpos.x-(streufaktor/2), startpos.y-(streufaktor/2))],
                             [CCSequence actions:
                              [CCScaleTo actionWithDuration:0.1f scale:1.0f],
                              [CCScaleTo actionWithDuration:1 scale:0],
                              [CCCallFuncN actionWithTarget:particle selector:@selector(spriteMoveFinished:)],
                              nil],
                             [CCRotateBy actionWithDuration:0.8 angle:-360],
                             [CCSequence actions:
                              [CCDelayTime actionWithDuration:0.1],
                              [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(movepos.x*(-1),movepos.y)] rate:2],
                              nil],
                             nil]];
    }
    return particle; 
}

-(void)spriteMoveFinished:(id)sender {
	ExplosionParticle *sprite = (ExplosionParticle *)sender;
    [sprite stopAllActions];
	[self.parent removeChild:sprite cleanup:YES];
	sprite = nil;
}
@end


@implementation ItemUpParticle

+ (id)particle:(Item *)item {
	
    ItemUpParticle *particle = nil;
    if ((particle = [[[super alloc] init] autorelease])) {
		
        // do it..
        int num = 12;
        [particle initParticles];
        for (int i=1; i<=num; i++) {
            
            NSString *file = nil;
            
            // capushito
            if ([item isKindOfClass:[Capushito class]]) {
                file = (arc4random()%2==0) ? @"particle_15.png" : @"particle_16.png";
            }
            // coin
            else if ([item isKindOfClass:[Coin class]]) {
                file = (arc4random()%2==0) ? @"particle_0.png" : @"particle_6.png";
            }
            // protection suit
            else if ([item isKindOfClass:[ProtectSuit class]]) {
                file = (arc4random()%2==0) ? @"particle_1.png" : @"particle_8.png";
            }
            // others: weapons
			else {
                file = (arc4random()%2==0) ? @"particle_13.png" : @"particle_14.png";
            }
            
            CCSprite *p1 = [CCSprite spriteWithSpriteFrameName:file];
            p1.rotation = 360/num*i;
            p1.tag = 60+(arc4random()%40);
            [p1 runAction:[CCFadeOut actionWithDuration:1]];
            [particle addParticle:p1];
        }
        
        [particle schedule:@selector(updatePositions)];
        
    }
    return particle;
}

- (void) initParticles {
    particles = [[NSMutableArray alloc] init];
}

- (void) addParticle:(CCSprite *)particle {
    [particles addObject:particle];
    [self addChild:particle];
}

- (void) updatePositions {
    
    for (CCSprite *particle in particles) {
        
        float speed = ((float)particle.tag)/60; // Move 50 pixels in 60 frames (1 second)
        int angle = particle.rotation;
        
        float vx = cos(angle * M_PI / 180) * speed;
        float vy = sin(angle * M_PI / 180) * speed;

        CGPoint direction = ccp(vx,vy);
        
        particle.position = ccpAdd(particle.position, direction);
        //And to wrap it up, we can also set the rotation of the sprite the same as the angle, and it will point in the right direction:
        //particle.rotation = angle;
    }
}

- (void) dealloc {
    
    [particles release];
    [super dealloc];
}

@end