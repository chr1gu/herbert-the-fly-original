//
//  GameOverScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/29/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "GameConfig.h"
#import "LocalStorageManager.h"
#import "GameOverScene.h"
#import "ReloadMainScene.h"
#import "MainMenuScene.h"
#import "LocalStorageManager.h"
#import "SFXMenuItemFont.h"
#import "SimpleAudioEngine.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [GameOverLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation GameOverLayer
@synthesize projectilesDestroyed = _projectilesDestroyed;
@synthesize score = _score;
@synthesize gametime = _gametime;

// Facebook
@synthesize facebook;
@synthesize facebookUser;

static NSString* kAppId = @"121445621262667";

-(id) init
{
	if( (self=[super init] ))
    {		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		NSString *lang = [LocalStorageManager getLang];
        
        NSString *share = @"share your awesomeness";
        NSString *tryagain = @"try again";
        NSString *mainmenutitle = @"mainmenu";
        NSString *yourscore = @"your score";
        NSString *weapons = @"weapons";
        
        if ([lang isEqualToString:@"de"]) {
            share = @"zeige wie toll du bist";
            tryagain = @"nochmal";
            mainmenutitle = @"hauptmenü";
            yourscore = @"deine Punkte";
            weapons = @"waffen";
        }
        if ([lang isEqualToString:@"ch"]) {
            share = @"zeigs aune uf";
            tryagain = @"nomau";
            mainmenutitle = @"houptmenü";
            yourscore = @"dini pünkt";
            weapons = @"waffä";
        }
        
        CCSprite *background = [CCSprite spriteWithFile:@"mm_gameover_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
		
        if ([LocalStorageManager isMusicEnabled]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_gameover.caf"];
        }
        
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_gameover_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 280)];
		[self addChild:_header];
        
        CCLabelTTF *scoretitle = [CCLabelTTF labelWithString:yourscore dimensions:CGSizeMake(320,60) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
        scoretitle.color = ccc3(0,0,0);
        scoretitle.position = ccp(winSize.width/2, winSize.height/2+58);
        [self addChild:scoretitle];
        
        CCLabelTTF *weapontitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ %i/%i",weapons,[[LocalStorageManager getUnlockedItems] count]-NUM_ITEMS,NUM_WEAPONS] dimensions:CGSizeMake(320,60) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
        weapontitle.color = ccc3(0,0,0);
        weapontitle.position = ccp(winSize.width/2, winSize.height/2+5);
        [self addChild:weapontitle];
        
        CCSprite *herb = [CCSprite spriteWithSpriteFrameName:@"mm_gameover_herb.png"];
		[herb setPosition:ccp(412, winSize.height/2-64)];
		[self addChild:herb];
        
        CCLabelTTF *_otherInfos = [CCLabelTTF labelWithString:share dimensions:CGSizeMake(320,60) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
        _otherInfos.color = ccc3(0,0,0);
        _otherInfos.position = ccp(winSize.width/2, winSize.height/2-107);
        [self addChild:_otherInfos];
        
        // levitate anim..
        id move = [CCMoveBy actionWithDuration:2 position:ccp(0,5)];
        id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
        id move_ease_back = [move_ease reverse];
        id seq1 = [CCSequence actions: move_ease, [CCDelayTime actionWithDuration:0.1f], move_ease_back, [CCDelayTime actionWithDuration:0.1f], nil];	
        [herb runAction: [CCRepeatForever actionWithAction:seq1]];
        
		
		//menu
		[CCMenuItemFont setFontSize:26];
		[CCMenuItemFont setFontName: @"akaDylan Plain"];
		
		// Font Item
		SFXMenuItemFont *play = [SFXMenuItemFont itemFromString:tryagain target: self selector:@selector(restartGame)];
		play.color = ccc3(0,0,0);
		
		SFXMenuItemFont *mainmenu = [SFXMenuItemFont itemFromString:mainmenutitle target: self selector:@selector(mainMenuGame)];
		mainmenu.color = ccc3(0,0,0);
        
        [facebook logout:self];
        SFXMenuItemFont *facebookLink = [SFXMenuItemFont itemFromString:@"facebook" target: self selector:@selector(facebookTapped:)];
		facebookLink.color = ccc3(55,88, 154);
		
		CCMenu *menu = [CCMenu menuWithItems:play, mainmenu, facebookLink, nil];
		[menu alignItemsVertically];
		
        play.position = ccp(play.position.x, play.position.y-45);
		mainmenu.position = ccp(mainmenu.position.x, mainmenu.position.y-35);
        facebookLink.position = ccp(facebookLink.position.x, facebookLink.position.y-66);
		
		[self addChild:menu];
		
		// Show points after a small delay.. because you have to pass them
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:0.1],
						 [CCCallFunc actionWithTarget:self selector:@selector(calcPoints)],
						 nil]];
	}	
	return self;
}


