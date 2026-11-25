//
//  HelloWorldLayer.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 10/28/10.
//  Copyright Etite 2010. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "MainMenuScene.h"
#import "Cloud.h"
#import "CCMaskTo.h"
#import "Particles.h"
#import "DeathAni.h"
#import "OptionScene.h"
#import "LocalStorageManager.h"
#import "SponsorOverlay.h"
#import "ParticleEffects.h"
#import "ReloadMainScene.h"

#define PTM_RATIO 32.0

// HelloWorld implementation
@implementation HelloWorld

/*- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 if (buttonIndex != 0) {
 // confirm..
 ////        [layer initGameTutorial];
 } else {
 ////        [layer initGameStartCountdown];
 }
 }*/

enum {
    kRemoveObjectTag = 99,
    kDrugRainbowTag = 7,
    kParticleTag = 8,
};

+(id) scene
{
    CCScene *scene = [CCScene node];
    
	HelloWorld *layer = [HelloWorld node];
    
	[scene addChild: layer];
    
    // start normal game..
    [layer initGameStartCountdown];
    
    // first gamestart done!
    [LocalStorageManager unloadMenuAssets];
    [LocalStorageManager setFirstStart];
    
    // ask if you wanna start with the tutorial!
    /*UIView* view = [[CCDirector sharedDirector] openGLView];
     UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle: @"Tutorial" message: @"First time playing this game?" delegate: self cancelButtonTitle: @"No!" otherButtonTitles: @"Jup", nil];
     [view addSubview: myAlertView];
     [myAlertView show];
     [myAlertView release];*/
    
	// return the scene
	return scene;
}

+(id) tutorialMode
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	HelloWorld *layer = [HelloWorld node];
    
	[scene addChild: layer];
    
    // start tutorial game..
    [LocalStorageManager unloadMenuAssets];
    [layer initGameTutorial];
	
	// return the scene
	return scene;
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
} 

-(void) scheduleFlashMessage: (id)node msgType:(int)msgType
{
	[self flashMessage:msgType];
}

-(void) flashMessage: (int) msgType {
    
	// if there is allready a flash sprite show this one with a small delay..
	if (_flashSprite) {
		id t = (id)msgType;
		[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallFuncND actionWithTarget:self selector:@selector(scheduleFlashMessage:msgType:) data:t],nil]];
		return;
	}
    
    NSString *lang = [LocalStorageManager getLang];
	
	// distinguish message types..
	switch (msgType) {
		case 0:
			_flashSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"msg_speed_%@.png",lang]];
			break;
		case 1:
			_flashSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"msg_wpn_%@.png",lang]];
			break;
		default:
			break;
	}
	
	if (_flashSprite != nil) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		_flashSprite.position = ccp(winSize.width/2, winSize.height/2);
		_flashSprite.tag = 10;
		_flashSprite.scale = 0.8;
		[_flashSprite runAction:[CCSequence actions:
                                 [CCScaleTo actionWithDuration:0.4f scale:1.2f],
                                 [CCScaleTo actionWithDuration:0.3f scale:1.0],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
		[self addChild:_flashSprite z:47];	
	}
}

-(void) updateAmmoBar
{	
	NSString *str = [NSString stringWithFormat:@"%d",_wheaponAmmo];
	if (_wheaponType != 0) {
		[_ammoBar setString:str];
	}
	else {
		[_ammoBar setString:@""];
	}
}

-(void) changeWeaponAmmo: (int)weaponType {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (_tutorialMode) {
        return;
    }
    
    if (_ammoLabel) {
        [self removeChild:_ammoLabel cleanup:YES];
    }
	
	switch (weaponType) {
		case 0:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_gagi.png"];
			break;
		case 1:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_kalaschnikov.png"];
			break;
		case 2:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_laser.png"];
			break;
		case 3:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_minigun.png"];
			break;
		case 4:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_pumpgun.png"];
			break;
		case 5:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_rocket.png"];
			break;
		case 6:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_rainbow.png"];
			break;
		case 7:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_tabasco.png"];
			break;
		case 8:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_flygun.png"];
			break;
        case 9:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_uebergun.png"];
			break;
        case 10:
            _ammoLabel = [CCSprite spriteWithSpriteFrameName:@"ammoicon_bugspray.png"];
			break;
	}
    
    _ammoLabel.visible = YES;
    _ammoLabel.position = ccp(218, winSize.height-_ammoLabel.contentSize.height/2);
    [self addChild:_ammoLabel z:18];
}

-(void) changeWeaponAmmo {
    [self changeWeaponAmmo:_wheaponType];
}

- (void)removeSpriteBody:(id)sender {

    CCSprite *sprite = (CCSprite *)sender;
    b2Body *spriteBody = NULL;
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *curSprite = (CCSprite *)b->GetUserData();
            if (sprite == curSprite) {
                spriteBody = b;
                break;
            }
        }
    }
    if (spriteBody != NULL) {
        _world->DestroyBody(spriteBody);
    }
}

- (void) delayedDropWeapon
{
    // make sure there is no ammo before drop..
    if (_wheaponAmmo<=0 && _wheaponType != 0) {
        [self dropWeapon];
    }
}

- (void) dropWeapon {
	
	_laserBeam.visible = NO;
	_rainbow.visible = NO;
	_bulletMGMode = NO;
    
    if (_dropWeaponDelayed) {
        _dropWeaponDelayed = NO;
    }
	
	if (_wheaponType != 0) {
		[_player stopShooting];
		if (_wheaponType == 2) {
			[self removeSpriteBody:_laserBeam];
		}
		if (_wheaponType == 6) {
			[self removeSpriteBody:_rainbow];
		}
		_wheaponType = 0;
		_wheaponAmmo = 0;
		_itemWeight = 0;
		[_player dropWeapon];
		[self updateAmmoBar];
	}
    
    [self changeWeaponAmmo];
}

-(void) enemyDeath:(Monster *)enemy {
    
    if (enemy.isDead) {
        // if multiple bullets hit the target early return..
        return;
    }
    
    _projectilesDestroyed++;
    enemy.isDead = YES;
    
    // tutorial targets..
    if ([enemy isKindOfClass:[DummyTarget class]]) {
        CCSprite *marked = [CCSprite spriteWithSpriteFrameName:@"tut_target_shot.png"];
        marked.position = ccp(enemy.position.x, enemy.position.y);
        [marked runAction:[CCMoveTo actionWithDuration:0.7 position:ccp(marked.position.x-100, marked.position.y)]];
        [marked runAction:[CCFadeOut actionWithDuration:0.7]];
        [self addChild:marked z:22];
        return;
    }
    
    if ([enemy isKindOfClass:[Bibi class]]) {
        if (arc4random() % 2) {
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/enemies/birdy_death.caf"];
            }
        }
    } else {
        if (arc4random() % 3) {
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"audio/sfx/enemies/bug_hit%d.caf",(arc4random()%3)]];
            }
        }
    }
    
    // TODO: death ani
    //NSLog(@"NO DEATH ANI ATM..");
    //return;
    
    // attach death scene..
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:@"birdy" forKey:@"Bibi2"];
    [dictionary setObject:@"birdy" forKey:@"Bibi"];
    [dictionary setObject:@"gilbert" forKey:@"BugGilbert"];
    [dictionary setObject:@"ladybug" forKey:@"LadyBug"];
    [dictionary setObject:@"lina" forKey:@"BugLina"];
    [dictionary setObject:@"bob" forKey:@"FlyBob"];
    [dictionary setObject:@"oona" forKey:@"BugOona"];
    [dictionary setObject:@"fred" forKey:@"FlyFred"];
    [dictionary setObject:@"fuckbutton" forKey:@"Fuckbutton"];
    [dictionary setObject:@"robert" forKey:@"FlyRobert"];
    [dictionary setObject:@"sina" forKey:@"FlySina"];
    
    NSString *desc = [dictionary objectForKey:[[enemy class] description]];
    [dictionary release];
    
    if (!desc) {
        return;
    }
    
    if ([desc isEqualToString:@"birdy"]) {
        // TODO: remove this class!!
        DeathAni *death = [DeathAni initWithTarget:enemy:3];
        [self addChild:death z:20];
    } else {
       int index = [ParticleEffects fireParticles:desc:ccp(enemy.position.x,enemy.position.y)];
        
        // callback to re-enable current emitter!
        // TODO: this sucks.. fix it!!!
        switch (index) {
            case 0:
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:1.3],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(resetEmitter1)],
                                 nil]];
                break;
            case 1:
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:1.3],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(resetEmitter2)],
                                 nil]];
                break;
            case 2:
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:1.3],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(resetEmitter3)],
                                 nil]];
                break;
            case 3:
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:1.3],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(resetEmitter4)],
                                 nil]];
                break;
        }
        
    }
}

- (void) resetEmitter1 {
    [ParticleEffects releaseEm:0];
}
- (void) resetEmitter2 {
    [ParticleEffects releaseEm:1];
}
- (void) resetEmitter3 {
    [ParticleEffects releaseEm:2];
}
- (void) resetEmitter4 {
    [ParticleEffects releaseEm:4];
}

-(void) explode:(CGPoint)pos {
    
    for (int i=0; i<10; i++) {
        
        ExplosionParticle *particle = [ExplosionParticle initWithFile:[NSString stringWithFormat:@"boom_cloud%i.png",i/2]:pos];
        particle.position = pos;
        particle.tag = 4;
        [self addChild:particle z:22];
    }
    
    CCSprite *boomlabel = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"boom_label%i.png",arc4random()%6]];
	boomlabel.position = pos;
	boomlabel.scale = 0.5f;
	boomlabel.opacity = 0.0f;
	boomlabel.tag = 4;
	[self addChild:boomlabel z:22];
    
	[boomlabel runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.1f],
						  [CCFadeIn actionWithDuration:0.01f],
						  [CCScaleTo actionWithDuration:0.3f scale:1.0f],
						  [CCScaleTo actionWithDuration:0.2f scale:0.8f],
						  [CCFadeOut actionWithDuration:0.2f],
						  [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],nil]];
    
    [boomlabel runAction:[CCSequence actions:
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-5, boomlabel.position.y+5)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-10, boomlabel.position.y-3)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-15, boomlabel.position.y+5)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-20, boomlabel.position.y-3)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-25, boomlabel.position.y+1)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-30, boomlabel.position.y-5)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-35, boomlabel.position.y+0)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-40, boomlabel.position.y-3)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-45, boomlabel.position.y+2)],
                          [CCMoveTo actionWithDuration:0.1 position:ccp(boomlabel.position.x-50, boomlabel.position.y-1)],
                          nil]];
	
	CCSprite *projectile = nil;
	for (int i=0; i<=10; i++) {
		projectile = [CCSprite spriteWithSpriteFrameName:@"pumpgun_shot.png"];
		projectile.position = ccp(pos.x-50+(arc4random()%100), pos.y-50+(arc4random()%100));
		projectile.tag = 2;
		projectile.visible = NO;
		[_projectiles addObject:projectile];
		[self addChild:projectile z:9];
		
		//CGPoint realDest = ccp(realDest.x, realDest.y - 100 + (arc4random()%200));
		[projectile runAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:0.6f],
							   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
							   nil]];
		
		[self addBoxBodyForSprite:projectile];
	}
	
    [self vibrate];
    [_background runAction:[CCSequence actions:
                            [CCFadeTo actionWithDuration:0.1 opacity:150],
                            [CCFadeTo actionWithDuration:0.2 opacity:255],
                            nil]];
    
    
    
    
    if ([LocalStorageManager isSFXEnabled]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/boom.caf"];
    }
	
	// Damage on herbert if distance to low..
	int offX = pos.x - _player.position.x;
	int offY = pos.y - _player.position.y;
	if (offX < 80 && (offY>-100 && offY<100)) {
		[self hitPlayer:200];
	}
}

-(void) lsdCountdown: (ccTime) dt {
	_lsdCountdown--;
	[_ammoBar setString:[NSString stringWithFormat:@"%i",_lsdCountdown]];
}

