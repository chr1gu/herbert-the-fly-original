//
//  OptionScene.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "cocos2d.h"
#import "SFXMenuItemFont.h"
#import "SFXMenuItemImage.h"

@interface OptionScene : CCLayer
{
    SFXMenuItemFont *changename;
}

- (void) mainMenu: (id) sender;

+(id) scene;

@end