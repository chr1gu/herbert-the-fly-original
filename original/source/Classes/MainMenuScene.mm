//
//  MainMenuScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//
#import "MainMenuScene.h"
#import "CustomTransitions.h"
#import "HelloWorldScene.h"
#import "CreditScene.h"
#import "HighscoreScene.h"
#import "OptionScene.h"
#import "CCSprite.h"
#import "MotionSprite.h"
#import "LocalStorageManager.h"
#import "Particles.h"
#import "SponsorOverlay.h"


// TOBE DELETED..
//#import "GameOverScene.h"

@implementation MainMenuScene

+ (id)animatedScene {
    MainMenuScene *scene = [MainMenuScene node];
    [scene initAnimation];
    return scene;
}

- (id) init {
    
    if( (self=[super init] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"mm_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
		
		[CCMenuItemFont setFontSize:24];
		[CCMenuItemFont setFontName: @"akaDylan Plain"];
        
        NSString *lang = [LocalStorageManager getLang];
        NSString *menu_newgame = @"New Game";
        NSString *menu_tutorial = @"Tutorial";
        NSString *menu_highscore = @"Highscore";
        NSString *menu_options = @"Options";
        NSString *menu_credits = @"Info";
        
        if ([lang isEqualToString:@"de"]) {
            menu_newgame = @"Neues Spiel";
            menu_tutorial = @"Tutorial";
            menu_highscore = @"Rangliste";
            menu_options = @"Optionen";
            menu_credits = @"Info";
        }
        if ([lang isEqualToString:@"ch"]) {
            menu_newgame = @"Nöis Schpiu";
            menu_tutorial = @"Tutorial";
            menu_highscore = @"Ranglischtä";
            menu_options = @"Optionä";
            menu_credits = @"Infos";
        }
        
        // clouds
        cloudLeft = [CCSprite spriteWithSpriteFrameName:@"mm_main_cloud_left.png"];
        cloudLeftPos = ccp(cloudLeft.contentSize.width/2-18, cloudLeft.contentSize.height/2-19);
        cloudLeft.position = ccp(cloudLeftPos.x, cloudLeftPos.y);
        
        cloudRight = [CCSprite spriteWithSpriteFrameName:@"mm_main_cloud_right.png"];
        cloudRightPos = ccp(winSize.width-(cloudRight.contentSize.width/2)+18, cloudRight.contentSize.height/2-18);
        cloudRight.position = ccp(cloudRightPos.x, cloudRightPos.y);
        
        [self addChild: cloudRight z:10];
        [self addChild: cloudLeft z:10];
        
		// Font Item
		play = [SFXMenuItemFont itemFromString:menu_newgame target:self selector:@selector(startGame:)];
		play.color = ccc3(0,0,0);
		
		tut = [SFXMenuItemFont itemFromString:menu_tutorial target: self selector:@selector(tutorial:)];
		tut.color = ccc3(0,0,0);
		
		highscore = [SFXMenuItemFont itemFromString:menu_highscore target: self selector:@selector(highscore:)];
		highscore.color = ccc3(0,0,0);
		
		options = [SFXMenuItemFont itemFromString:menu_options target: self selector:@selector(options:)];
		options.color = ccc3(0,0,0);
		
		credits = [SFXMenuItemFont itemFromString:menu_credits target: self selector:@selector(credits:)];
		credits.color = ccc3(0,0,0);
        
        sponsoring = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_icon_sponsor.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_icon_sponsor.png"] target:self selector:@selector(sponsorOverlay:)];
        // SPONSORING IS NOT ENABLED IN THE CURRENT VERSION
        [sponsoring setIsEnabled:NO];
        sponsoring.visible = NO;
        
        facebook = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_icon_fb.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_icon_fb.png"] target:self selector:@selector(facebookLink:)];
		
        CCMenu *menu = [CCMenu menuWithItems:play, tut, highscore, options, credits, sponsoring, facebook, nil];
		menu.position = ccp(menu.position.x, 65);
		[menu alignItemsVertically];
        
		tut.position = ccp(tut.position.x, tut.position.y+10);
		highscore.position = ccp(highscore.position.x, highscore.position.y+20);
		options.position = ccp(options.position.x, options.position.y+30);
		credits.position = ccp(credits.position.x, credits.position.y+40);
        sponsoring.position = ccp(winSize.width/2-70, -35);
        facebook.position = ccp(winSize.width/2-27, -38);
		
		if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] && [LocalStorageManager isMusicEnabled]) {
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_mm.caf"];
		}
		[self addChild: menu z:10];
        
        _logoText = [CCSprite spriteWithSpriteFrameName:@"mm_main_logo_misantropical.png"];
        _logoText.position = ccp(winSize.width/2, 228);
        [self addChild:_logoText z:10];
		
		_animLogo = [CCSprite spriteWithSpriteFrameName:@"mm_main_logo.png"];
		_animLogo.position = ccp(winSize.width/2, 257);
		[self addChild:_animLogo z:10];
        
        [self startBackgroundAnimations];
        
        particles = [[NSMutableArray alloc] init];
        [self schedule:@selector(addParticle) interval:0.5];
	}	
	return self;
}

