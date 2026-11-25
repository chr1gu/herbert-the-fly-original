//
//  ParticleEffects.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 7/29/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "ParticleEffects.h"

@implementation ParticleEffects

static CCParticleBatchNode *delegateLayer = nil;
static NSMutableArray *em;
static BOOL em1InUse;
static BOOL em2InUse;
static BOOL em3InUse;
static BOOL em4InUse;

+ (void) initEmitters:(CCParticleBatchNode *)layer
{
    delegateLayer = layer;
    em = [[NSMutableArray alloc] init];
    
    em1InUse = NO;
    em2InUse = NO;
    em3InUse = NO;
    em4InUse = NO;
    
    for (int n=0; n<4; n++)
    {
        NSMutableArray *currentEm = [[NSMutableArray alloc] init];
        
        for (int i=0; i<=9; i++)
        {
            CCParticleExplosion *emitter = [CCParticleExplosion node];
            
            [emitter setVisible:NO];
            [emitter setTotalParticles:1];
            [emitter setGravity:ccp(10,-[[CCDirector sharedDirector] winSizeInPixels].height)];
            [emitter setSpeed:100];
            [emitter setEndSizeVar:0];
            [emitter setStartSpinVar:563];
            [emitter setStartSizeVar:0];
            [emitter setLife:2];
            [emitter setLifeVar:0];
            [emitter setStartColor:(ccColor4F) {1.0f, 1.0f, 1.0f, 255.0f}];
            [emitter setEndColor:(ccColor4F) {1.0f, 1.0f, 1.0f, 255.0f}];
            [emitter setEndColorVar:(ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f}];
            [emitter setStartColorVar:(ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f}];
            
            // TODO: is this the way to do it? could be dangerous as well if texture cache gets purged.. first load the whole texture into it and then cut it out..
            [emitter setTexture:[[CCTextureCache sharedTextureCache] textureForKey:@"clct_bugsgads.png"]];
            
            //emitter.autoRemoveOnFinish = YES;
            
            [delegateLayer addChild: emitter z:20];
            [currentEm addObject:emitter];
        }
        
        [em addObject:currentEm];
        [currentEm release];
    }
}

+ (void) releaseEm:(int)index {
    
    switch (index) {
        case 0:
            em1InUse = NO;
            break;
        case 2:
            em2InUse = NO;
            break;
        case 3:
            em3InUse = NO;
            break;
        case 4:
            em4InUse = NO;
            break;
    }
}

+ (int) fireParticles:(NSString *)name:(CGPoint)pos
{
    int index;
    
    //NSLog(@"Used particle emitters: %d %d %d %d", em1InUse, em2InUse, em3InUse, em4InUse);
    
    if (!em1InUse) {
        index = 0;
        em1InUse = YES;
    }
    else if (!em2InUse) {
        index = 1;
        em2InUse = YES;
    }
    else if (!em3InUse) {
        index = 2;
        em3InUse = YES;
    }
    else if (!em4InUse) {
        index = 3;
        em4InUse = YES;
    }
    else {
        //NSLog(@"No available emitter!");
        return -1;
    }
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    float size = 0;
    
    for (int i=0; i<=9; i++)
    {
        CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"kill_%@_%i.png",name,i]];
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frame];
        
        [[[em objectAtIndex:index] objectAtIndex:i] setVisible:NO];
        [[[em objectAtIndex:index] objectAtIndex:i] setTexture:[frame texture] withRect:[frame rect]];
        
        // figure out dimension
        size = MIN(sprite.contentSize.width, sprite.contentSize.height);

        // convert position into correct coords because there is still a bug in CCParticleBatchNode
        [[[em objectAtIndex:index] objectAtIndex:i] setPosition:ccpMult(pos, [[CCDirector sharedDirector] contentScaleFactor])];
        [[[em objectAtIndex:index] objectAtIndex:i] setStartSize:size];
        [[[em objectAtIndex:index] objectAtIndex:i] setEndSize:kParticleStartSizeEqualToEndSize];
        [[[em objectAtIndex:index] objectAtIndex:i] resetSystem];
        [[[em objectAtIndex:index] objectAtIndex:i] setVisible:YES];

        sprite = nil;
        frame = nil;
    }

    return index;
}

+ (void) deallocEmitters
{    
    delegateLayer = nil;
    em = nil;
    //[em release];
}

@end