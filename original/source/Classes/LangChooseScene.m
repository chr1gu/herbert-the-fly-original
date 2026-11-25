//
//  LangChooseScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 5/26/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "MainMenuScene.h"
#import "LocalStorageManager.h"
#import "LangChooseScene.h"
#import "SimpleAudioEngine.h"
#import "SFXMenuItemFont.h"

@implementation LangChooseScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	
	LangChooseScene *layer = [LangChooseScene node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
    
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"mm_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
		
		[CCMenuItemFont setFontSize:26];
		[CCMenuItemFont setFontName: @"akaDylan Plain"];
		
		SFXMenuItemFont *de = [SFXMenuItemFont itemFromString:@"Deutsch" target: self selector:@selector(startDE:)];
		de.color = ccc3(0,0,0);
        
        SFXMenuItemFont *ch = [SFXMenuItemFont itemFromString:@"Bärndütsch" target: self selector:@selector(startCH:)];
		ch.color = ccc3(0,0,0);
        
        SFXMenuItemFont *en = [SFXMenuItemFont itemFromString:@"English" target: self selector:@selector(startEN:)];
		en.color = ccc3(0,0,0);
        
		CCMenu *menu = [CCMenu menuWithItems:de, ch, en, nil];
		[menu alignItemsVertically];
		[self addChild: menu];
        
        // load sound..
        if ([LocalStorageManager isMusicEnabled]) {
            [[SimpleAudioEngine sharedEngine] preloadEffect:@"audio/music/bg_mm.caf"];
        }
	}
	return self;
}

- (void) startDE: (id) sender 
{
    [LocalStorageManager setLang:@"de"];
    [self mainMenu];
}

- (void) startCH: (id) sender
{
    [LocalStorageManager setLang:@"ch"];
    [self mainMenu];
}

- (void) startEN: (id) sender
{
    [LocalStorageManager setLang:@"en"];
    [self mainMenu];
}

- (void) mainMenu
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[MainMenuScene animatedScene] withColor:ccc3(255, 255, 255)]];
}

- (void) dealloc
{	
	[super dealloc];
}
@end