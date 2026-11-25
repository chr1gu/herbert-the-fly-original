//
//  LayerGradientAnim.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/17/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "cocos2d.h"


@interface LayerGradientAnim : CCLayerGradient {
    
    float _r_start;
    float _r_end;
    float _g_start;
    float _g_end;
    float _b_start;
    float _b_end;
    
    ccColor3B _endColor;
    ccColor3B _startColor;
    ccColor3B _endColorOld;
    ccColor3B _startColorOld;
}

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v;

- (void) newColorFade: (ccColor3B) start: (ccColor3B) end: (float) duration;

@end
