//
//  OptionScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "MainMenuScene.h"
#import "OptionScene.h"
#import "CCSprite.h"
#import "CustomTransitions.h"
#import "LocalStorageManager.h"
#import "Particles.h"
#import "SimpleAudioEngine.h"
#import "GameConfig.h"

@implementation OptionScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	
	OptionScene *layer = [OptionScene node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        NSString *lang = [LocalStorageManager getLang];
        NSString *menu_name = @"your name";
        NSString *menu_lang = @"language english";
        NSString *menu_sfx = @"sfx";
        NSString *menu_music = @"music";
        NSString *menu_reset = @"reset game";
        NSString *menu_on = @"on";
        NSString *menu_off = @"off";
        
        if ([lang isEqualToString:@"de"]) {
            menu_name = @"dein name";
            menu_lang = @"sprache deutsch";
            menu_sfx = @"sfx";
            menu_music = @"musik";
            menu_reset = @"zurücksetzen";
            menu_on = @"ein";
            menu_off = @"aus";
        }
        if ([lang isEqualToString:@"ch"]) {
            menu_name = @"di Namä";
            menu_lang = @"sprach bärndütsch";
            menu_sfx = @"sfx";
            menu_music = @"musig";
            menu_reset = @"zrüggsetzä";
            menu_on = @"ah";
            menu_off = @"us";
        }
        
        if ([LocalStorageManager isSFXEnabled]) {
            menu_sfx = [NSString stringWithFormat:@"%@ %@", menu_sfx, menu_on];
        } else {
            menu_sfx = [NSString stringWithFormat:@"%@ %@", menu_sfx, menu_off];
        }
        
        if ([LocalStorageManager isMusicEnabled]) {
            menu_music = [NSString stringWithFormat:@"%@ %@", menu_music, menu_on];
        } else {
            menu_music = [NSString stringWithFormat:@"%@ %@", menu_music, menu_off];
        }
        
        if ([LocalStorageManager getUsername] != DEFAULT_USERNAME) {
            menu_name = [LocalStorageManager getUsername];
        }
        
		CCSprite *background = [CCSprite spriteWithFile:@"mm_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
        
        CCSprite *_cloudrt = [CCSprite spriteWithSpriteFrameName:@"mm_options_cloud.png"];
		[_cloudrt setPosition:ccp(_cloudrt.contentSize.width/2, _cloudrt.contentSize.height/2)];
		[self addChild:_cloudrt z:10];
        
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_options_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 280)];
		[self addChild:_header z:10];
        
        CCLabelTTF *slash = [CCLabelTTF labelWithString:@"/" dimensions:CGSizeMake(50,50) alignment:UITextAlignmentLeft fontName:@"akaDylan Plain" fontSize:24];
		slash.color = ccc3(0,0,0);
		slash.position = ccp(winSize.width/2+25, winSize.height/2+22);
		[self addChild:slash z:10];
        
        SFXMenuItemImage *mainmenu = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_hover_%@.png",lang]] target:self selector:@selector(mainMenu:)];
        
		changename = [CCMenuItemFont itemFromString:menu_name target: self selector:@selector(nameprompt:)];
		changename.color = ccc3(0,0,0);
        
		SFXMenuItemFont *changelang = [SFXMenuItemFont itemFromString:menu_lang target: self selector:@selector(changelang:)];
		changelang.color = ccc3(0,0,0);
        
		SFXMenuItemFont *sfx = [SFXMenuItemFont itemFromString:menu_sfx target: self selector:@selector(toggleSFX:)];
		sfx.color = ccc3(0,0,0);
        
        SFXMenuItemFont *music = [SFXMenuItemFont itemFromString:menu_music target: self selector:@selector(toggleMusic:)];
		music.color = ccc3(0,0,0);
        
		SFXMenuItemFont *reset = [SFXMenuItemFont itemFromString:menu_reset target: self selector:@selector(resetSettings:)];
		reset.color = ccc3(0,0,0);
		
		CCMenu *menu = [CCMenu menuWithItems:mainmenu,changename,music,sfx,changelang,reset, nil];
		menu.position = ccp(winSize.width/2, winSize.height/2);
		[menu alignItemsVertically];
		
		[self addChild: menu z:10];
		mainmenu.position = ccp(winSize.width/2-mainmenu.contentSize.width/2, -winSize.height/2+mainmenu.contentSize.height/2);
        
        music.position = ccp(music.position.x-90, music.position.y+12);
        sfx.position = ccp(sfx.position.x+90, sfx.position.y+50);
        changelang.position = ccp(changelang.position.x, changelang.position.y+60);
        reset.position = ccp(reset.position.x, reset.position.y+43);
        
        [self schedule:@selector(addParticle) interval:0.5];
	}
	return self;
}


