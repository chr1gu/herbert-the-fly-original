//
//  Clouds.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/31/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Cloud : CCSprite {
    int _index;
	float _speed;
}

@property (nonatomic, assign) int index;
@property (nonatomic, assign) float speed;

@end

@interface ForegroundCloud : Cloud {
}
+(id)cloud;
@end

@interface BackgroundCloud : Cloud {
}
+(id)cloud;
@end

@interface MiddleCloud : Cloud {
}
+(id)cloud;
@end

@interface GroundCloud : Cloud {
}
+(id)cloud;
@end

@interface Rainbow : Cloud {
    
    CCSprite *rainbow;
}
+(id)cloud;
- (void) checkPosition;
- (void) addRainbow;
- (void) changeTexture;
@end