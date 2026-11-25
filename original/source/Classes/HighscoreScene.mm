//
//  MainMenuScene.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/22/10.
//  Copyright 2010 Etite. All rights reserved.
//
#import "MainMenuScene.h"
#import "HighscoreScene.h"
#import "CCSprite.h"
#import "CustomTransitions.h"
#import "LocalStorageManager.h"
#import "Particles.h"
#import "SFXMenuItemImage.h"

@implementation HighscoreScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	
	HighscoreScene *layer = [HighscoreScene node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		NSString *lang = [LocalStorageManager getLang];
        
		CCSprite *background = [CCSprite spriteWithFile:@"mm_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
        
        CCSprite *_cloudlb = [CCSprite spriteWithSpriteFrameName:@"mm_highscore_cloud_left.png"];
		[_cloudlb setPosition:ccp(_cloudlb.contentSize.width/2, _cloudlb.contentSize.height/2)];
		[self addChild:_cloudlb z:10];
        
        CCSprite *_cloudrt = [CCSprite spriteWithSpriteFrameName:@"mm_highscore_cloud.png"];
		[_cloudrt setPosition:ccp(winSize.width-_cloudrt.contentSize.width/2, winSize.height-_cloudrt.contentSize.height/2)];
		[self addChild:_cloudrt z:10];
        
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_highscore_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 280)];
		[self addChild:_header z:10];
		
		SFXMenuItemImage *mainmenu = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_back_hover_%@.png",lang]] target:self selector:@selector(mainMenu:)];
		
		CCMenu *menu = [CCMenu menuWithItems:mainmenu, nil];
		[menu alignItemsVertically];
		
		[self addChild: menu z:10];
		mainmenu.position = ccp(winSize.width/2-mainmenu.contentSize.width/2, -winSize.height/2+mainmenu.contentSize.height/2);
		
		// CREATE HIGHSCORE LIST
		NSMutableString* placeText = [NSMutableString string];
		NSMutableString* scoreText = [NSMutableString string];
		NSMutableString* nameText = [NSMutableString string];
		//
		NSArray *highscoredata = [LocalStorageManager getHighscore];
		int numScores = [highscoredata count];
		for (int i=0; i<numScores; i++) {
			NSDictionary *entry = [highscoredata objectAtIndex:i];
			int score = [[entry objectForKey:@"score"] intValue];
			// cut name if he's to long..
			NSString* name = [entry valueForKey:@"name"];
			if ([name length]>10) {
				name = [name substringToIndex:10];
			}
			// append strings
			[scoreText appendString:[NSString stringWithFormat:@"%i\n",score]];
			[placeText appendString:[NSString stringWithFormat:@"%i.\n",(i+1)]];
			[nameText appendString:[NSString stringWithFormat:@"%@\n",name]];
		}
		
		// place
		CCLabelTTF *placelist = [CCLabelTTF labelWithString:placeText dimensions:CGSizeMake(30,200) alignment:UITextAlignmentLeft fontName:@"akaDylan Plain" fontSize:13];
		placelist.color = ccc3(0,0,0);
		placelist.position = ccp(130, 140);
		[self addChild:placelist z:10];
		
		// name
		CCLabelTTF *namelist = [CCLabelTTF labelWithString:nameText dimensions:CGSizeMake(120,200) alignment:UITextAlignmentLeft fontName:@"akaDylan Plain" fontSize:13];
		namelist.color = ccc3(0,0,0);
		namelist.position = ccp(210, 140);
		[self addChild:namelist z:10];
		
		// score
		CCLabelTTF *scorelist = [CCLabelTTF labelWithString:scoreText dimensions:CGSizeMake(120,200) alignment:UITextAlignmentRight fontName:@"akaDylan Plain" fontSize:13];
		scorelist.color = ccc3(0,0,0);
		scorelist.position = ccp(300, 140);
		[self addChild:scorelist z:10];
        
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

- (void) mainMenu: (id) sender 
{
	[[CCDirector sharedDirector] replaceScene:
	[MyCCSlideInLTransition transitionWithDuration:1.0f scene:[MainMenuScene node]]];
}

- (void) dealloc
{	
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end