- (void) addParticle {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = 0;
	int maxY = winSize.height;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
    
    // Add particles
    MenuParticle *particle = [MenuParticle particle];
    particle.position = ccp(winSize.width + 30, actualY);
    [self addChild:particle z:0];
    [particle runAction:[CCSequence actions:[CCMoveTo actionWithDuration:particle.speed position:ccp(-particle.contentSize.width/2, actualY)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                         nil]];
}

-(void)spriteMoveFinished:(id)sender {
	MenuParticle *sprite = (MenuParticle *)sender;
    [sprite stopAllActions];
	[self removeChild:sprite cleanup:YES];
	sprite = nil;
}


- (void) toggleSFX: (id) sender 
{
    if ([LocalStorageManager isSFXEnabled]) {
        [LocalStorageManager setSFX:NO];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    } else {
        [LocalStorageManager setSFX:YES];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
    }
    
    // update
    [[CCDirector sharedDirector] replaceScene:[OptionScene scene]];
}

- (void) toggleMusic: (id) sender 
{
    if ([LocalStorageManager isMusicEnabled]) {
        [LocalStorageManager setMusic:NO];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    } else {
        [LocalStorageManager setMusic:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_mm.caf"];
    }
    
    // update
    [[CCDirector sharedDirector] replaceScene:[OptionScene scene]];
}

- (void) mainMenu: (id) sender 
{
	[[CCDirector sharedDirector] replaceScene:
	[MyCCSlideInRTransition transitionWithDuration:1.0f scene:[MainMenuScene node]]];
}

- (void) changelang: (id) sender 
{
    // get next lang..
    int index = 0;
    NSArray *langs = [LocalStorageManager getAvailableLangs];
    NSString *currentLang = [LocalStorageManager getLang];
    for (int i=0; i<[langs count]; i++) {
		NSDictionary *entry = [langs objectAtIndex:i];
		if ([[entry objectForKey:@"code"] isEqualToString:currentLang] ) {
			index = i;
		}
	}
    
    if (index >= [langs count]-1) {
        index = 0;
    } else {
        index++;
    }
    
    NSDictionary *lang = [langs objectAtIndex:index];
    [LocalStorageManager setLang:[lang objectForKey:@"code"]];
    [[CCDirector sharedDirector] replaceScene:[OptionScene scene]];
}


- (void) resetSettings: (id) sender 
{
    UIView* view = [[CCDirector sharedDirector] openGLView];
    NSString *lang = [LocalStorageManager getLang];
    NSString *r_text = @"You are going to reset your Highscore, unlocked weapons and settings! Are you sure?";
    NSString *r_title = @"Reset settings";
    NSString *r_cancel = @"Cancel";
    NSString *r_ok = @"OK";
    
    if ([lang isEqualToString:@"de"]) {
        r_text = @"Willst du wirklich deinen Highscore, freigespielte Waffen und Einstellungen löschen? Es gibt kein zurück!";
        r_title = @"Zurücksetzen";
        r_cancel = @"Nein";
        r_ok = @"OK";
    }
    if ([lang isEqualToString:@"ch"]) {
        r_text = @"Ds setzt di Highscore, freigspiui Waffe u Iistellige zrügg! Bisch ganz sicher du wosch das?";
        r_title = @"Zrüggsetzä";
        r_cancel = @"Nei";
        r_ok = @"OK";
    }
    
    UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle:r_title message:r_text delegate: self cancelButtonTitle:r_cancel otherButtonTitles:r_ok, nil];
    [view addSubview: myAlertView];
    
    [myAlertView show];
    [myAlertView release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        // confirm..
        [LocalStorageManager resetSettings];
        [[CCDirector sharedDirector] replaceScene:[OptionScene scene]];
    }
}

- (void) nameprompt: (id) sender
{
	// bind label which will be updated after keyboard input..
	[LocalStorageManager bindUsernameDisplayLabel:changename];
	// show keyboard..
	[[[UIApplication sharedApplication] delegate] specifyUsername];
}

- (void) dealloc
{	
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	// release userLabel.. else app crashes after next update of username outside this scene!
	[LocalStorageManager dealloc];
	[super dealloc];
}
@end