- (void) initAnimation {
    
    // LOGO
    [_animLogo stopAllActions];
    _animLogo.position = ccp(_animLogo.position.x, 400);
    [_animLogo runAction: [CCSequence actions:
                           [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(_animLogo.position.x, 257)]],
                           [CCCallFuncN actionWithTarget:self selector:@selector(startBackgroundAnimations)],
                           nil]];
    _logoText.opacity = 0;
    [_logoText runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:0.4],
                          [CCFadeIn actionWithDuration:0.3],
                          nil]];
    
    // CLOUDS
    cloudLeft.position = ccp(cloudLeftPos.x-180, cloudLeftPos.y-40);
    cloudRight.position = ccp(cloudRightPos.x+180, cloudRightPos.y-40);
    
    
    // cloud fadein
    [cloudLeft runAction:[CCSequence actions:
                          [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:1 position:cloudLeftPos]],
                          nil]];
    [cloudRight runAction:[CCSequence actions:
                           [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:1 position:cloudRightPos]],
                           nil]];
    
    
    // MENU
    play.opacity = 0;
    tut.opacity = 0;
    highscore.opacity = 0;
    options.opacity = 0;
    credits.opacity = 0;
    
    play.scale = 0.5;
    tut.scale = 0.5;
    highscore.scale = 0.5;
    options.scale = 0.5;
    credits.scale = 0.5;
    
    facebook.position = ccp(facebook.position.x, facebook.position.y-60);
    sponsoring.position = ccp(sponsoring.position.x, sponsoring.position.y-60);
    
    // menu fadein/out parameters
    menuFadeTimePause = 0.1;
    menuFadeSpeed = 0.3;
    int startdelay = 4;
    
    // menu fadein
    [play runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:menuFadeTimePause*startdelay],
                     [CCSpawn actions:
                      [CCFadeIn actionWithDuration:menuFadeSpeed],
                      [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:1]],
                      nil],
                     nil]];
    
    [tut runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+1)],
                    [CCSpawn actions:
                     [CCFadeIn actionWithDuration:menuFadeSpeed],
                     [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:1]],
                     nil],
                    nil]];
    
    [highscore runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+2)],
                          [CCSpawn actions:
                           [CCFadeIn actionWithDuration:menuFadeSpeed],
                           [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:1]],
                           nil],
                          nil]];
    
    [options runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+3)],
                        [CCSpawn actions:
                         [CCFadeIn actionWithDuration:menuFadeSpeed],
                         [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:1]],
                         nil],
                        nil]];
    
    [credits runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+4)],
                        [CCSpawn actions:
                         [CCFadeIn actionWithDuration:menuFadeSpeed],
                         [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:1]],
                         nil],
                        nil]];
    
    [sponsoring runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+5)],
                        [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:menuFadeSpeed position:ccp(sponsoring.position.x, sponsoring.position.y+60)]],
                        nil]];
    
    [facebook runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:menuFadeTimePause*(startdelay+6)],
                           [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:menuFadeSpeed position:ccp(facebook.position.x, facebook.position.y+60)]],
                           nil]];
    
}

- (void) startBackgroundAnimations {
    // anim logo
    id move = [CCMoveBy actionWithDuration:2 position:ccp(0,5)];
    id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
    id move_ease_back = [move_ease reverse];
    id seq1 = [CCSequence actions: move_ease, [CCDelayTime actionWithDuration:0.1f], move_ease_back, [CCDelayTime actionWithDuration:0.1f], nil];	
    [_animLogo runAction: [CCRepeatForever actionWithAction:seq1]];
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
    
    [particles addObject:particle];
}

-(void)spriteMoveFinished:(id)sender {
	MenuParticle *sprite = (MenuParticle *)sender;
    [sprite stopAllActions];
	[self removeChild:sprite cleanup:YES];
    [particles removeObject:sprite];
	sprite = nil;
}

- (void) showLoading {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *loading = [CCSprite spriteWithSpriteFrameName:@"mm_loading.png"];
    loading.position = ccp(winSize.width-loading.contentSize.width/2, loading.contentSize.height/2-60);
    [loading runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.3 position:ccp(loading.position.x, loading.position.y+60)]]];
    [self addChild:loading z:10];
}