-(void) speedUpdate
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // update all objects on stage..
    for(id item in self.children) {
        
        float distance;
        float restDistance;
        float restSpeed;
        
        id actionMove;
        id actionMoveDone;
        
        // UPDATE CLOUDS
        if ([item isKindOfClass:[Cloud class]] && ![item isKindOfClass:[Rainbow class]]) {
            [item stopAllActions];
            Cloud *myCloud = (Cloud *) item;
            //
            distance = winSize.width+myCloud.contentSize.width;
            restDistance = myCloud.position.x+myCloud.contentSize.width/2;
            restSpeed = myCloud.speed/distance*restDistance;
            myCloud.speed = restSpeed;
            actionMove = [CCMoveTo actionWithDuration:restSpeed/_gameSpeed
                                             position:ccp(-myCloud.contentSize.width/2, myCloud.position.y)];
            actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                                  selector:@selector(removeCloud:)];
            // update movespeed..
            [myCloud runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        }
        
        // UPDATE PARTICLES
        if ([item isKindOfClass:[Particles class]]) {
            [item stopAllActions];
            Particles *particle = (Particles *) item;
            //
            distance = winSize.width+particle.contentSize.width;
            restDistance = particle.position.x+particle.contentSize.width/2;
            restSpeed = particle.speed/distance*restDistance;
            particle.speed = restSpeed;
            actionMove = [CCMoveTo actionWithDuration:restSpeed/_gameSpeed
                                             position:ccp(-particle.contentSize.width/2, particle.position.y)];
            actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                                  selector:@selector(removeCloud:)];
            // update movespeed..
            [particle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        }
    }
    
    // update all objects on stage..
    for(id item in environmentBatchNode.children) {
        
        float distance;
        float restDistance;
        float restSpeed;
        id actionMove;
        id actionMoveDone;
        
        // UPDATE CLOUDS
        if ([item isKindOfClass:[Cloud class]]) {
            [item stopAllActions];
            Cloud *myCloud = (Cloud *) item;
            distance = winSize.width+myCloud.contentSize.width;
            restDistance = myCloud.position.x+myCloud.contentSize.width/2;
            restSpeed = myCloud.speed/distance*restDistance;
            myCloud.speed = restSpeed;
            actionMove = [CCMoveTo actionWithDuration:restSpeed/_gameSpeed
                                             position:ccp(-myCloud.contentSize.width/2, myCloud.position.y)];
            actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                                  selector:@selector(removeCloud:)];
            // update movespeed..
            [myCloud runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        }
        
        // UPDATE PARTICLES
        if ([item isKindOfClass:[Particles class]]) {
            NSLog(@"update particle");
            [item stopAllActions];
            Particles *particle = (Particles *) item;
            //
            distance = winSize.width+particle.contentSize.width;
            restDistance = particle.position.x+particle.contentSize.width/2;
            restSpeed = particle.speed/distance*restDistance;
            particle.speed = restSpeed;
            actionMove = [CCMoveTo actionWithDuration:restSpeed/_gameSpeed
                                             position:ccp(-particle.contentSize.width/2, particle.position.y)];
            actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                                  selector:@selector(removeCloud:)];
            // update movespeed..
            [particle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        }
    }
    
    for(id target in _targets)
    {
        // UPDATE ENEMIES
        if ([target isKindOfClass:[Monster class]]) {
            Monster *monster = (Monster *) target;
            monster.gameSpeed = _gameSpeed;
            [monster speedUpdate];
        }
    }
    
}

-(void) enableLSDMode
{	
	if (_lsdMode != YES) {
		_lsdMode = YES;
        
        _protectMode = NO;
        [_player dropProtectSuitWithAnimation:NO];
        [self schedule:@selector(createDrugRainbow) interval:0.04];
		
		int time = 5;
		
		_gameTimeSeconds--;
        // this is to prevent that the speed-up message is flashing up multiple times when taking a star one second before.. rly rare case!
        
        if ([LocalStorageManager isMusicEnabled]) {
            NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio/music/bg_drugmode" ofType:@"caf"]];
            _drugSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
            _drugSound.volume = 1.0f;
            _drugSound.numberOfLoops = 3;
            [_drugSound prepareToPlay];
            [_drugSound play];
        }
        
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
		
		_gameSpeed = _gameSpeed*2;
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:0.1],
                         [CCCallFuncN actionWithTarget:self selector:@selector(speedUpdate)],
                         nil]];
        
		_lsdCountdown = time;
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _drugbg = [CCSprite spriteWithFile:@"drugmode.png"];
        _drugbg.position = ccp(winSize.width/2, winSize.height/2);
		_drugbg.visible = YES;
		_drugbg.rotation = 0;
        [self addChild:_drugbg z:0];
        
		[self dropWeapon];
		[_player enableLSD];
		[_drugbg runAction:[CCRotateTo actionWithDuration:(time) angle:120]];
		[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:time], [CCCallFunc actionWithTarget:self selector:@selector(disableLSDMode)], nil]];
		[self schedule:@selector(lsdCountdown:) interval:1.0];
		_ammoLabel.visible = NO;
        
        // hide rainbows in drug mode
        for(id item in self.children) {
            if ([item isKindOfClass:[Rainbow class]]) {
                [(Rainbow*)item setVisible:NO];
            }
        }
	}
}

-(void) disableLSDMode
{	
	if (_lsdMode != NO) {
		_lsdMode = NO;
        
        [self removeChild:_drugbg cleanup:YES];
        _drugbg = nil;
        
		_gameSpeed = _gameSpeed/2;
        [self speedUpdate];
		
        _lastHerbLocation = ccp(0,0);
        [self unschedule:@selector(createDrugRainbow)];
		[self unschedule:@selector(lsdCountdown:)];
		[self updateAmmoBar];
        [self changeWeaponAmmo];
		
		[_drugSound stop];
        [_drugSound release];
        _drugSound = nil;
        
        [self unschedule:@selector(repeatDrugSound)];
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
		
		[_player disableLSD];
		[self enableGodMode];
        
        // show rainbows after drug mode
        for(id item in self.children) {
            if ([item isKindOfClass:[Rainbow class]]) {
                [(Rainbow*)item setVisible:YES];
            }
        }
	}
}

// add body for each sprite for collision detection
- (void)addBoxBodyForSprite:(CCSprite *)sprite {
	
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_dynamicBody;
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO, 
							   sprite.position.y/PTM_RATIO);
	
    spriteBodyDef.userData = sprite;
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
	
	// TODO put polygons into monster class..
	b2PolygonShape spriteShape;
	
	// TODO: add that to the monster class!
	if ([sprite isKindOfClass:[Bibi class]]) {
		
		// Polygon must be "convex" and counterclockwise.
		int num = 8;
		b2Vec2 verts[] = {
			b2Vec2(-9.0f / PTM_RATIO, 46.2f / PTM_RATIO),
			b2Vec2(-38.2f / PTM_RATIO, 29.0f / PTM_RATIO),
			b2Vec2(-50.7f / PTM_RATIO, -4.5f / PTM_RATIO),
			b2Vec2(-33.2f / PTM_RATIO, -42.0f / PTM_RATIO),
			b2Vec2(12.7f / PTM_RATIO, -50.0f / PTM_RATIO),
			b2Vec2(49.2f / PTM_RATIO, -20.5f / PTM_RATIO),
			b2Vec2(42.0f / PTM_RATIO, 25.7f / PTM_RATIO),
			b2Vec2(12.2f / PTM_RATIO, 46.2f / PTM_RATIO)
		};		
		spriteShape.Set(verts, num);
		
	}
	// Bug body..
	else if ([sprite isKindOfClass:[BugGilbert class]]) {
		
		int num = 6;
		b2Vec2 bverts[] = {
			b2Vec2(-8.9f / PTM_RATIO, 6.5f / PTM_RATIO),
			b2Vec2(-18.5f / PTM_RATIO, -7.3f / PTM_RATIO),
			b2Vec2(-14.6f / PTM_RATIO, -18.6f / PTM_RATIO),
			b2Vec2(1.1f / PTM_RATIO, -24.8f / PTM_RATIO),
			b2Vec2(13.3f / PTM_RATIO, -16.2f / PTM_RATIO),
			b2Vec2(12.8f / PTM_RATIO, -4.2f / PTM_RATIO)
		};		
		spriteShape.Set(bverts, num);
	}
	
	// laser beam set mask
	else if (sprite.tag == 5) {
		spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
							 10/PTM_RATIO,
							 b2Vec2(9.0f,0.1f), 0.0f);
	}
	// projectiles
	else if ([sprite isKindOfClass:[Projectile class]]) {
		
		Projectile *proj = (Projectile *)sprite;
		spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
							 sprite.contentSize.height/PTM_RATIO/2,
							 b2Vec2(proj.b2BodyOffset.x, proj.b2BodyOffset.y), 0.0f);
	}
	// herbert body
	else if ([sprite isKindOfClass:[Herbert class]]) {
		
		// Polygon must be "convex" and counterclockwise.
		int num = 6;
		b2Vec2 hverts[] = {
			b2Vec2(24.7f / PTM_RATIO, 18.0f / PTM_RATIO),
			b2Vec2(-1.2f / PTM_RATIO, 25.0f / PTM_RATIO),
			b2Vec2(-20.0f / PTM_RATIO, 11.7f / PTM_RATIO),
			b2Vec2(-16.7f / PTM_RATIO, -13.2f / PTM_RATIO),
			b2Vec2(1.2f / PTM_RATIO, -14.7f / PTM_RATIO),
			b2Vec2(21.5f / PTM_RATIO, -2.7f / PTM_RATIO)
		};
		spriteShape.Set(hverts, num);
		
	}
	else {
		spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
							 sprite.contentSize.height/PTM_RATIO/2);
	}
	
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 10.0;
    spriteShapeDef.isSensor = true;
    spriteBody->CreateFixture(&spriteShapeDef);
}

- (BOOL)hasSpriteBody:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *curSprite = (CCSprite *)b->GetUserData();
            if (sprite == curSprite) {
                return YES;
            }
        }
    }
    return NO;
}

-(void) reloadWheapon {
	_wheaponReloaded = YES;
}
-(void) loadPumpgun {
    if ([LocalStorageManager isSFXEnabled]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/pumpgun_load.caf"];
    }
}

-(void) updateHealthBar
{	
	float initPos = 30;
	float barWidth = 39;
	float maskSize = (barWidth/_maxHealth*(_maxHealth-_health));
    int health = _health>_maxHealth ? _maxHealth : _health;
    
    // figure out which color we have to fade to..
    ccColor3B startCol = (ccColor3B){246,253,255};
    ccColor3B endCol = (ccColor3B){173,224,245};
    
    if (health<300 && health>=250) {
        startCol = (ccColor3B){242,251,245};
        endCol = (ccColor3B){161,209,227};
    }
    if (health<250 && health>=200) {
        startCol = (ccColor3B){239,250,237};
        endCol = (ccColor3B){150,195,202};
    }
    if (health<200 && health>=150) {
        startCol = (ccColor3B){236,249,226};
        endCol = (ccColor3B){139,181,196};
    }
    if (health<150 && health>=100) {
        startCol = (ccColor3B){233,248,219};
        endCol = (ccColor3B){129,167,179};
    }
    if (health<100 && health>=50) {
        startCol = (ccColor3B){232,248,216};
        endCol = (ccColor3B){107,140,149};
    }
    if (health<50) {
        startCol = (ccColor3B){232,248,216};
        endCol = (ccColor3B){82,107,115};
    }
    
    // update background on hit / health decrease
    [_background newColorFade:startCol:endCol:1];
    
	[_healthBar stopAllActions];
	[_healthBar runAction: [CCMoveTo actionWithDuration:0.2 position:ccp(initPos-(maskSize/2),_healthBar.position.y)]];
	[_healthBar runAction: [CCMaskTo actionWithDuration:0.2 rect:CGRectMake(0,0,barWidth-maskSize,_healthBar.contentSize.height)]];
}

-(void) disableGodmode {
	_godMode = NO;
}
-(void) enableGodMode {
	// flashing and unbreakable..
	_godMode = YES;
	[_player runAction:[CCSequence actions:
                        [CCCallFunc actionWithTarget:_player selector:@selector(blink)],
                        [CCDelayTime actionWithDuration:2],
						[CCCallFunc actionWithTarget:self selector:@selector(disableGodmode)],nil]];
}

-(void) hitPlayer:(int)damage {
	
	if (!_godMode && !gameOverScene) {
        
        [self vibrate];
		
		if (!_tutorialMode) {
            _health -= damage;
        }
		
		if (_health<=0) {
			
            // hit only once..
            _godMode = YES;
            _health = 0; // if less than zero..
            
            // game over...
            [self dropWeapon];
            [self disableGameControlls];
            [_player deathAni];
            
            _gameSpeed = _gameSpeed/2;
            [self speedUpdate];
            
            [self runAction:[CCSequence actions:
                             [CCDelayTime actionWithDuration:1],
                             [CCCallFuncN actionWithTarget:self selector:@selector(gameOverSceneChange)],
                             nil]];
            
		} else {
			[self enableGodMode]; // blink for 2 seconds..
		}
        
        [self updateHealthBar];
	}
}

-(void) gameOverSceneChange {
    
    [LocalStorageManager loadMenuAssets];
    gameOverScene = [GameOverScene node];
    gameOverScene.layer.projectilesDestroyed = _projectilesDestroyed;
    gameOverScene.layer.gametime = _gameTimeSeconds;
    gameOverScene.layer.score = _points;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:gameOverScene withColor:ccc3(255, 255, 255)]];
}


-(void) updatePointsBar
{	
    if (_pointsDisplay < _points) {
        
        int diff = (_points-_pointsDisplay);
        int countStep = diff/11;
        if (countStep<5) {
            countStep = (_points-_pointsDisplay)>5 ? 5 : 1;
        }
        
        _pointsDisplay += countStep;
        [_pointsBar setString:[NSString stringWithFormat:@"%d",_pointsDisplay]];
    }
    
    if (_tutorialMode && _pointsDisplay > _points) {
        
        // tutorial finished..
        if (_points == 0) {
            if (_tutorialLevel == 2) {
                // disable game controlls and get weapon
                [self addItem:[PumpGun item]];
                [self disableGameControlls];
                [_pointsBar runAction:[CCFadeOut actionWithDuration:0.3]];
                [self killAllEnemies];
                
                _bulletMGMode = NO;
                [_player stopShooting];
                [_player updatePosition:180:260:1.2:2.5];
                [_player stopTilting];
                
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:3.7],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(finishTut3)],
                                 nil]];
            } else {
                // next tutorial
                [self initGameTutorial];
            }
        }
        
        if (_points >= 0) {
            _pointsDisplay--;
            [_pointsBar setString:[NSString stringWithFormat:@"%d",_pointsDisplay]]; 
        }
    }
}