- (void)calcPoints {
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
    _tmpScore = 0;
	_scoreLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(320,40) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:26];
	_scoreLabel.color = ccc3(0,0,0);
	_scoreLabel.position = ccp(winSize.width/2, winSize.height/2+50);
	[self addChild:_scoreLabel];
    [self updateScore];
    
	
	//CCLabelTTF *_otherInfos = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"You survived %i seconds and killed %i enemies",_gametime,_projectilesDestroyed] dimensions:CGSizeMake(320,60) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    
    if (_tmpScore < _score) {
        // by a framerate of 60 it should always take about 2 seconds..
        _scoreCountStep = _score/60;
        if (_scoreCountStep < 1) {
            _scoreCountStep = 2;
        }
        // if divide by 10 = zero, add one more in order to count nicer..
        if (_scoreCountStep%10==0) {
            _scoreCountStep++;
        }

        [self schedule:@selector(updateScore)];
        
        [_scoreLabel runAction:
         [CCRepeatForever actionWithAction:[CCSequence actions:
                                            [CCScaleTo actionWithDuration:0.3 scale:0.8],
                                            [CCScaleTo actionWithDuration:0.3 scale:1.1],
                                            nil]]];
    }
	
	if ([LocalStorageManager inHighscore:_score]!=-1) {
		
		// SHOW MESSAGE: you reached a new highscore..
		// .....
		// check if username is set..
		NSString *name = [LocalStorageManager getUsername];
		if([name isEqualToString:DEFAULT_USERNAME] || [name isEqualToString:@""]){
            
			_menu_namescreen = [[CCSprite spriteWithFile:@"menu_namescreen.png"] retain];
			_menu_namescreen.position = ccp(winSize.width/2, winSize.height/2);
			[self addChild:_menu_namescreen z:98];
            
            NSString *lang = [LocalStorageManager getLang];
            _menu_namescreen_title = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"menu_namescreen_%@.png",lang]];
            [_menu_namescreen_title setPosition:ccp(winSize.width/2, 280)];
            [_menu_namescreen addChild:_menu_namescreen_title];
			
			_username = [CCLabelTTF labelWithString:[LocalStorageManager getUsername] dimensions:CGSizeMake(150,50) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
			_username.color = ccc3(0,0,0);
			_username.position = ccp(winSize.width/2, winSize.height/2+50);
			[self addChild:_username z:99];
			
			[LocalStorageManager bindUsernameDisplayLabel:_username];
			
			// Use Dispatcher to hide name screen!!!
			[[NSNotificationCenter defaultCenter]
			 addObserver:self
			 selector:@selector(updateScreenAfterUsersInput:)
			 name:@"usernameUpdate"
			 object:nil];
			
			// tell the localStorage manager to update the highscore after confirming the user name..
			[LocalStorageManager updateHighscoreAfterUsersInput:_score];
			
			// show keyboard
			[[[UIApplication sharedApplication] delegate] specifyUsername];
		}
		else
        {
			[LocalStorageManager addHighscore:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", [NSNumber numberWithInt:_score], @"score", nil]];
		}
	}
}

