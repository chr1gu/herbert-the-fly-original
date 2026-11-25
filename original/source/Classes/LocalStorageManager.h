//
//  LocalStorageManager.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 1/15/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "cocos2d.h"

@interface LocalStorageManager : NSObject {

}

+ (int)inHighscore:(int)score;
+ (NSArray*)getHighscore;
+ (void) loadHighscore;
+ (void) addHighscore:(NSDictionary *)newEntry;
+ (void) resetSettings;
+ (void) updateHighscoreAfterUsersInput:(int)newScore;
+ (void) bindUsernameDisplayLabel:(id)sender;
+ (void) updateUserLabel:(NSString*)newString;
+ (void) updateUsername:(NSString*)newName;
+ (void) setLang:(NSString*)newLang;
+ (NSArray*) getUnlockedItems;
+ (void) setUnlockedItems:(NSArray *)items;
+ (void) setFirstStart;
+ (BOOL) isFirstStart;
+ (void) setSFX:(BOOL)enabled;
+ (void) setMusic:(BOOL)enabled;
+ (BOOL) isSFXEnabled;
+ (BOOL) isMusicEnabled;
+ (BOOL) isLangSet;
+ (void) loadIngameAssets;
+ (void) loadMenuAssets;
+ (void) unloadIngameAssets;
+ (void) unloadMenuAssets;
+ (NSString*) getLang;
+ (NSArray*) getAvailableLangs;
+ (NSString*) getUsername;

+ (void) alert:(NSString*)title:(NSString*)message;

+ (void) dealloc;

@end