-(void) killAllEnemies {

    for (Monster *target in _targets)
    {
        [self removeSpriteBody:target];
        [target stopAllActions];
        [target setOpacity:255];
        [target unscheduleAllSelectors];
        [target removeAndCleanup];
        [self enemyDeath:target];
        
        if (!_tutorialMode) {
            _points += target.points;
        }
	}
    [_targets removeAllObjects];
}

- (void)update:(ccTime)dt {

    NSMutableArray *objectsToDelete = [[NSMutableArray alloc] init];
	
	CGRect playerRect = CGRectMake(
								   _player.position.x, 
								   _player.position.y-20, 
								   30, 
								   60);
	
	// update bodies..
	_world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
			CGPoint offset = ccp(0,0);
			
			/*if (sprite.tag == 1 || [sprite isKindOfClass:[Herbert class]]) {
				Monster *monster = (Monster *)sprite;
			}*/
			
			// special position for herb body if in drug mode..
            if ([sprite isKindOfClass:[Herbert class]] && _lsdMode) {
				offset.x = 150;
			}
            
            // Create smoke for rockets!
            if ([sprite isKindOfClass:[Rocket class]]) {
                // as long as we just have one rocket we can use a variable..
                _rocketPosition = sprite.position;
            }
			
            b2Vec2 b2Position = b2Vec2((sprite.position.x+offset.x)/PTM_RATIO,
									   (sprite.position.y+offset.y)/PTM_RATIO);
			
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            b->SetTransform(b2Position, b2Angle);
        }
    }
    
    // improve performance and check only every 3rd time the collision..
    if (checkCollisions<2) {
        checkCollisions++;
        return;
    } else {
        checkCollisions = 0;
    }
    
    // check for collision with box2d
    std::vector<b2Body *>toDestroy; 
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); 
        pos != _contactListener->_contacts.end(); ++pos) {
        
        MyContact contact = *pos;
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            // herbert against targets
            if (spriteA.tag == 1 && [spriteB isKindOfClass:[Herbert class]]) {
                [self targetHitsHerbert:(Monster *)spriteA];
                spriteA.tag = kRemoveObjectTag;
                //[objectsToDelete addObject:spriteA];
            } else if (spriteB.tag == 1 && [spriteA isKindOfClass:[Herbert class]]) {
                [self targetHitsHerbert:(Monster *)spriteB];
                spriteB.tag = kRemoveObjectTag;
                //[objectsToDelete addObject:spriteB];
            }
            
            // check projectiles against targets
            else if (spriteA.tag == 1 && (spriteB.tag == 2 || spriteB.tag == 5))
            {
                [self bulletHitsTarget:spriteB:spriteA:objectsToDelete];
                toDestroy.push_back(bodyA);
            } else if ((spriteA.tag == 2 || spriteA.tag == 5) && spriteB.tag == 1)
            {
                [self bulletHitsTarget:spriteA:spriteB:objectsToDelete];
                toDestroy.push_back(bodyB);
            }
        }
    }
    
    // synchronize array because of multithreading..
    @synchronized(_targets) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for(Monster *target in _targets)
        {
			if (target.tag == kRemoveObjectTag) {
                [tempArray addObject:target];
                [self removeSpriteBody:target];
                [target stopAllActions];
                [target setOpacity:255];
                [target unscheduleAllSelectors];
                [target removeAndCleanup];
			}
		}
        
        [_targets removeObjectsInArray:tempArray];
        tempArray = nil;
        
	}
    
    // synchronize array because of multithreading..
    @synchronized(_projectiles) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for(Projectile *projectile in _projectiles)
        {
			if (projectile.tag == kRemoveObjectTag)
            {    
                [tempArray addObject:projectile];
                [self removeSpriteBody:projectile];
                [self removeChild:projectile cleanup:YES];
                
                if ([projectile isKindOfClass:[Rocket class]])
                {
                    [self unschedule:@selector(createRocketSmoke)];
                }
			}
		}
        
        [_projectiles removeObjectsInArray:tempArray];
        tempArray = nil;
        
	}
    
    [objectsToDelete release];
    
    // synchronize array because of multithreading..
    @synchronized(_items) {
        
		Item *itemToRemoveLater = nil;
        for(Item *item in _items)
        {
			if (item.tag == kRemoveObjectTag) {
				itemToRemoveLater = item;
				continue;
			}
            
            CGRect itemRect = CGRectMake(
                                         item.position.x - (item.contentSize.width/2), 
                                         item.position.y - (item.contentSize.height/2), 
                                         item.contentSize.width, 
                                         item.contentSize.height);
            
            // Get item
            if (CGRectIntersectsRect(playerRect, itemRect) && !gameOverScene)
            {
                [self getItem:item];
            }
		}
        
		if(itemToRemoveLater!=nil)
        {
			[_items removeObject:itemToRemoveLater];
            [objectBatchNode removeChild:itemToRemoveLater cleanup:YES];
		}
	}
	
	if (_wheaponType == 2) {
		_laserBeam.position = ccp(_player.position.x-2, _player.position.y-42);
	}
	
	if (_wheaponType == 6) {
		_rainbow.position = ccp(_player.position.x-7, _player.position.y-47);
	}
    
    // update pointsbar
    [self updatePointsBar];
}

- (void) targetHitsHerbert:(Monster *)monster
{
    [self enemyDeath:monster];
    
    // decrease health
    if (_lsdMode != YES) {
        if (_protectMode == YES) {
            _protectMode = NO;
            [_player dropProtectSuit];
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/protectionsuit_out.caf"];
            }
            [self enableGodMode];
        } else {
            // in tutorial 3 set points back to 5 if enemy hits you..
            if (_tutorialLevel == 2) {
                _pointsDisplay = 6;
                _points = 5;
            }
            [self hitPlayer:monster.strength];
        }
    }
    
    if (!_tutorialMode) {
        _points += monster.points;
    }
}

- (void) bulletHitsTarget:(Projectile *)projectile:(Monster *)monster:(NSMutableArray *)objectsToDelete
{
    if ([projectile isKindOfClass:[Rocket class]]) {
        if (!_tutorialMode) {
            _points += 150;
        }
        [self explode:projectile.position];
    }
    
    if ([projectile isKindOfClass:[Projectile class]]) {
        if (!_tutorialMode) {
            _points += 20;
        }
        projectile.tag = kRemoveObjectTag;
        monster.hp -= projectile.strength;
    } else {
        monster.hp -= 1;
    }
    
    // in tutorial 3.. bibis are immortal
    if (monster.hp <= 0 && _tutorialLevel != 2)
    {
        monster.tag = kRemoveObjectTag;
        [self enemyDeath:monster];
        
        if (!_tutorialMode)
        {
            _points += monster.points;
        }
        else {
            _points -= 1;
        }
        
    } else {
        
        // blinks..
        [monster blink];
        
        // Sprechblase / speach bubble:
        if (arc4random()%12 == 0)
        {
            [monster addSpeakbubble];
        }
    }
}

