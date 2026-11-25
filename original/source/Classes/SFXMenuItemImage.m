//
//  SFXMenu.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 6/1/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "SFXMenuItemImage.h"
#import "SimpleAudioEngine.h"
#import "LocalStorageManager.h"

@implementation SFXMenuItemImage

-(void) selected {

    if ([LocalStorageManager isSFXEnabled]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/menu.caf"];
    }
    [super selected];
}

@end
