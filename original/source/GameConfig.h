//
//  GameConfig.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/5/11.
//  Copyright Etite 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//

// 3rd generation and newer devices: Rotate using UIViewController. Rotation should be supported on iPad apps.
// TIP:
// To improve the performance, you should set this value to "kGameAutorotationNone" or "kGameAutorotationCCDirector"
#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR
#define GAME_AUTOROTATION kGameAutorotationUIViewController

// ARMv6 (1st and 2nd generation devices): Don't rotate. It is very expensive
#elif __arm__
#define GAME_AUTOROTATION kGameAutorotationNone


// Ignore this value on Mac
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#else
#error(unknown architecture)
#endif


//
// Some Gamespecific Stuff
//
// 0: shitball, 1: mg, 2: laser, 3: minigun, 4: pumpgun, 5: rocket, 6: rainbowgun; 7: tabasco, 8: flygun, 9: übergun, 10: bugspray
#define GAME_INITIAL_WEAPON 0
#define GAME_INITIAL_AMMO 0
#define GAME_INITIAL_GAMESPEED 1.0
// item level (99 = all, at beginning), 1 = standard
#define GAME_INITIAL_ITEMLEVEL 1
#define GAME_INITIAL_DIFFICULTYLEVEL 0
#define GAME_INITIAL_GAMETIMESECONDS 0
#define GAME_INITIAL_POINTS 0
#define GAME_INITIAL_ITEMWEIGHT 0

#define GAME_INITIAL_HEALTH 300
#define GAME_MAX_HEALTH 300
#define GAME_MAX_DIFFICULTYLEVEL 20

#define NUM_ITEMS 3
#define NUM_WEAPONS 10

#define GAME_GAMELOGICINTERVAL 1.2f
#define GAME_DEBUGSCHWAENGLE 0
#define DISPLAY_DEBUGINFO 0
#define DISPLAY_DEBUGHITAREAS 0

#define DEFAULT_USERNAME @"Herbert"

#define URL_FACEBOOK @"http://m.facebook.com/pages/Herbert/216167655083370";
#define URL_ETITE @"http://etite.ch/?ref=herbert.app";
#define URL_JUSTIN @"http://www.nihilinteractive.com/";

#endif // __GAME_CONFIG_H