- (void) getItem:(Item *)item
{    
    _bulletMGMode = NO;
    _laserBeam.visible = NO;
    _rainbow.visible = NO;
    
    if (![item isKindOfClass:[UberGun class]]) {
        [self unschedule:@selector(ueberlightening)];
        [_background stopAllActions];
        [_background runAction:[CCFadeTo actionWithDuration:0.2f opacity:255]];
    }
    
    // GET CAPUSHITO
    if ([item isKindOfClass:[Capushito class]]) {
        if (_health+100<_maxHealth) {
            _health += 100;
        } else {
            _health = _maxHealth; 
        }
        [self updateHealthBar];
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"audio/sfx/herb/shitoccino%d.caf",arc4random()%3]];
        }
    }
    
    // GET LSD STAR
    if ([item isKindOfClass:[LsdStar class]]) {
        [self enableLSDMode];
    }
    
    // GET COIN
    if ([item isKindOfClass:[Coin class]]) {
        if (!_tutorialMode) {
            _points += 200;
        }
        else {
            _points--;
        }
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/coin_up.caf"];
        }
    }
    
    // GET PROTECTION SUIT
    if ([item isKindOfClass:[ProtectSuit class]] && (!_protectMode && !_lsdMode)) {
        [_player getProtectSuit];
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/protectionsuit_on.caf"];
        }
        _protectMode = YES;
    }
    
    // GET KALASCHNIKOV
    if ([item isKindOfClass:[Kalaschnikov class]] && !_lsdMode) {
        
        if (_wheaponType == 1) {
            _wheaponAmmo += 25;
        }
        else {
            _wheaponAmmo = 25;
            [_player changeWeapon:1];
            [self changeWeaponAmmo:1];
        }
        
        [self updateAmmoBar];
        _wheaponType = 1;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET MINIGUN
    if ([item isKindOfClass:[MiniGun class]] && !_lsdMode) {
        
        if (_wheaponType == 3) {
            _wheaponAmmo += 50;
        }
        else {
            _wheaponAmmo = 50;
            [_player changeWeapon:3];
            [self changeWeaponAmmo:3];
        }
        [self updateAmmoBar];
        _wheaponType = 3;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET PUMPGUN
    if ([item isKindOfClass:[PumpGun class]] && !_lsdMode) {
        
        if (_wheaponType == 4) {
            _wheaponAmmo += 8;
        }
        else {
            _wheaponAmmo = 8;
            [_player changeWeapon:4];
            [self changeWeaponAmmo:4];
        }
        [self updateAmmoBar];
        _wheaponType = 4;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET ROCKETLAUNCHER
    if ([item isKindOfClass:[RocketLauncher class]] && !_lsdMode) {
        
        if (_wheaponType == 5) {
            _wheaponAmmo += 5;
        }
        else {
            _wheaponAmmo = 5;
            [_player changeWeapon:5];
            [self changeWeaponAmmo:5];
        }
        [self updateAmmoBar];
        _wheaponType = 5;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET LASERGUN
    if ([item isKindOfClass:[LaserGun class]] && !_lsdMode) {
        
        if (_wheaponType == 2) {
            _wheaponAmmo += 30;
        }
        else {
            _wheaponAmmo = 30;
            [_player changeWeapon:2];
            [self changeWeaponAmmo:2];
        }
        
        [self updateAmmoBar];
        _wheaponType = 2;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    else {
        if (_laserBeam) {
            [self removeSpriteBody:_laserBeam];
        }
    }
    
    // GET RAINBOWGUN
    if ([item isKindOfClass:[RainbowGun class]] && !_lsdMode) {
        
        if (_wheaponType == 6) {
            _wheaponAmmo += 45;
        }
        else {
            _wheaponAmmo = 45;
            [_player changeWeapon:6];
            [self changeWeaponAmmo:6];
        }
        
        [self updateAmmoBar];
        _wheaponType = 6;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    } else {
        if (_rainbow) {
            [self removeSpriteBody:_rainbow];
        }
    }
    
    // GET TABASCO
    if ([item isKindOfClass:[TabascoShot class]] && !_lsdMode) {
        
        if (_wheaponType == 7) {
            _wheaponAmmo += 15;
        }
        else {
            _wheaponAmmo = 15;
            [_player changeWeapon:7];
            [self changeWeaponAmmo:7];
        }
        
        [self updateAmmoBar];
        _wheaponType = 7;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET FLYGUN
    if ([item isKindOfClass:[FlyGun class]] && !_lsdMode) {
        
        if (_wheaponType == 8) {
            _wheaponAmmo += 5;
        }
        else {
            _wheaponAmmo = 5;
            [_player changeWeapon:8];
            [self changeWeaponAmmo:8];
        }
        
        [self updateAmmoBar];
        _wheaponType = 8;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET UBERGUN
    if ([item isKindOfClass:[UberGun class]] && !_lsdMode) {
        
        if (_wheaponType == 9) {
            _wheaponAmmo += 3;
        }
        else {
            _wheaponAmmo = 3;
            [_player changeWeapon:9];
            [self changeWeaponAmmo:9];
        }
        
        [self updateAmmoBar];
        _wheaponType = 9;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    // GET BUGSPRAY
    if ([item isKindOfClass:[BugSpray class]] && !_lsdMode) {
        
        if (_wheaponType == 10) {
            _wheaponAmmo += 30;
        }
        else {
            _wheaponAmmo = 30;
            [_player changeWeapon:10];
            [self changeWeaponAmmo:10];
        }
        
        [self updateAmmoBar];
        _wheaponType = 10;
        
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/items/weapon_up.caf"];
        }
    }
    
    if (!_lsdMode && ![item isKindOfClass:[LsdStar class]]) {
        
        // item up effect
        ItemUpParticle *itemUp = [ItemUpParticle particle:item];
        itemUp.position = ccp(item.position.x+10, item.position.y);
        [itemUp runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:1 position:ccp(itemUp.position.x-80, itemUp.position.y)],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
        [self addChild:itemUp z:8];
    }
    
    // inifinite ammo in tutorial..
    if (_tutorialMode) {
        _wheaponAmmo = 999;
    }
    
    [self spriteMoveFinished:item];
}

- (void) flyHitHerb:(id)sender
{
    // fly gun hits herbert..
    [(Projectile *)sender setTag:kRemoveObjectTag];
    [self removeSpriteBody:sender];
    [self hitPlayer:100];
}

- (void)spriteMoveFinished :(id)sender {

	CCSprite *sprite = (CCSprite *)sender;
	
	if (sprite.tag == 2) { // projectile
		if ([sprite isKindOfClass:[Rocket class]]) {
			[self unschedule:@selector(createRocketSmoke)];
		}
        sprite.tag = kRemoveObjectTag;
        return;
	}
	else if (sprite.tag == 3) { // item
		sprite.tag = kRemoveObjectTag;
        return;
	}
    
    else if (sprite.tag == kDrugRainbowTag) { // drugRainbow
		[environmentBatchNode removeChild:sprite cleanup:YES];
        sprite = nil;
        return;
	}
	
	if (sprite.tag != 4) { // explosion sprite
		[self removeSpriteBody:sprite];
	} else {
		[sprite stopAllActions];
	}
	
	// flash sprite
	if (sprite.tag == 10) {
		_flashSprite = nil;
	}
    
    [self removeChild:sprite cleanup:YES];
	sprite = nil;
}

-(void)removeCloud :(id)sender {
	
    if ([sender isKindOfClass:[Rainbow class]]) {
        _hasRainbow = false;
    }
    if ([sender isKindOfClass:[BackgroundCloud class]] || [sender isKindOfClass:[MiddleCloud class]] || [sender isKindOfClass:[GroundCloud class]]) {
        Cloud *sprite = (Cloud *)sender;
        [environmentBatchNode removeChild:sprite cleanup:YES];
        return;
    }
	Cloud *sprite = (Cloud *)sender;
	[self removeChild:sprite cleanup:YES];
}

-(void)addCloud {

	Cloud *target = nil;
	
	int random = arc4random() % 6; // 0-5
	
	if (arc4random() % 3 == 0) {
		
        if (_hasRainbow) {
            return;
        }
        target = [Rainbow cloud];
        if (_lsdMode) {
            target.visible = NO;
        }
        _hasRainbow = true;
        
	} else {
		// all normal clouds
		if (random != 0) {
			if (random>3) {
				target = [MiddleCloud cloud];
			} else {
				target = [BackgroundCloud cloud];
			}
		} else {
			target = [ForegroundCloud cloud];
		}
	}
	
	//target.tag = 3;
	//[_targets addObject:target];
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = 0;
    if ([target isKindOfClass:[MiddleCloud class]]) {
        minY = 100;
    }
	int maxY = winSize.height;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
    int targetX = -target.contentSize.width/2;
	
	// special case for Rainbow
	if ([target isKindOfClass:[Rainbow class]]){
		actualY = target.contentSize.height/2;
		targetX = -1500;
	}
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
    
    if ([target isKindOfClass:[MiddleCloud class]] || [target isKindOfClass:[BackgroundCloud class]]){
		[environmentBatchNode addChild:target z:target.index];
	} else {
        [self addChild:target z:target.index];
    }
	
	// Determine speed of the target
	// Create the actions
	id actionMove = [CCMoveTo actionWithDuration:target.speed/_gameSpeed
										position:ccp(targetX, actualY)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self 
											 selector:@selector(removeCloud:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (Item *) chooseItem
{	
	NSArray *items = [LocalStorageManager getUnlockedItems];
    NSString *itemName = [items objectAtIndex:((int)arc4random()%[items count])];
	Item *item = [(Item *)NSClassFromString(itemName) item];
	return item;
}

- (Monster *) chooseTarget
{	
	// reverted switch.. if higher level more weapons available
	NSMutableArray *targets = [[NSMutableArray alloc] init];
	Monster *target = nil;
    
    if (_difficultyLevel >= 6) {
        // 3rd speedup
        [targets addObject:[FlyBob monster]];
        [targets addObject:[FlyRobert monster]];
    }
    if (_difficultyLevel >= 4) {
        // 2nd speedup
        [targets addObject:[Fuckbutton monster]];
        [targets addObject:[LadyBug monster]];
    }
    if (_difficultyLevel >= 2) {
        // 1st speedup
        [targets addObject:[BugGilbert monster]];
        [targets addObject:[Bibi monster]];
        [targets addObject:[Bibi2 monster]];
    }
    
    // default enemies
    [targets addObject:[FlyFred monster]];
    [targets addObject:[FlySina monster]];
    [targets addObject:[BugOona monster]];
    [targets addObject:[BugLina monster]];
	
    int index = arc4random()%[targets count];
	target = [targets objectAtIndex:index];
    [targets removeAllObjects];
	[targets release];
    targets = nil;
    
    // bird peep..
    if ([target isKindOfClass:[Bibi class]] || [target isKindOfClass:[Bibi2 class]]) {
        if (arc4random() % 3) {
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/enemies/birdy_coming.caf"];
            }
        }
    }
    
    // follow bug..
    if ([target isKindOfClass:[BugGilbert class]]) {
        [target follow:_player];
    }
    
	return target;
}

- (void) addItem:(Item *)item
{    
    // add item if there are not already enough placed..
    [self addItem:item:NO];
}

- (void) addItem:(Item *)item:(bool)forceAdd
{
    // max 2 items on stage
	if([_items count]>=2 && !_tutorialMode && !forceAdd) {
    	return;
	}
    
    item.tag = 3;
	[_items addObject:item];
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = item.contentSize.height/2;
	int maxY = winSize.height - item.contentSize.height/2;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
	
	// if in simulator or tutorial: always same height so herb can fly in that direction and take weapon
    if (_isIphoneSimulator || _tutorialLevel == 2) {
        actualY = 180;
    }
	
	// Create the target off-screen
	item.position = ccp(winSize.width + (item.contentSize.width/2), actualY);
	[objectBatchNode addChild:item z:9];
	
	// Create the move actions
	id actionMove = [CCMoveTo actionWithDuration:10/_gameSpeed 
										position:ccp(-item.contentSize.width/2, actualY)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self 
											 selector:@selector(spriteMoveFinished:)];
	[item runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (void) addItem
{	
	Item *item = [self chooseItem];
    //Item *item = [LsdStar item];
    if (item) {
        [self addItem:item];
    }
}

-(void)addTarget {
    
    Monster *target = nil;
    //if([_targets count]>=1) { return; }
    
    if (_tutorialMode && _tutorialLevel == 1) {
        // Zielscheibe..
        target = [DummyTarget monster];
    }
    
    else if (_tutorialMode && (_tutorialLevel == 2 || _tutorialLevel == 3)) {
        // Birdies..
        if (arc4random()%2==0) {
            target = [Bibi monster];
        } else {
            target = [Bibi2 monster];
        }
    }
    
    else {
        
        target = [self chooseTarget];
        //target = [BugLina monster];
    }
    
    if (!target) return;
	
    //target = [BugLina monster];
    //[target follow:_player];
	
	target.tag = 1;
	target.gameSpeed = _gameSpeed;
	[_targets addObject:target];
    
	
	// Global Eventlistener
	/*[[NSNotificationCenter defaultCenter]
    addObserver:self
	 selector:@selector(monsterMoveFinished:)
	 name:@"monsterMoveFinished"
	 object:target];*/
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = 0;
	int maxY = winSize.height;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
    
    // debug
    //actualY = 300;
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
	[self addBoxBodyForSprite:target];
    [objectBatchNode addChild:target z:10];
	[target initWithYPos:actualY];
}

- (void) addParticle {
    
    // no particles in drug mode
    //if (_lsdMode) {
    //    return;
    //}
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = 0;
	int maxY = winSize.height;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
    
    // Add particles
    Particles *particle = [ForegroundParticle particle];
    particle.position = ccp(winSize.width + 30, actualY);
    particle.tag = kParticleTag;
    [self addChild:particle z:particle.index];
    [particle runAction:[CCSequence actions:[CCMoveTo actionWithDuration:particle.speed/_gameSpeed position:ccp(-particle.contentSize.width/2, actualY)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(removeCloud:)],
                         nil]];
}


- (void) handleCCTouchForShooting: (CGPoint) location {
	
	// disable shooting completly when take lsd
	if (_lsdMode == YES) {
		return;
	}
    
    if (_dropWeaponDelayed) {
        // if we're already empty and still try to shoot.. imediatly drop weapon!
        [self dropWeapon];
        return;
    }
    
    // Bail out if we are trying to shoot backwards
    if (location.x <= 70) return;
	
	// Set up initial location of projectile
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// other var declarations..
	Projectile *projectile = nil;
	int offX;
	int offY;
	int realX;
	float ratio;
	int realY;
	CGPoint realDest;
	int offRealX;
	int offRealY;
	float length;
	float velocity;
	float realMoveDuration;
	float angleRadians;
	float angleDegrees;
	float cocosAngle;
	
	switch (_wheaponType)
	{
            // PROJECTILES
			// mg
		case 1:
			projectile = [MGShell projectile];
			projectile.anchorPoint = ccp(-3.0, 0.5);
			projectile.position = ccp(_player.position.x+8, _player.position.y-13.5);
			projectile.tag = 2;
			[_projectiles addObject:projectile];
			
			// Determine offset of location to projectile
			offX = location.x - projectile.position.x;
			offY = location.y - projectile.position.y;
			[self addChild:projectile z:9];
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width + (projectile.contentSize.width/2);
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + projectile.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - projectile.position.x;
			offRealY = realY - projectile.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 300/1; // 480pixels/1sec
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			projectile.rotation = cocosAngle;
			
			[_player shoot:cocosAngle];
            
            _wheaponReloaded = NO;
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			
			// Move projectile to actual endpoint
			[projectile runAction:[CCSequence actions:
								   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/kalaschnikov.caf"];
			}
            break;
			
			
			// laser
		case 2:			
			// Determine offset of location to projectile
			offX = location.x - _player.position.x; // -+ Corrections for laser shot
			offY = location.y - _player.position.y;
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width;
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + _player.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - _player.position.x;
			offRealY = realY - _player.position.y;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			
			projectile = nil;
            _laserBeam.rotation = cocosAngle;
            
			if (![self hasSpriteBody:_laserBeam]) {
				projectile = _laserBeam;
				[_projectiles addObject:projectile];
				_laserBeam.visible = YES;
			}
			[_player shoot:cocosAngle];
			break;
			
			// rainbowgun
		case 6:			
			// Determine offset of location to projectile
			offX = location.x - _player.position.x; // -+ Corrections for laser shot
			offY = location.y - _player.position.y;
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width;
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + _player.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - _player.position.x;
			offRealY = realY - _player.position.y;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			
			projectile = nil;
			if (![self hasSpriteBody:_rainbow]) {
				projectile = _rainbow;
				[_projectiles addObject:projectile];
				_rainbow.visible = YES;
			}
			_rainbow.rotation = cocosAngle;
			[_player shoot:cocosAngle];
			break;
			
			// Minigun
		case 3:	
            
			// Determine offset of location to projectile
			offX = location.x - _player.position.x; // -+ Corrections for laser shot
			offY = location.y - _player.position.y;

			// Determine where we wish to shoot the projectile to
			realX = winSize.width;
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + _player.position.y + 50; //korrektur weg. waffenposition.
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - _player.position.x;
			offRealY = realY - _player.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 1200/1; // 480pixels/1sec = 0.4 = 480x10/4
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
            
            [_player shoot:cocosAngle];
            if (!minigunWarmedUp) {
                return;
            }
			
			projectile = [MiniGunShell projectile];
			projectile.anchorPoint = ccp(-9.0,0.5);
			projectile.position = ccp(_player.position.x-10+(arc4random()%10), _player.position.y-44-(arc4random()%10));
			projectile.tag = 2;
			[_projectiles addObject:projectile];
			[self addChild:projectile z:9];
			
			// bullets have a small randomness..
			realDest = ccp(realDest.x, realDest.y - 20 + (arc4random()%40));
			
			projectile.rotation = cocosAngle;
			[projectile runAction:[CCSequence actions:
								   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/minigun.caf"];
            }
			break;
			
			
			// Pumpgun
		case 4:			
			// Determine offset of location to projectile
			offX = location.x - _player.position.x; // -+ Corrections for laser shot
			offY = location.y - _player.position.y;
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width;
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + _player.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - _player.position.x;
			offRealY = realY - _player.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 1800/1; // 480pixels/1sec = 0.4 = 480x10/4
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			
			for (int i=0; i<=5; i++) {
				
				projectile = [PumpShell projectile];
				projectile.position = ccp(_player.position.x, _player.position.y-20);
				projectile.anchorPoint = ccp(-10.0,0.700000);
				projectile.tag = 2;
				[_projectiles addObject:projectile];
				[self addChild:projectile z:9];
				
				// bullets have a small randomness but still somehow calculated speading..
                int spreadRandRange = -100 + (arc4random()%200);
                if (i==0) {
                    spreadRandRange = 0;
                }
                if (i==5) {
                    spreadRandRange = 100;
                }
				realDest = ccp(realDest.x, realDest.y+spreadRandRange);
				
				int rand = (arc4random()%3);
				float flRand = (float) rand/10;
				projectile.rotation = cocosAngle;
				[projectile runAction:[CCSequence actions:
									   [CCMoveTo actionWithDuration:realMoveDuration+flRand position:realDest],
									   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
									   nil]];
				
				[self addBoxBodyForSprite:projectile];
			}
			
			projectile = nil;
			[_player shoot:cocosAngle];
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/pumpgun_shot.caf"];
            }
			
			if (_wheaponAmmo>=1) {
				[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(loadPumpgun)], nil]];
			}
			
			_wheaponReloaded = NO;
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			break;
			
			// rocketlauncher
		case 5:
			// Determine offset of location to projectile
			offX = location.x - _player.position.x; // -+ Corrections for laser shot
			offY = location.y - _player.position.y;
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width;
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + _player.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - _player.position.x;
			offRealY = realY - _player.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 300/1; // 480pixels/1sec
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			
			projectile = [Rocket projectile];
			projectile.anchorPoint = ccp(0.414894,0.614286); //same like rocketlauncher..
			projectile.position = ccp(_player.position.x-5, _player.position.y-45);
			
			projectile.tag = 2;
			[_projectiles addObject:projectile];
			[self addChild:projectile z:9];
			
			projectile.rotation = cocosAngle;
			[projectile runAction:[CCSequence actions:
								   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			
			[_player shoot:cocosAngle];
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/rocketlauncher.caf"];
            }
			
			[self unschedule:@selector(createRocketSmoke)];
			[self schedule:@selector(createRocketSmoke) interval:0.05];
			
			_wheaponReloaded = NO;
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.8f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			break;
			
			// tabascoshot
		case 7:
			projectile = [TabascoShots projectile];
			projectile.anchorPoint = ccp(-60.0/32, 10.0/32);
			projectile.position = ccp(_player.position.x+12, _player.position.y-15);
			projectile.tag = 2;
			[_projectiles addObject:projectile];
			
			// Determine offset of location to projectile
			offX = location.x - projectile.position.x;
			offY = location.y - projectile.position.y;
			[self addChild:projectile z:9];
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width + (projectile.contentSize.width/2);
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + projectile.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - projectile.position.x;
			offRealY = realY - projectile.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 350/1; // 480pixels/1sec
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			projectile.rotation = cocosAngle;
			
			[_player shoot:cocosAngle];
			
			// Move projectile to actual endpoint
			[projectile runAction:[CCSequence actions:
								   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/herb/pewpew.caf"];
            }
			
			_wheaponReloaded = NO;
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.25f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			break;
			
			// flygun shot
		case 8:
			
            for (int i=0; i<3; i++) {
                FlyGunShot *fly = [FlyGunShot projectile:_targets:location:i:_player];
                fly.position = ccp(_player.position.x+10, _player.position.y-45);
                fly.tag = 2;
                [_projectiles addObject:fly];
                [self addChild:fly z:9];
                [self addBoxBodyForSprite:(CCSprite *)fly];
            }
            
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/flygun.caf"];
            }
            
			_wheaponReloaded = NO;
            [_player shoot:0];
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			break;
			
            
			// übergun
		case 9:
            [self unschedule:@selector(ueberlightening)];
            [self schedule:@selector(ueberlightening) interval:0.4];
            [_background setOpacity:240];
            [_background runAction:[CCFadeTo actionWithDuration:0.4f opacity:100]];
            
			projectile = nil;
			[_player shoot:0];
			break;
            
            
            // bugspray
        case 10:			
			projectile = [SprayPoison projectile];
			projectile.position = ccp(_player.position.x+26, _player.position.y-21);
			projectile.tag = 2;
			[_projectiles addObject:projectile];
			
			[self addChild:projectile z:11];
			[_player shoot:cocosAngle];
            
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/bugspray.caf"];
            }
			
			// Move projectile to actual endpoint
			[projectile runAction:[CCSequence actions:
                                   [CCMoveTo actionWithDuration:0.5 position:ccp(projectile.position.x+50, projectile.position.y)],
                                   [CCMoveTo actionWithDuration:0.6 position:ccp(projectile.position.x+30, projectile.position.y)],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			break;
            
			// shitball
		default:
			projectile = [ShitBall projectile];
			projectile.anchorPoint = ccp(-60.0/32, 10.0/32);
			projectile.position = ccp(_player.position.x+12, _player.position.y-15);
			projectile.tag = 2;
			[_projectiles addObject:projectile];
            
			// Determine offset of location to projectile
			offX = location.x - projectile.position.x;
			offY = location.y - projectile.position.y;
			[self addChild:projectile z:9];
			
			// Determine where we wish to shoot the projectile to
			realX = winSize.width + (projectile.contentSize.width/2);
			ratio = (float) offY / (float) offX;
			realY = (realX * ratio) + projectile.position.y;
			realDest = ccp(realX, realY);
			
			// Determine the length of how far we're shooting
			offRealX = realX - projectile.position.x;
			offRealY = realY - projectile.position.y;
			length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
			velocity = 350/1; // 480pixels/1sec
			realMoveDuration = length/velocity;
			
			angleRadians = atanf((float)offRealY / (float)offRealX);
			angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			cocosAngle = -1 * angleDegrees;
			projectile.rotation = cocosAngle;
			
			[_player shoot:cocosAngle];
			
			// Move projectile to actual endpoint
			[projectile runAction:[CCSequence actions:
								   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
								   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
								   nil]];
			
            if ([LocalStorageManager isSFXEnabled]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/herb/pewpew.caf"];
            }
			
			_wheaponReloaded = NO;
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(reloadWheapon)], nil]];
			break;
	}
    
    // check if special gun has ammo
	if(_wheaponType != 0) {
		
        if (_wheaponAmmo>0)
        {
            // ueberweapon don't directly reduce ammo..
            if (_wheaponType != 9) {
                _wheaponAmmo -= 1;
            }
		}
		[self updateAmmoBar];
	}
	
	// Drop weapon if it rans out of ammo..
	if (_wheaponAmmo<=0 && _wheaponType != 0) {
        _dropWeaponDelayed = YES;
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.7],[CCCallFunc actionWithTarget:self selector:@selector(delayedDropWeapon)], nil]];
	}
	
	if (projectile) {
		[self addBoxBodyForSprite:projectile];
	}
}

- (void) warmupMinigun
{
    minigunWarmedUp = YES;
    [self unschedule:@selector(warmupMinigun)];
}

-(void) ueberlightening {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    if ([LocalStorageManager isSFXEnabled]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/ubergun.caf"];
    }
    
    CCSprite *lightning0 = [CCSprite spriteWithFile:@"uber-lightning0.png"];
    lightning0.position = ccp(winSize.width/2, winSize.height/2);
    lightning0.opacity = 0;
    CCSprite *lightning1 = [CCSprite spriteWithFile:@"uber-lightning1.png"];
    lightning1.position = ccp(winSize.width/2, winSize.height/2);
    lightning1.opacity = 0;
    CCSprite *lightning2 = [CCSprite spriteWithFile:@"uber-lightning2.png"];
    lightning2.position = ccp(winSize.width/2, winSize.height/2);
    lightning2.opacity = 0;
    CCSprite *lightning3 = [CCSprite spriteWithFile:@"uber-lightning3.png"];
    lightning3.position = ccp(winSize.width/2, winSize.height/2);
    lightning3.opacity = 0;
    
    [self addChild:lightning0 z:2];
    [self addChild:lightning1 z:25];
    [self addChild:lightning2 z:25];
    [self addChild:lightning3 z:8];
    
    [lightning0 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.3],
                           [CCCallFuncN actionWithTarget:self selector:@selector(vibrate)],
                           [CCFadeIn actionWithDuration:0.05],
                           [CCFadeOut actionWithDuration:0.05],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [lightning1 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.4],
                           [CCFadeIn actionWithDuration:0.05],
                           [CCCallFuncN actionWithTarget:self selector:@selector(killAllEnemies)],
                           [CCFadeOut actionWithDuration:0.05],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [lightning2 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.5],
                           [CCFadeIn actionWithDuration:0.05],
                           [CCFadeOut actionWithDuration:0.05],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [lightning3 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.6],
                           [CCFadeIn actionWithDuration:0.05],
                           [CCFadeOut actionWithDuration:0.05],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    _ueberlightening = YES;
    [self runAction:[CCSequence actions:
                            [CCDelayTime actionWithDuration:0.2],
                            [CCDelayTime actionWithDuration:0.5],
                            [CCCallFuncN actionWithTarget:self selector:@selector(ueberlighteningFinished)],
                            nil]];
    
    [_background runAction:[CCSequence actions:
                            [CCFadeOut actionWithDuration:0.2],
                            [CCDelayTime actionWithDuration:0.5],
                            [CCFadeIn actionWithDuration:0.2],
                            nil]];
    
    // reduce ammo
    _wheaponAmmo -= 1;
    _points += 500;
    [self updateAmmoBar];
    [self unschedule:@selector(ueberlightening)];
}

- (void) ueberlighteningFinished {
    _ueberlightening = NO;
}

- (void) createRocketSmoke {
	
	CCSprite *smoke = [CCSprite spriteWithSpriteFrameName:@"cloud_rocket.png"];
    smoke.anchorPoint = ccp(15/PTM_RATIO,0);
	smoke.position = ccp(_rocketPosition.x-15, _rocketPosition.y);
	smoke.scale = 0.2;
	smoke.rotation = arc4random()%360;
	[self addChild:smoke z:9];
	
	[smoke runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0f]];
	[smoke runAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.1f],
					  [CCMoveTo actionWithDuration:0.9f position:ccp(smoke.position.x-(arc4random()%20), smoke.position.y+50+arc4random()%40)], nil]];
    [smoke runAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.1f],
					  [CCScaleTo actionWithDuration:0.9 scale:0], nil]];
	[smoke runAction:[CCSequence actions:
                      [CCFadeOut actionWithDuration:1.0f],
                      [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                      nil]];
}

- (void) createDrugRainbow {
	
	CCSprite *rainbow = [CCSprite spriteWithSpriteFrameName:@"drugmode_rainbow.png"];
	rainbow.position = ccp([_player getContainerXPos]+7, _player.position.y-8);
	rainbow.scale = 0.5;
    rainbow.tag = kDrugRainbowTag;
    
    // in order to get the right rotation get last spawn position of rainbow piece
    if (_lastHerbLocation.y != 0) {
        // Guessed values:
        // Max 45° rotation
        // Distance max 10px (=45°)
        rainbow.rotation = 45/10*(_lastHerbLocation.y-rainbow.position.y); 
    }
    
	[environmentBatchNode addChild:rainbow z:9];
	[rainbow runAction:[CCScaleTo actionWithDuration:1.0 scale:3.0f]];
	[rainbow runAction:[CCSequence actions:
                        [CCMoveTo actionWithDuration:0.7f position:ccp(rainbow.position.x-150, rainbow.position.y)], nil]];
	[rainbow runAction:[CCSequence actions:
                        [CCFadeOut actionWithDuration:1.0f],
                        [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                        nil]];
    
    _lastHerbLocation = rainbow.position;
}


// Fire bullets as long as we are in MGMode.. can be used for the laser as well..
- (void) bulletMGMode
{	
	if (_bulletMGMode == YES)
    {
        // no mg mode for flygun, rocket and übergun, bugspray
        if (_wheaponType != 8 || _wheaponType != 9 || _wheaponType != 10) {
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.05f], [CCCallFunc actionWithTarget:self selector:@selector(bulletMGMode)], nil]];
        }
        
        // uebergun fires once.
        if (_wheaponType == 9) {
            _bulletMGMode = NO;
        }
        
        // Bail out if we are trying to shoot backwards
        if (_lastBulletLocation.x <= 70) return;
        
		// fire bullets
        if (_wheaponReloaded == YES) {
            [self handleCCTouchForShooting:_lastBulletLocation];
        }
        
        if (_wheaponType == 6) {
            if ([LocalStorageManager isSFXEnabled] && !_scheduleBulletModeSFX) {
                _scheduleBulletModeSFX = YES;
                [[SimpleAudioEngine sharedEngine] stopEffect:_rainbowNoise];
                _rainbowNoise = [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/rainbowgun.caf"];
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:0.2],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(reactivateBulletModeSFX)],
                                 nil]];
            }
        }
        
        if (_wheaponType == 2) {
            if ([LocalStorageManager isSFXEnabled] && !_scheduleBulletModeSFX) {
                _scheduleBulletModeSFX = YES;
                [[SimpleAudioEngine sharedEngine] stopEffect:_laserNoise];
                _laserNoise = [[SimpleAudioEngine sharedEngine] playEffect:@"audio/sfx/wpns/lasergun.caf"];
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:0.2],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(reactivateBulletModeSFX)],
                                 nil]];
            }
        }
	}
}

