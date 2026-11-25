//
//  MainMenuScene.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SFXMenuItemFont.h"
#import "SFXMenuItemImage.h"

@interface MainMenuScene : CCLayer {
    
    // header
    CCSprite *_animLogo;
    CCSprite *_logoText;
    
    // Menu
    SFXMenuItemFont *play;
    SFXMenuItemFont *tut;
    SFXMenuItemFont *highscore;
    SFXMenuItemFont *options;
    SFXMenuItemFont *credits;
    SFXMenuItemImage *sponsoring;
    SFXMenuItemImage *facebook;
    
    // Clouds
    CCSprite *cloudLeft;
    CCSprite *cloudRight;
    CGPoint cloudLeftPos;
    CGPoint cloudRightPos;
    
    float menuFadeTimePause;
    float menuFadeSpeed;
    
    //particles
    NSMutableArray *particles;
    BOOL startTutorial;
    
}
- (void) startBackgroundAnimations;
- (void) showLoading;
- (void) startGameScene;
- (void) startGame: (id) sender;
- (void) tutorial: (id) sender;
- (void) credits: (id) sender;
- (void) highscore: (id) sender;
- (void) options: (id) sender;
- (void) sponsorOverlay: (id) sender;
- (void) facebookLink: (id) sender;
- (void) disableMenu;

- (void) initAnimation;
+ (id) animatedScene;

@end