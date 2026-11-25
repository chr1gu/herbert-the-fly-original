//
//  SponsorOverlay.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 7/13/11.
//  Copyright 2011 ETITE. All rights reserved.
//  THIS CLASS IS YET NOT USED BUT WILL BE ADDED WITH AN UPDATE
//  ONCE WE HAVE ADDED INAPP PURCHASES
//
/*
#import "SponsorOverlay.h"
#import "GameConfig.h"
#import "LocalStorageManager.h"
#import "StoreKitObserver.h"

@implementation SponsorOverlay


+(id) scene
{
	CCScene *scene = [CCScene node];
	
	SponsorOverlay *layer = [SponsorOverlay node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
    
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        NSString *lang = [LocalStorageManager getLang];
        
        NSString *desc = @"we're two indie developper who love coffee\nas much as herb does. help us stay awake to\nmake more great apps for you!\nsleep is for wussies anyway...";
        
        if ([lang isEqualToString:@"de"]) {
            desc = @"wir sind zwei indie entwickler die kaffee\ngenau so lieben wie herbert. halte uns wach,\ndamit wir mehr tolle app’s für dich machen\nkönnen. wer braucht denn schon schlaf...?";
        }
        if ([lang isEqualToString:@"ch"]) {
            desc = @"mir si zwöi jungi schwizer entwickler u liebe\nkafi genau so fescht wi dr herb. dürnes\nkafi-sponsoring hiufsch du üs wach z blibe u\nmir chöi witeri app’s für di mache.";
        }
		
		CCSprite *background = [CCSprite spriteWithFile:@"mm_sponsor_bg.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
        
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_title_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 290)];
		[self addChild:_header];
		
		[CCMenuItemFont setFontSize:26];
		[CCMenuItemFont setFontName: @"akaDylan Plain"];
        
        CCLabelTTF *descLabel = [CCLabelTTF labelWithString:desc dimensions:CGSizeMake(440,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:14];
		descLabel.color = ccc3(0,0,0);
		descLabel.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:descLabel];
        
        small = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_co1_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_sponsor_co1_ro.png"] target:self selector:@selector(smallTap:)];
        medium = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_co2_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_sponsor_co2_ro.png"] target:self selector:@selector(mediumTap:)];
        grande = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_co3_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_sponsor_co3_ro.png"] target:self selector:@selector(grandeTap:)];
        
        CCSprite *herb = [CCSprite spriteWithSpriteFrameName:@"mm_sponsor_herb.png"];
		[herb setPosition:ccp(83, 52)];
		[self addChild:herb];
        
        id move = [CCMoveBy actionWithDuration:2 position:ccp(0,5)];
        id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
        id move_ease_back = [move_ease reverse];
        id seq1 = [CCSequence actions: move_ease, [CCDelayTime actionWithDuration:0.1f], move_ease_back, [CCDelayTime actionWithDuration:0.1f], nil];	
        [herb runAction: [CCRepeatForever actionWithAction:seq1]];
        
		SFXMenuItemImage *mainmenu = [SFXMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_exit_%@.png",lang]] selectedSprite:[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_sponsor_exit_%@.png",lang]] target:self selector:@selector(close:)];
		CCMenu *menu = [CCMenu menuWithItems:small,medium,grande,mainmenu, nil];
		[menu alignItemsVertically];
		
		[self addChild: menu];
		mainmenu.position = ccp(winSize.width/2-mainmenu.contentSize.width/2, -winSize.height/2+mainmenu.contentSize.height/2);
        small.position = ccp(-90, -26);
        medium.position = ccp(95, -26);
        grande.position = ccp(0, -100);
        
        // init Storekit
        StoreKitObserver *observer = [[StoreKitObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
        //[self requestProductData];
	}
	return self;
}

- (void) close: (id) sender 
{
    if (loadingView) {
        [loadingView removeView];
        loadingView = nil;
    }
    
    [[CCDirector sharedDirector] popScene];
}

- (void) smallTap: (id) sender
{
    [self purchase:@"SPONSOR001"];
    //[self requestProductData];
}

- (void) mediumTap: (id) sender 
{
    [self purchase:@"SPONSOR001"];
    //[self requestProductData];
}

- (void) grandeTap: (id) sender 
{
    [self purchase:@"SPONSOR001"];
    //[self requestProductData];
}

- (void) checkTransactionStatus
{
    if ([[[SKPaymentQueue defaultQueue] transactions] count]<=0) {
        
        [small setIsEnabled:YES];
        [medium setIsEnabled:YES];
        [grande setIsEnabled:YES];
        
        if (loadingView) {
            [loadingView removeView];
            loadingView = nil;
        }
        
        [self unschedule:@selector(checkTransactionStatus)];
        [[CCDirector sharedDirector] popScene];
    }
}

- (void) purchase:(NSString *)identifier
{
    if ([SKPaymentQueue canMakePayments])
    {
        // only one transaction at once..
        if (!loadingView) {
            SKPayment *payment = [SKPayment paymentWithProductIdentifier:identifier];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
            UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            loadingView = [LoadingView loadingViewInView:[window.subviews objectAtIndex:0]];
            
            [self schedule:@selector(checkTransactionStatus) interval:0.5];
            [small setIsEnabled:NO];
            [medium setIsEnabled:NO];
            [grande setIsEnabled:NO];
        }
    }
    else
    {
        [LocalStorageManager alert:@"Error":@"InApp purchases are not enabled"];
    }
}

// fetch products..
- (void) requestProductData
{
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request= [[SKProductsRequest alloc] 
                                     initWithProductIdentifiers: [NSSet setWithObject: @"SPONSOR001"]];
        request.delegate = self;
        [request start];
    }
    else
    {
        [LocalStorageManager alert:@"Error":@"InApp purchases are not enabled"];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse: (SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
    //NSLog(@"%@", myProduct);
    // populate UI
    [request autorelease];
}


- (void) dealloc
{	
	[super dealloc];
}
@end*/
