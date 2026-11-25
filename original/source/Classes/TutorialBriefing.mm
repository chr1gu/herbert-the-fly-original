//
//  TutorialBriefing.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 6/3/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "TutorialBriefing.h"
#import "LocalStorageManager.h"
#import "MotionSprite.h"
#import "HelloWorldScene.h"

@implementation TutorialBriefing

+(id)initStep:(int)step:(id)delegate {
    
    TutorialBriefing *screen = nil;
    if ((screen = [[[super alloc] init] autorelease])) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"clct_tutorial.plist"];

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [screen setTextureRect:CGRectMake(0,0,winSize.width,winSize.height)];
        [screen setOpacity:0];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"tut_bg.png"];
        bg.opacity = 0;
        bg.position = ccp(winSize.width/2, winSize.height/2);
        [screen addChild:bg];
        
		CCSprite *herb = [CCSprite spriteWithSpriteFrameName:@"tut_herb.png"];
        herb.position = ccp(0, 0);
        [screen addChild:herb];
        
        [herb runAction: [CCSequence actions:
                          [CCEaseBackOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(herb.contentSize.width/2-10, herb.contentSize.height/2-13)]],
                          [CCCallFuncN actionWithTarget:screen selector:@selector(startBackgroundAnimations:)],
                               nil]];
        
        // Fade ins
        [bg runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
        
        if ([LocalStorageManager isMusicEnabled]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_gameover.caf" loop:YES];
        }
        
        switch (step) {
            case 1:
                [screen step2:delegate];
                break;
            case 2:
                [screen step3:delegate];
                break;
            case 3:
                [screen step4:delegate];
                break;
            case 4:
                [screen step5:delegate];
                break;
            default:
                [screen introScreen:delegate];
                break;
        }
        
    }
    return screen;
}

- (void) hide {
    [self.parent removeChild:self cleanup:YES];
}