- (void) reactivateBulletModeSFX {
    _scheduleBulletModeSFX = NO;
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (_paused) {
		return;
	}
		
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    _lastBulletLocation = location;
    
    // Bail out if we are trying to shoot backwards
    if (location.x <= 70) {
        [self ccTouchesEnded:touches withEvent:event];
        return;
    };
    
    // handle aiming for rainbow, minigun, laser in shooting method
    // ignore bugspray, flygun and ubergun aiming
    if (_wheaponType == 2 || _wheaponType == 3 || _wheaponType == 6 || _wheaponType == 7 || _wheaponType == 8 || _wheaponType == 9 || _wheaponType == 10) {
        return;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float offX = location.x - _player.position.x+8;
    float offY = location.y - _player.position.y-13.5;
    float realX = winSize.width;
    float ratio = (float) offY / (float) offX;
    float realY = (realX * ratio) + _player.position.y-13.5;
    float offRealX = realX - _player.position.x+8;
    float offRealY = realY - _player.position.y-13.5;
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    [_player aimGun:cocosAngle];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (_paused) {
		return;
	}
	
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    _lastBulletLocation = location;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float offX = location.x - _player.position.x+8;
    float offY = location.y - _player.position.y-13.5;
    float realX = winSize.width;
    float ratio = (float) offY / (float) offX;
    float realY = (realX * ratio) + _player.position.y-13.5;
    float offRealX = realX - _player.position.x+8;
    float offRealY = realY - _player.position.y-13.5;
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    [_player aimGun:cocosAngle];

    _bulletMGMode = YES;
    [self bulletMGMode];
    
    if (_wheaponType == 3) {
        [self schedule:@selector(warmupMinigun) interval:0.1];
    }
	
	// TRACK CLICKS ON HERBERT (drop weapon)
	CGRect playerRect = CGRectMake(
								   _player.position.x-40, 
								   _player.position.y-40, 
								   80, 
								   80
								   );
	
	if (CGRectContainsPoint(playerRect, _lastBulletLocation)) {
		[self dropWeapon];
	}
}


- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (_paused) {
		return;
	}
	
	_bulletMGMode = NO;
	[_player stopShooting];
    
    // stop laser noise imediatly
    [[SimpleAudioEngine sharedEngine] stopEffect:_laserNoise];
	
	if (_wheaponType == 2) {
		_laserBeam.visible = NO;
		[self removeSpriteBody:_laserBeam];
	}
    
    if (_wheaponType == 3) {
        [self unschedule:@selector(warmupMinigun)];
		minigunWarmedUp = NO;
	}
	
	if (_wheaponType == 6) {
		_rainbow.visible = NO;
		[self removeSpriteBody:_rainbow];
	}
    
    // uebergun abort
    if (_wheaponType == 9 && !_ueberlightening)
    {
        [_background stopAllActions];
        [_background runAction:[CCFadeTo actionWithDuration:0.2f opacity:255]];
        [self unschedule:@selector(ueberlightening)];
        [_player stopShooting];
    }
}

