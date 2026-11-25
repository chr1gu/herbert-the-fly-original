//
//  CreditScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "MainMenuScene.h"
#import "CreditScene.h"
#import "CCSprite.h"
#import "CustomTransitions.h"
#import "LocalStorageManager.h"
#import "SFXMenuItemImage.h"
#import "GameConfig.h"

@implementation CreditScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	
	CreditScene *layer = [CreditScene node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
    
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        NSString *lang = [LocalStorageManager getLang];
        
        NSString *gameby_label = @"game by";
        NSString *musicby_label = @"music by";
        NSString *musicbyname_label = @"justin lassen";
        NSString *gamebyname_label = @"dani rolli & chris ebert";
        NSString *thanks_label = @"special thanks to: \nfabienne gal, justin lassen, ray “awesome“ wenderlich,\nata “toast“, cocos2d community & george clooney,\nwe love you.";
        
        if ([lang isEqualToString:@"de"]) {
            gameby_label = @"spiel von";
            musicby_label = @"musik von";
            musicbyname_label = @"justin lassen";
            gamebyname_label = @"dani rolli & chris ebert";
            thanks_label = @"fettes danke an:\nfabienne gal, justin lassen, ray “awesome“ wenderlich,\nata “toast“, cocos2d community & george clooney,\nwe love you.";
        }
        if ([lang isEqualToString:@"ch"]) {
            gameby_label = @"spiu vo";
            musicby_label = @"musig vo";
            musicbyname_label = @"justin lassen";
            gamebyname_label = @"dani rolli & chris ebert";
            thanks_label = @"fetts merci a:\nfabienne gal, justin lassen, ray “awesome“ wenderlich,\nata “toast“, cocos2d community & george clooney,\nwe love you.";
        }
		
		CCSprite *background = [CCSprite spriteWithFile:@"mm_credits_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
        
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_info_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 280)];
		[self addChild:_header];
		
		[CCMenuItemFont setFontSize:26];
		[CCMenuItemFont setFontName: @"akaDylan Plain"];
        
        CCLabelTTF *gameby = [CCLabelTTF labelWithString:gameby_label dimensions:CGSizeMake(150,109) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:14];
		gameby.color = ccc3(0,0,0);
		gameby.position = ccp(winSize.width/2-90, winSize.height/2+30);
		[self addChild:gameby];
        
        CCLabelTTF *gamebyname = [CCLabelTTF labelWithString:gamebyname_label dimensions:CGSizeMake(200,69) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:10];
		gamebyname.color = ccc3(0,0,0);
		gamebyname.position = ccp(winSize.width/2-90, winSize.height/2+30);
		[self addChild:gamebyname];
        
        CCLabelTTF *musicby = [CCLabelTTF labelWithString:musicby_label dimensions:CGSizeMake(150,109) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:14];
		musicby.color = ccc3(0,0,0);
		musicby.position = ccp(winSize.width/2+90, winSize.height/2+30);
		[self addChild:musicby];
        
        CCLabelTTF *musicbyname = [CCLabelTTF labelWithString:musicbyname_label dimensions:CGSizeMake(200,69) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:10];
		musicbyname.color = ccc3(0,0,0);
		musicbyname.position = ccp(winSize.width/2+90, winSize.height/2+30);
		[self addChild:musicbyname];
        
        SFXMenuItemImage *etite = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info_logo_appetite.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info_logo_appetite.png"] target:self selector:@selector(etiteTap:)];
        SFXMenuItemImage *justin = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info_logo_nihil.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info_logo_nihil.png"] target:self selector:@selector(justinTap:)];
        
		SFXMenuItemImage *mainmenu = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_hover_%@.png",lang]] target:self selector:@selector(mainMenu:)];
        
		CCMenu *menu = [CCMenu menuWithItems:etite,justin,mainmenu, nil];
		[menu alignItemsVertically];
        
        CCLabelTTF *thanks = [CCLabelTTF labelWithString:thanks_label dimensions:CGSizeMake(460,150) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:10];
		thanks.color = ccc3(0,0,0);
		thanks.position = ccp(winSize.width/2, 10);
		[self addChild:thanks];
		
		[self addChild: menu];
		mainmenu.position = ccp(winSize.width/2-mainmenu.contentSize.width/2, -winSize.height/2+mainmenu.contentSize.height/2);
        etite.position = ccp(-90, -5);
        justin.position = ccp(90, -10);
	}
	return self;
}

- (void) mainMenu: (id) sender 
{
	[[CCDirector sharedDirector] replaceScene:
	[MyCCSlideInTTransition transitionWithDuration:1.0f scene:[MainMenuScene node]]];
}

- (void) etiteTap: (id) sender 
{
	NSString *url = URL_ETITE;       
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) justinTap: (id) sender 
{
	NSString *url = URL_JUSTIN;       
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) dealloc
{	
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end