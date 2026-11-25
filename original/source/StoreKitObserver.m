//
//  StoreKitObserver.m
//  HerbertTheFly
//
//  Created by Christoph Ebert on 8/13/11.
//  Copyright 2011 Etite. All rights reserved.
//

#import "StoreKitObserver.h"


@implementation StoreKitObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];    
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    
    //NSLog(@"Purchase failed/canceled..");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) recordTransaction: (SKPaymentTransaction *)transaction
{
    // no recording needed for sponsoring..
}

- (void) provideContent: (NSString *)productIdentifier
{
    // no aditional content needed for sponsoring..
    //NSLog(@"%@ purchased", productIdentifier);
}

@end