- (void) addTutorialObjects {
    
    if (_tutorialMode && _tutorialLevel == 0) {
        // tutorial level 1: just drop coins
        [self addItem:[Coin item]];
    }
    
    int spawnTime = 3+(arc4random()%4);
    
    // recursive call
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:spawnTime],
                     [CCCallFuncN actionWithTarget:self selector:@selector(addTutorialObjects)],
                     nil]];
}


-(void)itemScheduler 
{
    if ((arc4random() % 2) == 0) {
		[self addItem];
	}
}


-(void)gameLogic:(ccTime)dt {
    
	[self addTarget];
    
    // spawn all randomly..
    float spawnTime = GAME_GAMELOGICINTERVAL+((float)(arc4random()%5)/10)-_increasedSpawnRate;
    //NSLog(@"spawn: %f", spawnTime);
    
    if (_difficultyLevel >= 2) {
        spawnTime = spawnTime-0.3;
    }
    
    if(_tutorialMode) {
        spawnTime = 2.0+(arc4random()%4);
        // bird showdown..
        if (_tutorialLevel == 3) {
            spawnTime = spawnTime-1.0;
        }
        
        // bird escape
        //if (_tutorialLevel == 2) {
        //    spawnTime = spawnTime;
        //}
    }
    
    [self unschedule:@selector(gameLogic:)];
    [self schedule:@selector(gameLogic:) interval:spawnTime];
	
	// add points per time
    if (!_tutorialMode) {
        _points += 25;
    }
	
    // TODO: here we do not really count seconds.. fix it!
    _gameTimeSeconds++;
    
    // within the tutorials do not spawn/unlock items
    if (_tutorialMode) {
        return;
    }

    // item up...
	// unlock new items
    NSArray *newItems = nil;
    
	switch (_itemLevel) {
		case 1:
			if (_points > 5000) {
				_itemLevel++;
                newItems = [NSArray arrayWithObjects:
                            @"TabascoShot",
                            @"FlyGun",
                            @"BugSpray",
                            nil];
			}
			break;
		case 2:
			if (_points > 10000) {
				_itemLevel++;
				newItems = [NSArray arrayWithObjects:
                            @"Kalaschnikov",
                            @"PumpGun",
                            @"LaserGun",
                            nil];
			}
			break;
		case 3:
			if (_points > 20000) {
				_itemLevel++;
				newItems = [NSArray arrayWithObjects:
                            @"MiniGun",
                            @"RainbowGun",
                            @"RocketLauncher",
                            nil];
			}
			break;
        case 4:
			if (_points > 40000) {
				_itemLevel++;
                newItems = [NSArray arrayWithObjects:
                            @"UberGun",
                            nil];
			}
			break;
		default:
			break;
	}
    
    // new item to add..
    if (newItems)
    {
        NSString *item = [newItems objectAtIndex:arc4random()%[newItems count]];
        NSArray *items = [LocalStorageManager getUnlockedItems];
        
        //NSLog(@"check item %@ against %@", item, items);
        BOOL itemFound = NO;
        for (NSString *itemName in items)
        {
            if ([itemName isEqualToString:item])
            {
                itemFound = YES;
                break;
            }
        }
        
        if (!itemFound)
        {
            NSMutableArray *newItems = [NSMutableArray arrayWithArray:items];
            [newItems addObject:item];
            [LocalStorageManager setUnlockedItems:newItems];
            
            // spawn new item directly once..
            [self addItem:[(Item *)NSClassFromString(item) item]:YES];
            [self flashMessage:1];
        }
    }
}

// if the application loses focus pause game! RESUME
- (void)pauseIngameState {
    
	if (!_paused) {
		[self gamePauseMenu:nil];
        [_pauseBtn runAction:[CCFadeOut actionWithDuration:0.3]];
	}
}

- (void) clearStage {
    
    if (_pointsBar.opacity) {
        [_pointsBar runAction:[CCFadeOut actionWithDuration:0.3]];
    }
    
    // TODO remove clouds and particles...
    for (CCSprite *item in _items) {
        item.tag = kRemoveObjectTag;
    }
    for (CCSprite *target in _targets) {
        target.tag = kRemoveObjectTag;
    }
    
    [self disableGameControlls];
}

- (void)gamePause {
    
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    [self pauseSchedulerAndActions];
    
    if (_drugSound) {
        [_drugSound pause];
    }
    
    for(id item in self.children) {
        // UPDATE all stage objects..
        [item pauseSchedulerAndActions];
    }
}

- (void)gamePauseMenu: (id)sender {
	
    if (!_paused) {
        
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		_pauseMenuContinue.visible = YES;
		_pauseMenuRestart.visible = YES;
		_pauseMenuMain.visible = YES;
        _pauseMenuSponsor.visible = YES;
        _pauseBtn.visible = NO;
		_paused = YES;
		_pauseMenu = [CCSprite spriteWithFile:@"mm_pause_bg_en.png"];
		_pauseMenu.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:_pauseMenu z:48];
        
        NSString *lang = [LocalStorageManager getLang];
        CCSprite *_header = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mm_nav_pause_%@.png",lang]];
		[_header setPosition:ccp(winSize.width/2, 280)];
		[_pauseMenu addChild:_header];
        
        // smooth fadein..
		[_pauseMenu runAction:[CCFadeIn actionWithDuration:0.2]];
		[_pauseMenuSponsor runAction:[CCFadeIn actionWithDuration:0.2]];
        [_pauseMenuContinue runAction:[CCFadeIn actionWithDuration:0.2]];
		[_pauseMenuRestart runAction:[CCFadeIn actionWithDuration:0.2]];
		[_pauseMenuMain runAction:[CCFadeIn actionWithDuration:0.2]];
		[self gamePause];
        
        // move up/down ani..
        id move = [CCMoveBy actionWithDuration:2 position:ccp(0,5)];
        id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
        id move_ease_back = [move_ease reverse];
        id seq1 = [CCSequence actions: move_ease, [CCDelayTime actionWithDuration:0.1f], move_ease_back, [CCDelayTime actionWithDuration:0.1f], nil];	
        [_pauseMenuSponsor runAction: [CCRepeatForever actionWithAction:seq1]];
	}
}

- (void) gameSponsorMenu: (id)sender {
    
    // SPONSORING IS NOT YET ENABLED
    //[[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.3 scene:[SponsorOverlay scene]]];
}

// if you come back and you were in paused mode.. pause..
- (void)onEnter
{    
    if (_paused) {
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.3],[CCCallFuncN actionWithTarget:self selector:@selector(gamePause)], nil]];
    }
    
    [super onEnter];
}

- (void) gameRestart: (id)sender
{
    [self clearScene];
    [LocalStorageManager loadMenuAssets];
    
	[[CCDirector sharedDirector] replaceScene:[ReloadMainScene scene]];
}

