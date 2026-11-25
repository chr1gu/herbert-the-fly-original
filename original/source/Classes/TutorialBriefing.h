//
//  TutorialBriefing.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 6/3/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "cocos2d.h"
#import "SFXMenuItemImage.h"
#import "SFXMenuItemFont.h"

@interface TutorialBriefing : CCSprite {
    CCLabelTTF *txt;
    CCSprite *header;
    SFXMenuItemFont *next;
    
    CCScene* mainWindow;
    int step;
}

+(id)initStep:(int)step:(id)delegate;

- (void) hide;
- (void) introScreen:(id)delegate;
- (void) step2:(id)delegate;
- (void) step3:(id)delegate;
- (void) step4:(id)delegate;
- (void) step5:(id)delegate;

@end
