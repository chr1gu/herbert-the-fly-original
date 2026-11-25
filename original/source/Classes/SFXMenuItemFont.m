//
//  SFXMenu.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 6/1/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "SFXMenuItemFont.h"
#import "SimpleAudioEngine.h"
#import "LocalStorageManager.h"


@implementation SFXMenuItemFont

-(void) selected {

    if ([LocalStorageManager isSFXEnabled]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/menu.caf"];
    }
    [super selected];
}

@end