- (void)gameMainMenu: (id)sender
{
    // if we start the first time and we wanna skip the tutorial by clicking the [X]
    // EDIT: we set the first start and go back to mainmenu..
    if (_tutorialMode && [LocalStorageManager isFirstStart]) {
        [LocalStorageManager setFirstStart];
        //[self gameRestart:nil];
        //return;
    }
    
    [LocalStorageManager loadMenuAssets];
    
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] replaceScene:[MainMenuScene animatedScene]];
}
- (void) gameResume: (id)sender
{
	if (!_paused) {
		return;
	}
	
    [_pauseMenuSponsor stopAllActions];
    _pauseMenuSponsor.visible = NO;
	_pauseMenuContinue.visible = NO;
	_pauseMenuRestart.visible = NO;
	_pauseMenuMain.visible = NO;
    _pauseBtn.visible = YES;
    _pauseBtn.opacity = 255;
	
	_paused = NO;
	[self removeChild:_pauseMenu cleanup:YES];
	_pauseMenu = nil;
    
	// resume
    [self resumeSchedulerAndActions];
    
    if (_drugSound) {
        [_drugSound play];
    } else {
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    }
    
    for(id item in self.children) {
        // UPDATE all stage objects..
        [item resumeSchedulerAndActions];
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if (_paused) {
        return;
    }
    
    // beschleunigung..
    float kFilterFactor = 0.07;
    // max speed..
    float speedLimit = 28;
    
    // check if weapon or not and fly faster or not..
    if (_wheaponType != 0) {
        kFilterFactor = 0.045;
    }
    
    // fix moved accel-zero point -0.40 = (-0.65-(0.25/0.90))
    float accelY = (acceleration.x-0.40) * kFilterFactor + (1- kFilterFactor)*_lastAccelY;
    float accelDiff = acceleration.x-accelY;
    
    // tilting..
    if (accelDiff < -0.10+0.40) {
        if (!_tilting) {
            [_player tiltDown];
            _tilting = YES;
        }
    }
    else if (accelDiff > 0.20+0.40) {
        if (!_tilting) {
            [_player tiltUp];
            _tilting = YES;
        }
    }
    else {
        if (_tilting) {
            [_player stopTilting];
            _tilting = NO;
        }
    }
    
    //[_ammoBar setString:[NSString stringWithFormat:@"%f - %f", accelDiff, accelY]];
    
    //  max accel.. -0.40 for moved-zero point..
    if (accelY < -0.90-0.40) {
        accelY = -0.90-0.40;
    }
    // min accel..
    if (accelY > -0.20-0.40) {
        accelY = -0.20-0.40;
    }
    
    _lastAccelY = accelY;
    
    // Nullpunkt: -0.65;
    // -0.90 max, min -0.25
    //float percent = 100-(100/0.65*((accelY*-1)-0.25));
    // take into account moved-zero point: -0.40 / 0.20
    float percent = 100-(100/(0.65+0.20)*((accelY*-1)-(0.25)));
    
    //float playerPos = 320/100*percent;
    float playerPos = ((320)/100*percent)+100;
    
    // max speed..
    float speedDiff = _player.position.y-playerPos;
    
    //[_ammoBar setString:[NSString stringWithFormat:@"%f", speedDiff]];
    
    // tilt down
    if (speedDiff > speedLimit) {
        playerPos = _player.position.y-speedLimit;
    }
    // tilt up
    if (speedDiff < -speedLimit) {
        playerPos = _player.position.y+speedLimit;
    }
    
    [_player updatePosition:playerPos];
    //[_player setPosition:ccp(_player.position.x, playerPos)];
    
}

// on "init" you need to initialize your instance
- (id) init {
    
	if(( self=[super init] )) {

        
        _increasedSpawnRate = 0;
        
        // TODO: remove unused menu frames..
        //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
		//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
        
        // load assets if not already done so!
        [LocalStorageManager unloadMenuAssets];
        [LocalStorageManager loadIngameAssets];
        
		// If game pauses or gets inactive..
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(pauseIngameState)
		 name:@"pauseIngameState"
		 object:nil];
        
        _isIphoneSimulator = [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        [self cacheAnimations];
		
		_player = [Herbert node];
		_player.position = ccp(winSize.width+40, (winSize.height/2)-6+20);
        _playerInitPos = ccp(40, (winSize.height/2)-6+20);
		
		_health = GAME_INITIAL_HEALTH;
		_maxHealth = GAME_MAX_HEALTH;
		_wheaponReloaded = YES;
		_bulletMGMode = NO;
		
		// gamespeed..
		_points = GAME_INITIAL_POINTS;
        _pointsDisplay = GAME_INITIAL_POINTS;
		_itemLevel = GAME_INITIAL_ITEMLEVEL;
		_difficultyLevel = GAME_INITIAL_DIFFICULTYLEVEL;
		_gameTimeSeconds = GAME_INITIAL_GAMETIMESECONDS;
		
		_wheaponAmmo = GAME_INITIAL_AMMO;
		_itemWeight = GAME_INITIAL_ITEMWEIGHT;
        
		_wheaponType = GAME_INITIAL_WEAPON;
		[_player changeWeapon:GAME_INITIAL_WEAPON];
        [self changeWeaponAmmo];
        
        _lastAccelY = -0.89;
        
        //[self enableLSDMode];
        
        _tutCloseBtn = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"tut_x.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"tut_x.png"] target:self selector:@selector(gameMainMenu:)];
        _tutCloseBtn.opacity = 0;
        [_tutCloseBtn setIsEnabled:NO];
        [_tutCloseBtn setVisible:NO];
		
		// PAUSE BUTTON
		_pauseBtn = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_pause.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_pause.png"] target:self selector:@selector(gamePauseMenu:)];
        _pauseBtn.opacity = 0;
        [_pauseBtn setIsEnabled:NO];
        
        NSString *lang = [LocalStorageManager getLang];
        NSString *menu_continue = @"continue";
        NSString *menu_restart = @"restart";
        NSString *menu_main = @"mainmenu";
        
        if ([lang isEqualToString:@"de"]) {
            menu_continue = @"weiter";
            menu_restart = @"neustart";
            menu_main = @"hauptmenü";
        }
        if ([lang isEqualToString:@"ch"]) {
            menu_continue = @"witermachä";
            menu_restart = @"nöistart";
            menu_main = @"houptmenü";
        }
        
        _pauseMenuContinue = [SFXMenuItemFont itemFromString:menu_continue target: self selector:@selector(gameResume:)];
		_pauseMenuContinue.color = ccc3(0,0,0);
        
        _pauseMenuRestart = [SFXMenuItemFont itemFromString:menu_restart target: self selector:@selector(gameRestart:)];
		_pauseMenuRestart.color = ccc3(0,0,0);
        
        _pauseMenuMain = [SFXMenuItemFont itemFromString:menu_main target: self selector:@selector(gameMainMenu:)];
		_pauseMenuMain.color = ccc3(0,0,0);
        
        _pauseMenuSponsor = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_pause_herb.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_pause_herb.png"] target:self selector:@selector(gameSponsorMenu:)];
		
		CCMenu *menu = [CCMenu menuWithItems:_pauseBtn, _pauseMenuContinue, _pauseMenuRestart, _pauseMenuMain, _pauseMenuSponsor, _tutCloseBtn, nil];
		menu.position = ccp(0,0);
		//
        _tutCloseBtn.position = ccp(winSize.width-_tutCloseBtn.contentSize.width/2,winSize.height-_tutCloseBtn.contentSize.height/2);
		_pauseBtn.position = ccp(68, winSize.height-(_pauseBtn.contentSize.height/2));
		_pauseMenuContinue.position = ccp(winSize.width/2, winSize.height/2+55);
		_pauseMenuMain.position = ccp(winSize.width/2, winSize.height/2+24);
		_pauseMenuRestart.position = ccp(winSize.width/2, winSize.height/2-8);
        _pauseMenuSponsor.position = ccp(winSize.width/2-4, 70);
		_pauseMenuContinue.visible = NO;
		_pauseMenuRestart.visible = NO;
		_pauseMenuMain.visible = NO;
        _pauseMenuSponsor.visible = NO;
		
		// Keep track over enemies and bullets
		_items = [[NSMutableArray alloc] init];
		_targets = [[NSMutableArray alloc] init];
		_projectiles = [[NSMutableArray alloc] init];
		
		_healthbarRaster = [CCSprite spriteWithSpriteFrameName:@"health_bar.png"];
		_healthbarRaster.position = ccp(29, 308);
        _healthbarRaster.opacity = 0;
		
		_healthBar = [CCSprite spriteWithFile:@"health_life.png"];
        _healthBar.opacity = 0;
		_healthBar.position = ccp(30, 308);
		
		_ammoBar = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(100,50) alignment:UITextAlignmentLeft fontName:@"akaDylan Plain" fontSize:13];
		_ammoBar.color = ccc3(0,0,0);
        _ammoBar.opacity = 0;
		_ammoBar.position = ccp(288, winSize.height-28);
		
		_pointsBar = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentRight fontName:@"akaDylan Plain" fontSize:13];
		_pointsBar.color = ccc3(0,0,0);
        _pointsBar.opacity = 0;
		_pointsBar.position = ccp(winSize.width-250, winSize.height-28);
		
		_laserBeam = [[CCSprite spriteWithSpriteFrameName:@"lasershot.png"] retain];
		_laserBeam.anchorPoint = ccp(-32/_laserBeam.contentSize.width,
									 ((_laserBeam.contentSize.height/2)+5)/_laserBeam.contentSize.height);
		_laserBeam.visible = NO;
		_laserBeam.tag = 5;
		[self addChild:_laserBeam z:9];
		
        if ([LocalStorageManager isSFXEnabled]) {
            [[SimpleAudioEngine sharedEngine] preloadEffect:@"audio/sfx/wpns/lasergun.caf"];
        }
		
		_rainbow = [[CCSprite spriteWithSpriteFrameName:@"rainbowgun_shot.png"] retain];
        _rainbow.anchorPoint = ccp(-30/_rainbow.contentSize.width,
                                   0.5);
		_rainbow.visible = NO;
		_rainbow.tag = 5;
		[self addChild:_rainbow z:9];
		
		// box2d
		b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
		bool doSleep = false;
		_world = new b2World(gravity, doSleep);
		
		// Create contact listener
		_contactListener = new MyContactListener();
		_world->SetContactListener(_contactListener);
		
        // draw gradient background..
		_background = [LayerGradientAnim layerWithColor:ccc4(246,253,255,255)
                                             fadingTo:ccc4(173,224,245,255)
                                          alongVector:ccp(0,1)];
        
        // Enable debug draw
        if (DISPLAY_DEBUGHITAREAS) {
            _debugDraw = new GLESDebugDraw( PTM_RATIO );
            _world->SetDebugDraw(_debugDraw);
            uint32 flags = 0;
            flags += b2DebugDraw::e_shapeBit;
            _debugDraw->SetFlags(flags);
            
            // hide background
            _background.visible = NO;
        }
        
        //[_background newColorFade:(ccColor3B){100,30,70}:(ccColor3B){0,255,100}:1];
        _background.position = ccp(0, 0);
		
		[self addChild:_background z:0];
		[self addChild:_ammoBar z:18];
		[self addChild:_healthBar z:18];
		[self addChild:_healthbarRaster z:18];
		[self addChild:_pointsBar z:18];
		[self addChild:menu z:50];
		[self addChild:_player z:20];
        
        // performance sprite
        environmentBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"clct_ingame.png"];
        objectBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"clct_bugsgads.png"];
        particleBatchNode = [CCParticleBatchNode particleBatchNodeWithTexture:[objectBatchNode texture] capacity:10 useQuad:YES additiveBlending:NO];
        
        [self addChild:particleBatchNode z:12];
        [self addChild:environmentBatchNode z:2];
        [self addChild:objectBatchNode z:10];
        
        // prepare emitters for death anis..
        [ParticleEffects initEmitters:particleBatchNode];
		
		// add herbert boxbody...
		// box body can only be applied on existing elements attached to an object (to stage?) with some dimmensions!
		[self addBoxBodyForSprite:_player];
		
		[self updateHealthBar];
		[self updateAmmoBar];
        _ammoLabel.opacity = 0;
        
        // TODO: remove
        // stress test
        //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:4],[CCCallFuncN actionWithTarget:self selector:@selector(gameRestart:)], nil]];
	}
	return self;
}

- (void) cacheAnimations
{
    [self cacheAnimation:@"gilbert0":@"buggilbert0_":8];
    [self cacheAnimation:@"gilbert1":@"buggilbert1_":8];
    [self cacheAnimation:@"fuckbutton0":@"fuckbutton0_":8];
    [self cacheAnimation:@"fuckbutton1":@"fuckbutton1_":8];
    [self cacheAnimation:@"fuckbutton2":@"fuckbutton2_":8];
    [self cacheAnimation:@"ladybug0":@"ladybug0_":8];
    [self cacheAnimation:@"ladybug1":@"ladybug1_":8];
    [self cacheAnimation:@"flyfred0":@"flyfred0_":8];
    [self cacheAnimation:@"flyfred1":@"flyfred1_":8];
    [self cacheAnimation:@"flyrobert0":@"flyrobert0_":8];
    [self cacheAnimation:@"flyrobert1":@"flyrobert1_":8];
    [self cacheAnimation:@"flysina0":@"flysina0_":8];
    [self cacheAnimation:@"flysina1":@"flysina1_":8];
    [self cacheAnimation:@"buglina0":@"buglina0_":8];
    [self cacheAnimation:@"buglina1":@"buglina1_":8];
    [self cacheAnimation:@"bugoona0":@"bugoona0_":8];
    [self cacheAnimation:@"bugoona1":@"bugoona1_":8];
    [self cacheAnimation:@"flybob0":@"flybob0_":8];
    [self cacheAnimation:@"flybob1":@"flybob1_":8];
    [self cacheAnimation:@"bibi0":@"bibi0_":8];
    [self cacheAnimation:@"bibi0_shit":@"bibi0_shit":8];
    [self cacheAnimation:@"bibi1":@"bibi1_":8];
    
    // herb
    [self cacheAnimation:@"herbert":@"herb_body_":8];
    [self cacheAnimation:@"herbert_up":@"ani_herb_up_":8];
    [self cacheAnimation:@"herbert_down":@"ani_herb_down_":8];
    [self cacheAnimation:@"herbert_prot":@"herb_body_prot_":8];
    [self cacheAnimation:@"herbert_gover":@"ani_herb_gover":8];
    [self cacheAnimation:@"herbert_drugz":@"herb_drugz":16];
    [self cacheAnimation:@"herbert_trunk":@"snout4":8];
    [self cacheAnimation:@"herbert_legs_norm2":@"herb_leg_norm2_":8];
    [self cacheAnimation:@"herbert_legs_norm":@"herb_leg_norm_":8];
    [self cacheAnimation:@"herbert_legs_wbg2":@"herb_leg_wbg2_":8];
    [self cacheAnimation:@"herbert_legs_wbg":@"herb_leg_wbg1_":8];
    [self cacheAnimation:@"herbert_legs_wsm2":@"herb_leg_wsm2_":8];
    [self cacheAnimation:@"herbert_legs_wsm":@"herb_leg_wsm1_":8];
    
    // items
    [self cacheAnimation:@"item_prot":@"prot_":8];
    [self cacheAnimation:@"item_star":@"star":8];
    [self cacheAnimation:@"item_shit":@"caposhito":8];
    [self cacheAnimation:@"item_coin":@"ring":8];
}

- (void) cacheAnimation:(NSString *)name: (NSString *)prefix: (int)framecount
{
    CCAnimation *animation = [CCAnimation animation];
    for(int i = 1; i <= framecount; ++i)
    {
        [animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%i.png", prefix, i]]];
    }
    [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:name];
}

- (void) enemyRemoved
{
    // in tutorial 3 update points if you didn't touch a target
    if (_tutorialLevel == 2) {
        _points -= 1;
    }
}

- (void) tut4AddWpn1 {
    [self addItem:[Kalaschnikov item]];
}
- (void) tut4AddWpn2 {
    [self addItem:[LaserGun item]];
}
- (void) tut4:(TutorialBriefing *)sender {
    // skip
    //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCCallFuncN actionWithTarget:self selector:@selector(initGameTutorial)], nil]];
    
    [sender hide];
    if ([LocalStorageManager isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_loop0.caf" loop:YES];
    }
    // initial position
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_player updatePosition:(winSize.height/2)-6+20:40:0.1:1.8];
    _lastAccelY = -0.89;
    
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:1.9],
                     [CCCallFuncN actionWithTarget:self selector:@selector(enableGameControlls)],
                     nil]];
    
    // show weapon ammo and score..
    [_pointsBar runAction:[CCFadeIn actionWithDuration:0.3]];
    
    // init weapon
    _wheaponType = 4;
    _wheaponAmmo = 999;
    
    // 10 enemies to kill..
    _pointsDisplay = 11;
    _points = 10;
    
    // spawn delayed items
    // 1. kalaschnikov, 2. laser
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:8.0],
                     [CCCallFuncN actionWithTarget:self selector:@selector(tut4AddWpn1)],
                     [CCDelayTime actionWithDuration:16.0],
                     [CCCallFuncN actionWithTarget:self selector:@selector(tut4AddWpn2)],
                     nil]];
}

