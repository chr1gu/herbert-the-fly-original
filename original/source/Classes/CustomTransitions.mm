//
//  CustomTransitions.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 11/26/10.
//  Copyright 2010 Etite. All rights reserved.
//

#import "CustomTransitions.h"

@implementation MyCCSlideInLTransition

- (CCActionInterval*)easeActionWithAction:(CCActionInterval*)action {
	return [CCEaseInOut actionWithAction:action rate:5.0f];
}
@end

@implementation MyCCSlideInTTransition

- (CCActionInterval*)easeActionWithAction:(CCActionInterval*)action {
	return [CCEaseInOut actionWithAction:action rate:5.0f];
}
@end

@implementation MyCCSlideInBTransition

- (CCActionInterval*)easeActionWithAction:(CCActionInterval*)action {
	return [CCEaseInOut actionWithAction:action rate:5.0f];
}
@end

@implementation MyCCSlideInRTransition

- (CCActionInterval*)easeActionWithAction:(CCActionInterval*)action {
	return [CCEaseInOut actionWithAction:action rate:5.0f];
	//return [CCEaseInOut actionWithAction:action rate:5.0f];
	//return [CCEaseElasticInOut actionWithAction:action period:0.4f];
	//return [CCEaseSineIn actionWithAction:action];
	//return [CCEaseBackIn actionWithAction:action];
}
@end