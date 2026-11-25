//
//  StoreKitObserver.h
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/13/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import <StoreKit/StoreKit.h> 

@interface StoreKitObserver : NSObject <SKPaymentTransactionObserver> {
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) recordTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString *)productIdentifier;

@end