- (void) updateScore {
    if (_tmpScore < _score) {
        _tmpScore += _scoreCountStep;
    } else {
        _tmpScore = _score;
        [self unschedule:@selector(updateScore)];
        [_scoreLabel stopAllActions];
        [_scoreLabel runAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
    }

    [_scoreLabel setString:[NSString stringWithFormat:@"%i",_tmpScore]];
}


// remove namescreen do update.. 
- (void)updateScreenAfterUsersInput:(NSNotification*)note {
	// remove namescreen
	[_menu_namescreen runAction:[CCFadeOut actionWithDuration:0.5f]];
    [_menu_namescreen_title runAction:[CCFadeOut actionWithDuration:0.5f]];
	[_username runAction:[CCFadeOut actionWithDuration:0.5f]];
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(removeNameScreen)],nil]];
}
- (void)removeNameScreen {
	[self removeChild:_username cleanup:YES];
	_username = nil;
	[self removeChild:_menu_namescreen cleanup:YES];
	_menu_namescreen = nil;
}
- (void)restartGame {
	if (_menu_namescreen) {
		return;
	}
	[[CCDirector sharedDirector] replaceScene:[ReloadMainScene scene]];
}
- (void)mainMenuGame {
	if (_menu_namescreen) {
		return;
	}
    
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] replaceScene:[MainMenuScene animatedScene]];
}


// ---------FACEBOOK CONNECT --------
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self prepareFacebookWallPost];
}

- (void)facebookTapped:(id)sender
{        
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"])
    {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![facebook isSessionValid])
    {
        //NSArray *permissions = [[NSArray alloc] initWithObjects:
        //                        @"read_stream",
        //                        nil];
        //[facebook authorize:permissions];
        [facebook authorize:nil];
        //[permissions release];
    } 
    else
    {
        [self prepareFacebookWallPost];
    }
}

- (void) prepareFacebookWallPost
{
    // get username
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void) facebookWallPost
{    
    // image url 1-5
    //_awesomeLevel 1-5;
    
    // image url 1-5 -> _awesomeLevel 1-5;
    NSString *lvlString = @"cute";
    _awesomeLevel = 1;
    if (_score > 10000) {
        _awesomeLevel = 2;
        lvlString = @"cool";
    }
    if (_score > 20000) {
        _awesomeLevel = 3;
        lvlString = @"badaZz";
    }
    if (_score > 30000) {
        _awesomeLevel = 4;
        lvlString = @"awesome";
    }
    if (_score > 45000) {
        _awesomeLevel = 5;
        lvlString = @"legendary";
    }    
    
    // http://app.etite.ch/herbert/images/facebook_app_5.png?v.0.1
    NSString *icon = [NSString stringWithFormat:@"http://app.etite.ch/herbert/images/facebook_app_%i.png?v.0.1", _awesomeLevel];
    NSString *name = [NSString stringWithFormat:@"%@ reached %i points as Herbert. That was %@!", facebookUser, _score, lvlString];
    NSString *caption = [NSString stringWithFormat:@"%i points! Can you beat this?", _score];
    NSString *description = [NSString stringWithFormat:@"Get the app and more infos on app.etite.ch/herbert"];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kAppId, @"app_id",
                                   @"http://www.facebook.com/HerbertApp/", @"link",
                                   icon, @"picture",
                                   name, @"name",
                                   caption, @"caption",
                                   description, @"description",
                                   @"Tell the world:", @"message",
                                   nil];
    
    [facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (void)request:(FBRequest*)request didLoad:(id)result
{    
    facebookUser = @"I";
    if (result)
    {
        NSString *firstName = [result objectForKey:@"first_name"];
        NSString *lastName = [result objectForKey:@"last_name"];
        if (firstName && lastName)
        {
            facebookUser = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    
    [self facebookWallPost];
}

 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_menu_namescreen release];
    
    facebookUser = nil;
    [facebook release];
    
	[LocalStorageManager dealloc];
	[super dealloc];
}

@end