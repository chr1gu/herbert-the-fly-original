//
//  ReloadMainScene.mm
//  HerbertTheFly
//
//  Created by Christoph Ebert on 08/06/11.
//  Copyright 2010 Etite. All rights reserved.
//
#import "ReloadMainScene.h"
#import "HelloWorldScene.h"
#import "LocalStorageManager.h"


@implementation ReloadMainScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	
	ReloadMainScene *layer = [ReloadMainScene node];
	
	[scene addChild: layer];
	
	return scene;
}

- (id) init {
    
    if( (self=[super init] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"mm_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
		
        // show loading..
        CCSprite *loading = [CCSprite spriteWithSpriteFrameName:@"mm_loading.png"];
        loading.position = ccp(winSize.width-loading.contentSize.width/2, loading.contentSize.height/2-60);
        [loading runAction:[CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.3 position:ccp(loading.position.x, loading.position.y+60)]]];
        [self addChild:loading z:10];
        
        // replace scene with a small delay
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:0.3], 
                         [CCCallFuncN actionWithTarget:self selector:@selector(startGameScene)],
                         nil]];
		
	}	
	return self;
}

- (void) startGameScene
{
    [LocalStorageManager loadIngameAssets];
    [[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
}

- (void) dealloc
{
    //NSLog(@"[dealloc] ReloadMainScene");
    [super dealloc];
}

@end
