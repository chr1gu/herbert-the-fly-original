//
//  GameOverScene.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/29/10.
//  Copyright 2010 Etite. All rights reserved.
//
#import "FBConnect.h"
#import "cocos2d.h"

@interface GameOverLayer : CCLayer <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
	int _projectilesDestroyed;
	int _score;
	int _gametime;
    int _tmpScore;
    int _scoreCountStep;
    int _awesomeLevel;
	CCSprite *_menu_namescreen;
    CCSprite *_menu_namescreen_title;
	CCLabelTTF *_username;
    CCLabelTTF *_scoreLabel;
}
@property (nonatomic, assign) int projectilesDestroyed;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int gametime;

- (void)updateScore;
- (void)facebookWallPost;
- (void)prepareFacebookWallPost;

// facebook
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSString *facebookUser;

@end

@interface GameOverScene : CCScene {
	GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end