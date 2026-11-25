//
//  AppDelegate.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/5/11.
//  Copyright Etite 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextViewDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
