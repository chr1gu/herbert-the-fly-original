//
//  LocalStorageManager.mm
//  HerbertTheFly
//
//  Created by Christoph Ebert on 1/15/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "LocalStorageManager.h"
#import "GameConfig.h"

@implementation LocalStorageManager

static NSMutableArray *highscore = nil;
static NSString *username = nil;
static CCLabelTTF *usernameLabel = nil;
static int tempScore = 0;

static bool menuAssetsLoaded = NO;
static bool ingameAssetsLoaded = NO;

+ (NSArray*)getHighscore {
	// Always perform a load highscore then it can't load something cached..
	[self loadHighscore];	
	return highscore;
}

+ (void) loadHighscore {
	// load highscore list if allready existing..
	//NSArray *dblist = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"]) {
		NSArray *emptyList = [NSArray arrayWithObjects:
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_USERNAME, @"name", [NSNumber numberWithInt:0], @"score", nil],
					   nil];
		
		[[NSUserDefaults standardUserDefaults] setObject:emptyList forKey:@"highscore"];
		[[NSUserDefaults standardUserDefaults] synchronize];
        highscore = [emptyList mutableCopy];
	}
	else {
		// create a mutable copy of the array in oder to change..
		highscore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"] mutableCopy];
	}
}

/* This function checks if the current score can go into the highscore
   if yes, return the id which needs to be pushed out.. else return -1 */
+ (int)inHighscore:(int)newScore {
	
	if (!highscore) {
		[self loadHighscore];
        return [self inHighscore:newScore];
	}
	
	int numEntries = [highscore count];
	for (int i=0; i<numEntries; i++) {
		NSDictionary *entry = [highscore objectAtIndex:i];
		int score = [[entry objectForKey:@"score"] intValue];
		if (newScore>score) {
			return i;
		}
	}
	
	return -1;
}

+ (void) addHighscore: (NSDictionary *) newEntry {

	if (!highscore) {
		[self loadHighscore];
	}
	
	int newScore = [[newEntry objectForKey:@"score"] intValue];
	int newId = [self inHighscore:newScore];
	if (newId != -1) {
		
		int numEntries = [highscore count];
		[highscore insertObject:newEntry atIndex:newId];
		[highscore removeObjectAtIndex:numEntries];
		
		// save..
		[[NSUserDefaults standardUserDefaults] setObject:highscore forKey:@"highscore"];
		[[NSUserDefaults standardUserDefaults] synchronize];	
	}
}

// specify a label which will be updated after keyboard input
+ (void) bindUsernameDisplayLabel:(id)sender {
	usernameLabel = sender;
}

// update the highscore after user has specified a name..
+ (void) updateHighscoreAfterUsersInput:(int)newScore {
	tempScore = newScore;
}

// update display label if existing..
+ (void) updateUserLabel:(NSString*)newString {
	if (usernameLabel) {
		[usernameLabel setString:newString];
	}
}