- (void) finishTut3 {
    // remove gun..
    for(id item in _items) {
        [objectBatchNode removeChild:item cleanup:YES];
    }
    
    [self disableGameControlls];
    [_items removeAllObjects];
    
    _wheaponType = 4;
    [_player changeWeapon:4];
    [self changeWeaponAmmo:4];
    
    // next tut..
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.3],
                     [CCCallFuncN actionWithTarget:self selector:@selector(initGameTutorial)],
                     nil]];
    
}
- (void) tut3:(TutorialBriefing *)sender {
    // skip tutorial
    //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCCallFuncN actionWithTarget:self selector:@selector(initGameTutorial)], nil]];
    
    [sender hide];
    if ([LocalStorageManager isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_loop0.caf" loop:YES];
    }
    
    _player.position = _playerInitPos;
    [self enableGameControlls];
    [_pointsBar runAction:[CCFadeIn actionWithDuration:0.3]];
    // 5 bibis to escape..
    _pointsDisplay = 6;
    _points = 5;
    
}
- (void) tut2:(TutorialBriefing *)sender {
    // skip tutorial
    //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCCallFuncN actionWithTarget:self selector:@selector(initGameTutorial)], nil]];
    
    [sender hide];
    if ([LocalStorageManager isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_loop0.caf" loop:YES];
    }
    
    _player.position = _playerInitPos;
    [self enableGameControlls];
    [_pointsBar runAction:[CCFadeIn actionWithDuration:0.3]];
    // 5 targets to shoot..
    _pointsDisplay = 6;
    _points = 5;
}
- (void) tut1:(TutorialBriefing *)sender {
    // skip tutorial
    //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCCallFuncN actionWithTarget:self selector:@selector(initGameTutorial)], nil]];
    
    [sender hide];
    if ([LocalStorageManager isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"audio/music/bg_loop0.caf" loop:YES];
    }
    
    _player.position = _playerInitPos;
    [self enableGameControlls];
    [self addTutorialObjects];
    
    // ground clouds..
    [self repeatingGroundClouds];
    
    [_pointsBar runAction:[CCFadeIn actionWithDuration:0.3]];
    // 5 items to take..
    _pointsDisplay = 6;
    _points = 5;
    
}
-(void) initGameTutorial {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // clear old objects..
    [self clearStage];
    
    [_tutCloseBtn setIsEnabled:YES];
    [_tutCloseBtn setVisible:YES];
    [_tutCloseBtn runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:0.3],
                                 [CCFadeIn actionWithDuration:0.3],
                                 nil]];
    
    // start tutorial..
    if (!_tutorialMode) {
        _tutorialMode = YES;
        _tutorialLevel = 0;
        
        // center pointsBar..
        [self removeChild:_pointsBar cleanup:YES];
        _pointsBar = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(100,50) alignment:UITextAlignmentCenter fontName:@"akaDylan Plain" fontSize:13];
		_pointsBar.color = ccc3(0,0,0);
        _pointsBar.opacity = 0;
		_pointsBar.position = ccp(winSize.width/2, winSize.height-28);
        [self addChild:_pointsBar z:18];
        
        // drop weapon if one is set
        _wheaponType = 0;
		[_player changeWeapon:0];
        
    } else {
        _bulletMGMode = NO;
        _tutorialLevel += 1;
    }
    
    if (_tutorialLevel == 4) {
        // last tutorial finished!
        [self stopAllActions];
        _scheduleBulletModeSFX = NO;
        [[SimpleAudioEngine sharedEngine] stopEffect:_laserNoise];
        _laserBeam.visible = NO;
    }
    
    tut = [TutorialBriefing initStep:_tutorialLevel:self];
    tut.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:tut z:60];
}

-(void) initGameStartCountdown {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float pause = 0.1;
    float fadeInSpeed = 0.5;
    
    // DEBUG countdown
    //_isIphoneSimulator = NO;
    
    CCSprite *countdown3 = [CCSprite spriteWithSpriteFrameName:@"cntdwn_3.png"];
    CCSprite *countdown2 = [CCSprite spriteWithSpriteFrameName:@"cntdwn_2.png"];
    CCSprite *countdown1 = [CCSprite spriteWithSpriteFrameName:@"cntdwn_1.png"];
    CCSprite *countdown0 = [CCSprite spriteWithSpriteFrameName:@"cntdwn_0.png"];
    
    countdown3.position = ccp(winSize.width/2, winSize.height/2);
    countdown2.position = ccp(winSize.width/2, winSize.height/2);
    countdown1.position = ccp(winSize.width/2, winSize.height/2);
    countdown0.position = ccp(winSize.width/2, winSize.height/2);
    
    countdown3.opacity = 0;
    countdown2.opacity = 0;
    countdown1.opacity = 0;
    countdown0.opacity = 0;
    countdown3.scale = 0.8;
    countdown2.scale = 0.8;
    countdown1.scale = 0.8;
    countdown0.scale = 0.8;
    
    [self addChild:countdown3 z:21];
    [self addChild:countdown2 z:21];
    [self addChild:countdown1 z:21];
    [self addChild:countdown0 z:21];
    
    [_pauseBtn setIsEnabled:YES];
    
    [_pointsBar runAction:[CCFadeIn actionWithDuration:2]];
    [_ammoBar runAction:[CCFadeIn actionWithDuration:2]];
    [_pauseBtn runAction:[CCFadeIn actionWithDuration:2]];
    [_healthBar runAction:[CCFadeIn actionWithDuration:2]];
    [_healthbarRaster runAction:[CCFadeIn actionWithDuration:2]];
    [_ammoLabel runAction:[CCFadeIn actionWithDuration:2]];
    
    if (!_isIphoneSimulator) {
    [countdown3 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause],
                           [CCFadeIn actionWithDuration:fadeInSpeed/2],
                           nil]];
    [countdown3 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.2],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.0],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [countdown2 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause*2+fadeInSpeed],
                           [CCFadeIn actionWithDuration:fadeInSpeed/2],
                           nil]];
    [countdown2 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause*2+fadeInSpeed],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.2],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.0],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [countdown1 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause*3+fadeInSpeed*2],
                           [CCFadeIn actionWithDuration:fadeInSpeed/2],
                           nil]];
    [countdown1 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause*3+fadeInSpeed*2],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.2],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.0],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    [countdown0 runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:pause*4+fadeInSpeed*3],
                           [CCFadeIn actionWithDuration:fadeInSpeed/2],
                           nil]];
    [countdown0 runAction:[CCSequence actions:
                           
                           [CCDelayTime actionWithDuration:0.5],
                           
                           [CCDelayTime actionWithDuration:pause*4+fadeInSpeed*3],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.2],
                           [CCScaleTo actionWithDuration:fadeInSpeed/2 scale:1.0],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           [CCCallFuncN actionWithTarget:self selector:@selector(enableGameControlls)],
                           nil]];
    } else {
        // if iphonesimulator.. skip this
        [self enableGameControlls];
    }
    
    // init background sound (level up soundloops..)
    // TODO: check preloading correct?
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:[NSString stringWithFormat:@"audio/music/bg_loop%i.caf",(_difficultyLevel)]];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"audio/music/bg_loop%i.caf",(_difficultyLevel)] loop:NO];
    
    if (![LocalStorageManager isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
    }
    
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];
        
    if (!_isIphoneSimulator) {
        // Fade camera to Herb..
        _gameSpeed = 3;
        [_player runAction:[CCSequence actions:
                            [CCDelayTime actionWithDuration:pause*2+fadeInSpeed],
                            [CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:fadeInSpeed*5 position:ccp(40, _player.position.y)]],
                            nil]];

    } else {
        // if iphonesimulator skip fadein
        [_player setPosition:ccp(40, _player.position.y)];
    }
    
    [self repeatingGroundClouds];
}

-(void) enableGameControlls {
    
    _gameSpeed = GAME_INITIAL_GAMESPEED;
    [self speedUpdate];
    
    if (!_tutorialMode || (_tutorialMode && _tutorialLevel != 0)) {
        self.isTouchEnabled = YES;
    } 
    
    self.isAccelerometerEnabled = YES;
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 30)];
    
    if (!_tutorialMode || (_tutorialMode && _tutorialLevel != 0)) {
        [self schedule:@selector(gameLogic:) interval:GAME_GAMELOGICINTERVAL]; 
    }
    
    if (!_tutorialMode)
    {
        [self schedule:@selector(itemScheduler) interval:5.0];
    }
    [self schedule:@selector(addParticle) interval:0.6];
    [self schedule:@selector(addCloud) interval:2.9];
    [self schedule:@selector(update:)];
    
    // DEBUG Umeschwänglerei..
#if GAME_DEBUGSCHWAENGLE == 1
    [self debugSchwaengle];
#endif
}

-(void) disableGameControlls {
    
    self.isTouchEnabled = NO;
    self.isAccelerometerEnabled = NO;
    
    [self unschedule:@selector(gameLogic:)]; 
    [self unschedule:@selector(addParticle)];
    [self unschedule:@selector(addCloud)];
    [self unschedule:@selector(update:)];
    [self unschedule:@selector(itemScheduler)];
}

// TODO: only for debugging and movie capturing..
-(void) debugSchwaengle {
    
    float posY1 = arc4random()%100+170;
    float posY2 = arc4random()%60+90;
    
    //NSLog(@"%f %f", posY1-_player.position.y, posY1-posY2);
    [_player stopTilting];
    
    if (posY1-posY2 > 80) {
        [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:2],
                     [CCCallFuncN actionWithTarget:self selector:@selector(debugTiltDown)],
                     nil]];
    }
    
    if (posY1-_player.position.y> 80) {
        [_player tiltUp];
    }
    
	[_player runAction: [CCSequence actions:
						 [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2 position:ccp(40, posY1)]], 
                         [CCCallFuncN actionWithTarget:_player selector:@selector(stopTilting)],
						 [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2 position:ccp(40, posY2)]],
						 [CCCallFuncN actionWithTarget:self selector:@selector(debugSchwaengle)], 
                         nil]];
}

-(void) debugTiltDown {
    [_player tiltDown];
}

-(void)repeatingGroundClouds {

    CGSize winSize = [[CCDirector sharedDirector] winSize];
	GroundCloud *cloud = [GroundCloud cloud];
    [environmentBatchNode addChild:cloud z:cloud.index];
	cloud.position = ccp(winSize.width+cloud.contentSize.width/2, cloud.contentSize.height/2);
	
	// recursion..
	[cloud runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:cloud.speed/_gameSpeed position:ccp(-cloud.contentSize.width/2, cloud.contentSize.height/2)],
                      [CCCallFuncN actionWithTarget:self selector:@selector(removeCloud:)],
                      nil]];
    
    // spawn next..
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:(cloud.speed/_gameSpeed)/2],
                     [CCCallFuncN actionWithTarget:self selector:@selector(repeatingGroundClouds)],
                     nil]];
}

- (void) backgroundMusicFinished
{
    // level up:
    // increase gamespeed in a fix timeframe and unlock new enemies..
	if (_difficultyLevel<GAME_MAX_DIFFICULTYLEVEL) {
		
		_difficultyLevel++;
		
		switch (_difficultyLevel) {
			
            case 2:
				_gameSpeed = 1.5;
                _increasedSpawnRate = 0.2;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 4:
				_gameSpeed = 2.0;
                _increasedSpawnRate = 0.3;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 6:
				_gameSpeed = 2.5;
                _increasedSpawnRate = 0.35;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 8:
				_gameSpeed = 2.75;
                _increasedSpawnRate = 0.4;
                [self flashMessage:0];
                [self speedUpdate];
				break;
			case 10:
				_gameSpeed = 3.0;
                _increasedSpawnRate = 0.45;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 12:
				_gameSpeed = 3.25;
                _increasedSpawnRate = 0.5;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 14:
				_gameSpeed = 3.5;
                _increasedSpawnRate = 0.55;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 16:
				_gameSpeed = 3.75;
                _increasedSpawnRate = 0.6;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 18:
				_gameSpeed = 4.0;
                _increasedSpawnRate = 0.65;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 20:
				_gameSpeed = 4.25;
                _increasedSpawnRate = 0.7;
                [self flashMessage:0];
                [self speedUpdate];
				break;
            case 22:
				_gameSpeed = 4.5;
                _increasedSpawnRate = 0.75;
                [self flashMessage:0];
                [self speedUpdate];
				break;
			default:
				break;
		}
        
        // last level has infinite background loop
        BOOL loop = NO;
        if (_difficultyLevel==GAME_MAX_DIFFICULTYLEVEL-1) {
            loop = YES;
        }
        else {
            [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:[NSString stringWithFormat:@"audio/music/bg_loop%i.caf",((_difficultyLevel/2)+1)]];
        }
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"audio/music/bg_loop%i.caf",(_difficultyLevel/2)] loop:loop];
	}
}

- (void) draw
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
}

// here we remove some stuff already bevore we leave the scene or restart a game
- (void) clearScene
{
    if (_drugSound) {
        [_drugSound stop];
        [_drugSound release];
        _drugSound = nil;
    }
    
    // reset listener..
    [ParticleEffects deallocEmitters];
    [LocalStorageManager unloadIngameAssets];
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:nil];
    
    // remove event listener
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{    
    
    for (Projectile *projectile in _projectiles) {
        // this prevents crashes from flygun projectiles
        if ([projectile isKindOfClass:[FlyGunShot class]]) {
            [(FlyGunShot *)projectile setTarget:nil:ccp(0,0):nil];
        }
        [projectile stopAllActions];
        [projectile unscheduleAllSelectors];
    }
    
    for (Monster *target in _targets) {
        // this prevents crashes from flygun projectiles
        [target stopAllActions];
        [target unscheduleAllSelectors];
        [target removeAllFlygunListener];
    }
    
    [self clearScene];
    [self removeSpriteBody:_player];
    
    /*[self stopAllActions];
    [self unscheduleAllSelectors];
    
    for (Projectile *projectile in _projectiles) {
        // this prevents crashes from flygun projectiles
        if ([projectile isKindOfClass:[FlyGunShot class]]) {
            [(FlyGunShot *)projectile setTarget:nil:ccp(0,0):nil];
        }
        [projectile stopAllActions];
        [projectile unscheduleAllSelectors];
    }
    
    for (Monster *target in _targets) {
        // this prevents crashes from flygun projectiles
        [target stopAllActions];
        [target unscheduleAllSelectors];
        [target removeAllFlygunListener];
    }
    
    [self clearScene];
    [self removeSpriteBody:_player];
    
    [_player prepareDealloc];
    [self removeChild:_player cleanup:YES];
    [self removeChild:tut cleanup:YES];
    _player = nil;
    
    [_laserBeam release];
    [_rainbow release];
    _laserBeam = nil;
    _rainbow = nil;
    
    [_projectiles removeAllObjects];
    [_items removeAllObjects];
    [_targets removeAllObjects];
    [_projectiles release];
    [_items release];
    [_targets release];
    _items = nil;
    _targets = nil;
    _projectiles = nil;
    [self removeAllChildrenWithCleanup:YES];
    
    //NSLog(@"[dealloc] HelloWorld");*/
	[super dealloc];
}
@end
