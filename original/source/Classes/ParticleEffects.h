//
//  ParticleEffects.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 7/29/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParticleEffects : NSObject {

}

+ (void) releaseEm:(int)index;
+ (void) initEmitters:(CCParticleBatchNode *)layer;
+ (int) fireParticles:(NSString *)name:(CGPoint)pos;
+ (void) deallocEmitters;

@end
