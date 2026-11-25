//
//  LayerGradientAnim.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/17/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "LayerGradientAnim.h"


@implementation LayerGradientAnim

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v
{
    return [super layerWithColor:start fadingTo:end alongVector:v];
}

- (void) fadeColors
{
    
    ccColor3B S = {
        [self startColor].r-_r_start,
        [self startColor].g-_g_start,
        [self startColor].b-_b_start
    };
    
    ccColor3B E = {
        [self endColor].r-_r_end,
        [self endColor].g-_g_end,
        [self endColor].b-_b_end
    };
    
    // limit colorfading if it reaches the end color
    if (_startColorOld.r < _startColor.r && S.r > _startColor.r || _startColorOld.r > _startColor.r && S.r < _startColor.r) {
        S.r = _startColor.r;
    }
    if (_startColorOld.g < _startColor.g && S.g > _startColor.g || _startColorOld.g > _startColor.g && S.g < _startColor.g) {
        S.g = _startColor.g;
    }
    if (_startColorOld.b < _startColor.b && S.b > _startColor.b || _startColorOld.b > _startColor.b && S.b < _startColor.b) {
        S.b = _startColor.b;
    }
    if (_endColorOld.r < _endColor.r && E.r > _endColor.r || _endColorOld.r > _endColor.r && E.r < _endColor.r) {
        E.r = _endColor.r;
    }
    if (_endColorOld.g < _endColor.g && E.g > _endColor.g || _endColorOld.g > _endColor.g && E.g < _endColor.g) {
        E.g = _endColor.g;
    }
    if (_endColorOld.b < _endColor.b && E.b > _endColor.b || _endColorOld.b > _endColor.b && E.b < _endColor.b) {
        E.b = _endColor.b;
    }
    
    [self setStartColor:S];
    [self setEndColor:E];
    
    //NSLog(@"UPDATE self-r:%f r-step:%f r-end:%f",(float)[self startColor].r,(float)_r_start,(float)_startColor.r);
}

- (void) clearScheduler
{
    // fix some small rounding issues by setting the definitive colors again
    [self setStartColor:_startColor];
    [self setEndColor:_endColor];
    //NSLog(@"FINALCUT self-r:%f r-step:%f r-end:%f",(float)[self startColor].r,(float)_r_start,(float)_startColor.r);
    [self unscheduleAllSelectors];
}

- (void) newColorFade: (ccColor3B) start: (ccColor3B) end: (float) duration
{
    // stop previous fadings
    [self unscheduleAllSelectors];
    
    _endColor = end;
    _startColor = start;
    float intervalTime = 0.06;
    
    _startColorOld = [self startColor];
    _endColorOld = [self endColor];
    
    _r_start = (float)[self startColor].r-(float)start.r;
    _g_start = (float)[self startColor].g-(float)start.g;
    _b_start = (float)[self startColor].b-(float)start.b;
    _r_end = (float)[self endColor].r-(float)end.r;
    _g_end = (float)[self endColor].g-(float)end.g;
    _b_end = (float)[self endColor].b-(float)end.b;
    
    //NSLog(@"Initial: start-r:%f",_r_start);
    
    _r_start = (float)_r_start/(duration/intervalTime);
    _g_start = (float)_g_start/(duration/intervalTime);
    _b_start = (float)_b_start/(duration/intervalTime);
    _r_end = (float)_r_end/(duration/intervalTime);
    _g_end = (float)_g_end/(duration/intervalTime);
    _b_end = (float)_b_end/(duration/intervalTime);
    
    [self fadeColors];
    [self schedule:@selector(fadeColors) interval:intervalTime];
    [self schedule:@selector(clearScheduler) interval:duration];
}

@end