- (void) startGameScene {
    
    // loading assets again..
    [LocalStorageManager loadIngameAssets];
    
    if (startTutorial) {
        [[CCDirector sharedDirector] replaceScene:[HelloWorld tutorialMode]];
    } else {
        [[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
    }
}

- (void) disableMenu
{
    [play setIsEnabled:NO];
    [tut setIsEnabled:NO];
    [highscore setIsEnabled:NO];
    [options setIsEnabled:NO];
    [credits setIsEnabled:NO];
    [sponsoring setIsEnabled:NO];
    [facebook setIsEnabled:NO];
    
    [play setColor:ccc3(0,0,0)];
    [tut setColor:ccc3(0,0,0)];
    [highscore setColor:ccc3(0,0,0)];
    [options setColor:ccc3(0,0,0)];
    [credits setColor:ccc3(0,0,0)];
}

- (void) startGame: (id) sender 
{
    [self disableMenu];
    
    // first game start start tutorial
    if ([LocalStorageManager isFirstStart]) {
        startTutorial = YES;
    }
    
    // remove particles..
    [self unschedule:@selector(addParticle)];
    for(id item in particles) {
        [item stopAllActions];
        [self removeChild:item cleanup:YES];
    }
    [particles release];
    
	[_animLogo stopAllActions];
    [_animLogo runAction: [CCSequence actions:
                           [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(_animLogo.position.x, 400)]],
                           [CCDelayTime actionWithDuration:0.7],
                           [CCCallFuncN actionWithTarget:self selector:@selector(showLoading)],
                           [CCDelayTime actionWithDuration:0.3],
                           [CCCallFuncN actionWithTarget:self selector:@selector(startGameScene)],
                           nil]];
    
    [_logoText runAction:[CCSequence actions:
                          [CCFadeOut actionWithDuration:0.3],
                          nil]];
    
    // cloud fadeout
    [cloudLeft runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:0.2],
                          [CCSpawn actions:
                           [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:1]],
                           [CCEaseExponentialIn actionWithAction:[CCScaleTo actionWithDuration:1 scale:5]],
                           [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:1 position:ccp(cloudLeft.position.x-900,cloudLeft.position.y-200)]],
                           nil],
                          nil]];
    [cloudRight runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.3],
                           [CCSpawn actions:
                            [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:1]],
                            [CCEaseExponentialIn actionWithAction:[CCScaleTo actionWithDuration:1 scale:5]],
                            [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:1 position:ccp(cloudLeft.position.x+900,cloudLeft.position.y-200)]],
                            nil],
                           nil]];
    
    // menu fadeout
    [play runAction:[CCSequence actions:
                     [CCSpawn actions:
                      [CCFadeOut actionWithDuration:menuFadeSpeed],
                      [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:0.5]],
                      nil],
                     nil]];
    
    [tut runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:menuFadeTimePause],
                    [CCSpawn actions:
                     [CCFadeOut actionWithDuration:menuFadeSpeed],
                     [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:0.5]],
                     nil],
                    nil]];
    
    [highscore runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:menuFadeTimePause*2],
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:menuFadeSpeed],
                           [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:0.5]],
                           nil],
                          nil]];
    
    [options runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:menuFadeTimePause*3],
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:menuFadeSpeed],
                         [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:0.5]],
                         nil],
                        nil]];
    
    [credits runAction:[CCSequence actions:
                        [CCDelayTime actionWithDuration:menuFadeTimePause*4],
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:menuFadeSpeed],
                         [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:menuFadeSpeed scale:0.5]],
                         nil],
                        nil]];
    
    [sponsoring runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:menuFadeTimePause],
                           [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:menuFadeSpeed position:ccp(sponsoring.position.x, sponsoring.position.y-60)]],
                           nil]];
    
    [facebook runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:menuFadeTimePause*2],
                         [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:menuFadeSpeed position:ccp(facebook.position.x, facebook.position.y-60)]],
                         nil]];
}

- (void) tutorial: (id) sender 
{
    [self disableMenu];
    startTutorial = YES;
    [self startGame:nil];
    
    //GameOverScene *sc = [GameOverScene node];
    //sc.layer.score = 7680;
    //[[CCDirector sharedDirector] replaceScene:sc];
}

- (void) sponsorOverlay: (id) sender 
{
    //[[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.3 scene:[SponsorOverlay scene]]];
}

- (void) facebookLink: (id) sender 
{
    NSString *url = URL_FACEBOOK; 
    
    /*CGRect webFrame = CGRectMake(0, 0, 300, 300);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [[[CCDirector sharedDirector] openGLView] addSubview:webView];
    return;*/
         
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) credits: (id) sender 
{
    [self disableMenu];
	[[CCDirector sharedDirector] replaceScene:
	 [MyCCSlideInBTransition transitionWithDuration:1.0f scene:[CreditScene scene]]];
}

- (void) highscore: (id) sender 
{
    [self disableMenu];
	[[CCDirector sharedDirector] replaceScene:
	 [MyCCSlideInRTransition transitionWithDuration:1.0f scene:[HighscoreScene scene]]];
}

- (void) options: (id) sender 
{
    [self disableMenu];
	[[CCDirector sharedDirector] replaceScene:
	 [MyCCSlideInLTransition transitionWithDuration:1.0f scene:[OptionScene scene]]];
}

@end
