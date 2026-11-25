//
//  Clouds.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/31/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Item.h"

@interface Particles : CCSprite {
    int _index;
	float _speed;
}

@property (nonatomic, assign) int index;
@property (nonatomic, assign) float speed;

@end

@interface ForegroundParticle : Particles {
}
+(id)particle;
-(void) randomFly:(id)sender;

@property (nonatomic, assign) CCSprite *animbody;

@end


@interface MenuParticle : Particles {
}
+(id)particle;
-(void) randomFly:(id)sender;

@property (nonatomic, assign) CCSprite *animbody;

@end


@interface ExplosionParticle : Particles {
}
+(id)initWithFile:(NSString *)file:(CGPoint)pos;

@end


@interface ItemUpParticle : Particles {
    NSMutableArray *particles;
}
+ (id) particle:(Item *)item;
- (void) initParticles;
- (void) updatePositions;
- (void) addParticle:(CCSprite *)particle;
@end