// change username in the db and the view's label if there is one set..
// if there is a tempScore update as well the highscore table!
+ (void) updateUsername:(NSString*)newName {
	
	// change value in storage..
	[[NSUserDefaults standardUserDefaults] setObject:newName forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// dispatch event for view..
	[[NSNotificationCenter defaultCenter] postNotificationName:@"usernameUpdate" object:self];
	
	// update display label if set..
	if (usernameLabel) {
		[usernameLabel setString:newName];
	}
	
	if (tempScore != 0) {
		// empty cached highscore results..
		highscore = nil;
		// add new entry..
		[self addHighscore:[NSDictionary dictionaryWithObjectsAndKeys:newName, @"name", [NSNumber numberWithInt:tempScore], @"score", nil]];
		// reset tempScore
		tempScore = 0;
	}
}

+ (NSArray*) getUnlockedItems
{
    NSArray *items = [[NSUserDefaults standardUserDefaults] valueForKey:@"unlockeditems"];
	if (!items)
    {
        // initial items..
        if (GAME_INITIAL_ITEMLEVEL >= 99) {
            items = [NSArray arrayWithObjects:
                     @"LsdStar",
                     @"ProtectSuit",
                     @"Capushito",
                     @"TabascoShot",
                     @"FlyGun",
                     @"BugSpray",
                     @"Kalaschnikov",
                     @"PumpGun",
                     @"LaserGun",
                     @"MiniGun",
                     @"RainbowGun",
                     @"RocketLauncher",
                     @"UberGun",
                     nil]; 
        } else {
            items = [NSArray arrayWithObjects:
                     @"LsdStar",
                     @"ProtectSuit",
                     @"Capushito",
                     nil]; 
        }
	}

    return items;
}
+ (void) setUnlockedItems:(NSArray *)items
{
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:@"unlockeditems"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"firststart"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"unlockeditems"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"highscore"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setFirstStart
{
    //NSLog(@"set first start!");
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"firststart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL) isFirstStart
{
    NSString *first = [[NSUserDefaults standardUserDefaults] valueForKey:@"firststart"];
    //NSLog(@"get %@", first);
	if (!first) {
        return YES;
	}
	return NO;
}

+ (void) setLang:(NSString *)newLang {
    [[NSUserDefaults standardUserDefaults] setObject:newLang forKey:@"lang"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) isLangSet {
	NSString *lang = [[NSUserDefaults standardUserDefaults] valueForKey:@"lang"];
	if (!lang) {
        return NO;
	}
	return YES;
}
+ (NSString*) getLang {
	NSString *lang = [[NSUserDefaults standardUserDefaults] valueForKey:@"lang"];
	if (!lang) {
        // default lang
        NSDictionary *entry = [[LocalStorageManager getAvailableLangs] objectAtIndex:0];
		lang = [entry objectForKey:@"code"];
	}
	return lang;
}
+ (NSArray*) getAvailableLangs {
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"en", @"code", @"english", @"desc", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"de", @"code", @"deutsch", @"desc", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"ch", @"code", @"bärndütsch", @"desc", nil],
            nil];
}

// return current username..
+ (NSString*) getUsername {
	
	NSString *dbuser = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
	if (!dbuser) {
		username = DEFAULT_USERNAME;
	} else {
		username = dbuser;
	}
	return username;
}


+ (void) setSFX:(BOOL)enabled {
    NSString *val = @"YES";
    if (!enabled) {
        val = @"NO";
    }
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:@"sfx_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) setMusic:(BOOL)enabled {
    NSString *val = @"YES";
    if (!enabled) {
        val = @"NO";
    }
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:@"music_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL) isSFXEnabled {
    NSString *sfx = [[NSUserDefaults standardUserDefaults] valueForKey:@"sfx_enabled"];
	if (!sfx || [sfx isEqualToString:@"YES"]) {
		return YES;
	}
    return NO;
}
+ (BOOL) isMusicEnabled {
    NSString *music = [[NSUserDefaults standardUserDefaults] valueForKey:@"music_enabled"];
	if (!music || [music isEqualToString:@"YES"]) {
		return YES;
	}
    return NO;
}

+ (void) alert:(NSString*)title:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"OK"];
    //[alert addButtonWithTitle:@"Cancel"];
    [alert show];
    [alert release];
}

+ (void) loadIngameAssets
{
    if (ingameAssetsLoaded) {
        return;
    }
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [cache addSpriteFramesWithFile:@"clct_ingame.plist"];
    [cache addSpriteFramesWithFile:@"clct_bugsgads.plist"];
    [cache addSpriteFramesWithFile:@"clct_herbert.plist"];
    
    [[CCTextureCache sharedTextureCache] addImage:@"drugmode.png"];
    
    ingameAssetsLoaded = YES;
    //NSLog(@"load ingame assets..");
}

+ (void) loadMenuAssets
{
    if (menuAssetsLoaded) {
        return;
    }
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [cache addSpriteFramesWithFile:@"clct_mm.plist"];
    menuAssetsLoaded = YES;
}

+ (void) unloadIngameAssets
{
    if (!ingameAssetsLoaded) {
        return;
    }
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCTextureCache *tcache = [CCTextureCache sharedTextureCache];
    
    [cache removeSpriteFramesFromFile:@"clct_ingame.plist"];
    [cache removeSpriteFramesFromFile:@"clct_bugsgads.plist"];
    [cache removeSpriteFramesFromFile:@"clct_herbert.plist"];
    [tcache removeTextureForKey:@"clct_ingame.png"];
    [tcache removeTextureForKey:@"clct_bugsgads.png"];
    [tcache removeTextureForKey:@"clct_herbert.png"];
    [tcache removeTextureForKey:@"drugmode.png"];
    ingameAssetsLoaded = NO;
}

+ (void) unloadMenuAssets
{
    if (!menuAssetsLoaded) {
        return;
    }
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [cache removeSpriteFramesFromFile:@"clct_mm.plist"];
    
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"clct_mm.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mm_bg.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"menu_namescreen.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mm_credits_bg.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mm_gameover_bg.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mm_sponsor_bg.png"];
    menuAssetsLoaded = NO;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*if (buttonIndex == 0)
    {
        // Yes
    }
    else if (buttonIndex == 1)
    {
        // No
    }*/
}

// this dealloc method is kinda special because its a class method and we have to call it manually
// and release just objects which can break the app if they are in memory after changing a scene..
+ (void) dealloc
{
	usernameLabel = nil;
    highscore = nil;
    username = nil;
    usernameLabel = nil;
    tempScore = 0;
    menuAssetsLoaded = NO;
    ingameAssetsLoaded = NO;
    
	// right there is no [super dealloc] method
	// because that one is static!
}
@end