- (void) addFacebook:(id)sender {
    NSString *url = URL_FACEBOOK;       
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

// Not used anymore..
//- (void) startNewGame:(id)sender {
//    [mainWindow gameRestart:self];
//}

- (void) startBackgroundAnimations:(id)sender {
    // anim logo
    id move = [CCMoveBy actionWithDuration:2 position:ccp(0,5)];
    id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
    id move_ease_back = [move_ease reverse];
    id seq1 = [CCSequence actions: move_ease, [CCDelayTime actionWithDuration:0.1f], move_ease_back, [CCDelayTime actionWithDuration:0.1f], nil];	
    [sender runAction: [CCRepeatForever actionWithAction:seq1]];
}

- (void) step5:(id)delegate {

    NSString *lang = [LocalStorageManager getLang];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mainWindow = delegate;
    
    NSString *labeltext = @"this was so much fun!\nok, I think we're ready\nto be friends on facebook...\n\nnot? come on, pleeease... You're\nlike my best friend ever!";
    NSString *labelStart = @"finish";
    NSString *labelAdd = @"add herbert now";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"das hat echt spass gemacht!\nich denke, wir sind nun\nbereit facebookfreunde zu sein...\n\nnicht? ach komm schon... du bist\nmein allerbester freund!";
        labelStart = @"beenden";
        labelAdd = @"freunde sein";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"ds isch ächt luschtig gsi!\ni dänke mir si itz bereit\nfacebookfründe z sii...\n\nniid? chum itz, biiitte.. du bisch\nmi auerbescht kolleg!";
        labelStart = @"beändä";
        labelAdd = @"fründe sii";
    }
    
    // text
    txt = [CCLabelTTF labelWithString:labeltext dimensions:CGSizeMake(350,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    txt.color = ccc3(0,0,0);
    txt.opacity = 0;
    txt.position = ccp(winSize.width/2, winSize.height/2-8);
    [self addChild:txt]; 
    
    // new game special multiline string..
    CCLabelTTF *labelFull = [CCLabelTTF labelWithString:labelStart dimensions:CGSizeMake(200,80) alignment:CCTextAlignmentCenter fontName:@"akaDylan Plain" fontSize:24];
    labelFull.color = ccc3(57, 154, 85);
    SFXMenuItemFont *startGame = [SFXMenuItemFont itemWithLabel:labelFull target:delegate selector:@selector(gameMainMenu:)];
    
    CCLabelTTF *labelFB = [CCLabelTTF labelWithString:labelAdd dimensions:CGSizeMake(200,40) alignment:CCTextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    labelFB.color = ccc3(55,88, 154);
    SFXMenuItemFont *fbadd = [SFXMenuItemFont itemWithLabel:labelFB target:self selector:@selector(addFacebook:)];
    
    // menu
    CCMenu *menu = [CCMenu menuWithItems:startGame,fbadd, nil];
    startGame.position = ccp(0, -138);
    startGame.opacity = 0;
    fbadd.opacity = 0;
    fbadd.position = ccp(0, -50);
    [self addChild:menu];
    
    // header
    header = [CCSprite spriteWithSpriteFrameName:@"tut_5.png"];
    header.position = ccp(winSize.width/2, 290);
    header.opacity = 0;
    [self addChild:header];
    
    // fade in's
    [startGame runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCFadeIn actionWithDuration:0.3],
                     nil]];
    [txt runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    [fbadd runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    [header runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
}
- (void) initTut4 {
    [mainWindow tut4:self];
}
- (void) step4:(id)delegate {

    NSString *lang = [LocalStorageManager getLang];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mainWindow = delegate;
    
    NSString *labeltext = @"haha, who's the boss now?!\n\njust try some weapons and\nhave fun. when taping doesn't work\nyou may try to hold.\n\nif you want to get\nrid of any gun,\njust tap on my\nshoulders, okay?";
    NSString *labelok = @"okey!";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"haha, wer hat nun das sagen?!\n\nkomm wir haben noch ein\nbisschen spass mit den waffen!\nprobier anstatt tippen auch\nmal gedrückt zu halten.\nwenn ich eine waffe\nwegschmeissen soll, tipp\nmir auf die schulter,\nokey?";
        labelok = @"okey!";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"haha, wär het itz dr grösser?!\n\nchum mir teschtä no paar meh!\nanstatt tippe chasch o mau drückt\nbhaute u luege was passiert.\n\nu weni e knarre söu\nla gheie, tipp mr eifach\nufd schultere, okey?";
        labelok = @"okey!";
    }
    
    // text
    txt = [CCLabelTTF labelWithString:labeltext dimensions:CGSizeMake(340,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    txt.color = ccc3(0,0,0);
    txt.opacity = 0;
    txt.position = ccp(winSize.width/2, winSize.height/2-8);
    [self addChild:txt]; 
    
    // menu
    next = [SFXMenuItemFont itemFromString:labelok target: self selector:@selector(initTut4)];
    next.color = ccc3(57, 154, 85);
    next.opacity = 0;
    next.position = ccp(0, -116);
    CCMenu *menu = [CCMenu menuWithItems:next, nil];
    [self addChild:menu];
    
    // header
    header = [CCSprite spriteWithSpriteFrameName:@"tut_4.png"];
    header.position = ccp(winSize.width/2, 290);
    header.opacity = 0;
    [self addChild:header];
    
    // fade in's
    [next runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCFadeIn actionWithDuration:0.3],
                     nil]];
    [txt runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    [header runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
}
- (void) initTut3 {
    [mainWindow tut3:self];
}
- (void) step3:(id)delegate {

    NSString *lang = [LocalStorageManager getLang];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mainWindow = delegate;
    
    NSString *labeltext = @"we're a good team!\ni try to avoid the birds\nespecially since my wife left\nme for one of them..\n\n\n\n\nbtw. what are you\ndoing on friday?";
    NSString *labelstart = @"start!";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"wir sind ein super team!\nseit meine frau mit einem vogel\ndurchgebrannt ist, geh ich\ndiesen mistviechern ausm weg...\n\n\n\n\nübrigens, am frei-\ntag schon was vor?";
        labelstart = @"start!";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"mir si es supr team!\ni ga dä vögu usmwäg, bsunders\nsit däm mini frou dürebrönnt\nisch mit somne mischtviech...\n\n\n\n\nach ja, was machsch\nam friti so?";
        labelstart = @"start!";
    }
    
    // text
    txt = [CCLabelTTF labelWithString:labeltext dimensions:CGSizeMake(300,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    txt.color = ccc3(0,0,0);
    txt.opacity = 0;
    txt.position = ccp(winSize.width/2, winSize.height/2-12);
    [self addChild:txt]; 
    
    // ani
    MotionSprite *ani = [MotionSprite motionWithSpriteSheet:@"clct_tutorial" framename:@"tutorial3_" numframes:4 delay:0.6];
    [ani setOpacity:0];
    ani.position = ccp(winSize.width/2,winSize.height/2-20);
    [ani play:NO repeat:YES];
    [self addChild:ani];
    
    [ani runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    
    // menu
    next = [SFXMenuItemFont itemFromString:labelstart target: self selector:@selector(initTut3)];
    next.color = ccc3(57, 154, 85);
    next.opacity = 0;
    next.position = ccp(0, -116);
    CCMenu *menu = [CCMenu menuWithItems:next, nil];
    [self addChild:menu];
    
    // header
    header = [CCSprite spriteWithSpriteFrameName:@"tut_3.png"];
    header.position = ccp(winSize.width/2, 290);
    header.opacity = 0;
    [self addChild:header];
    
    // fade in's
    [next runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCFadeIn actionWithDuration:0.3],
                     nil]];
    [txt runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    [header runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
}

- (void) initTut2 {
    [mainWindow tut2:self];
}
- (void) step2:(id)delegate {

    NSString *lang = [LocalStorageManager getLang];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mainWindow = delegate;
    
    NSString *labeltext = @"that was nice!\nnow let's try this: tap\non the screen and i will shoot\nexactly in this direction\n\n\n\n\n\nlet's hit 5 targets!";
    NSString *labelstart = @"start!";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"das war toll!\njetzt versuchen wir mal das:\ntippe auf den Bildschirm und\nich schiesse genau dort hin.\n\n\n\n\n\ntriff 5 ziele!";
        labelstart = @"start!";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"ds isch geil gsi!\nok probiere mr ds: tipp ufe\nbiudschirm u ig schiessä\nnär gnau i die richtig.\n\n\n\n\n\ntriff 5 ziiu!";
        labelstart = @"start!";
    }
    
    // text
    txt = [CCLabelTTF labelWithString:labeltext dimensions:CGSizeMake(300,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    txt.color = ccc3(0,0,0);
    txt.opacity = 0;
    txt.position = ccp(winSize.width/2, winSize.height/2-8);
    [self addChild:txt]; 
    
    // ani
    MotionSprite *ani = [MotionSprite motionWithSpriteSheet:@"clct_tutorial" framename:@"tutorial2_" numframes:4 delay:0.6];
    [ani setOpacity:0];
    ani.position = ccp(winSize.width/2,winSize.height/2-20);
    [ani play:NO repeat:YES];
    [self addChild:ani];
    
    [ani runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    
    // menu
    next = [SFXMenuItemFont itemFromString:labelstart target: self selector:@selector(initTut2)];
    next.color = ccc3(57, 154, 85);
    next.opacity = 0;
    next.position = ccp(0, -116);
    CCMenu *menu = [CCMenu menuWithItems:next, nil];
    [self addChild:menu];
    
    // header
    header = [CCSprite spriteWithSpriteFrameName:@"tut_2.png"];
    header.position = ccp(winSize.width/2, 290);
    header.opacity = 0;
    [self addChild:header];
    
    // fade in's
    [next runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCFadeIn actionWithDuration:0.3],
                     nil]];
    [txt runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.5],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    [header runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
}
- (void) step1LabelUpdate {
    
    NSString *lang = [LocalStorageManager getLang];
    NSString *labeltext = @"when you tilt your machine\nI fly up and down. this must\nhave something to do with\ngravity... whatever.\n\n\n\n\n\nlet's collect 5 rings!";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"Wenn du dein gerät neigst,\nfliege ich hoch und runter.\nDas wird wohl irgendwas mit\n der Schwerkraft zu tun haben.\n\n\n\n\n\nSammle 5 Ringe!";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"wed z grät neigsch, de\nflügeni ufe u abe. I weis o nid\ngnau werum aber es het äuä\nöpis mit dr schwärchraft ztüe.\n\n\n\n\n\nSamle 5 Ringe!";
    }
    
    [txt setString:labeltext];
    step = 1;
}
- (void) step1 {
    
    // the 2nd time you press next button.. start tutorial.
    if(step==1) {
        [mainWindow tut1:self];
        return;
    }
    
    NSString *lang = [LocalStorageManager getLang];
    NSString *labelstart = @"start!";
    if ([lang isEqualToString:@"de"]) {
        labelstart = @"start!";
    }
    if ([lang isEqualToString:@"ch"]) {
        labelstart = @"start!";
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [txt runAction:[CCSequence actions:
                    [CCFadeOut actionWithDuration:0.3],
                    [CCCallFuncN actionWithTarget:self selector:@selector(step1LabelUpdate)],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    
    // update header..
    [self removeChild:header cleanup:YES];
    header = [CCSprite spriteWithSpriteFrameName:@"tut_1.png"];
    header.position = ccp(winSize.width/2, 290);
    [self addChild:header];
    
    
    MotionSprite *ani = [MotionSprite motionWithSpriteSheet:@"clct_tutorial" framename:@"tutorial1_" numframes:4 delay:0.6];
    [ani setOpacity:0];
    ani.position = ccp(winSize.width/2,winSize.height/2-20);
    [ani play:NO repeat:YES];
    [self addChild:ani];
    
    [ani runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:0.3],
                    [CCFadeIn actionWithDuration:0.3],
                    nil]];
    
    [next setString:labelstart];
    [next setColor:ccc3(82, 153, 56)];
}

- (void) introScreen:(id)delegate {
    
    NSString *lang = [LocalStorageManager getLang];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mainWindow = delegate;
    step = 0;
    
    NSString *labeltext = @"hey, nice to meet you!\ni'm herbert, but just call\nme herb.\n\nSomehow you have control over\nme. so i would like to show\nyou some stuff i've\nalready figured\nout...";
    NSString *labelNext = @"next";
    
    if ([lang isEqualToString:@"de"]) {
        labeltext = @"hey, nett dich kennen zu\nlernen! ich bin Herbert, aber\nnenn mich ruhig herb.\n\nirgendwie hast du die kontrolle\nüber mich erlangt, darum\nwürde ich dir gerne\nein paar sachen zeigen\ndie ich kann...";
        labelNext = @"weiter";
    }
    if ([lang isEqualToString:@"ch"]) {
        labeltext = @"Sälü du, fröit mi di\nkenne z'lehre. I bi dr Herbert,\nabr für di süsch eifach Herb.\n\ndu hesch's irgendwie gschafft\nd kontroue über mi z erlange.\ndrum zeigi dr am\nbeschte mau wasi so\ndruf ha...";
        labelNext = @"wiiter";
    }
    
    // text
    txt = [CCLabelTTF labelWithString:labeltext dimensions:CGSizeMake(300,200) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
    txt.color = ccc3(0,0,0);
    txt.opacity = 0;
    txt.position = ccp(winSize.width/2, winSize.height/2-8);
    [self addChild:txt]; 
    
    // menu
    next = [SFXMenuItemFont itemFromString:labelNext target: self selector:@selector(step1)];
    next.color = ccc3(0,0,0);
    next.opacity = 0;
    next.position = ccp(0, -116);
    CCMenu *menu = [CCMenu menuWithItems:next, nil];
    [self addChild:menu];
    
    // header
    header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"tut_title_%@.png",lang]];
    header.position = ccp(winSize.width/2, 290);
    header.opacity = 0;
    [self addChild:header];
    
    // fade in's
    [next runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:0.5],
                         [CCFadeIn actionWithDuration:0.3],
                         nil]];
    [txt runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCFadeIn actionWithDuration:0.3],
                     nil]];
    [header runAction:[CCSequence actions:
                       [CCDelayTime actionWithDuration:0.3],
                       [CCFadeIn actionWithDuration:0.3],
                       nil]];
}


- (void) dealloc
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"clct_tutorial.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"clct_tutorial.png"];
    
    //NSLog(@"[dealloc] TutorialBriefing");
    [super dealloc];
}

@end
