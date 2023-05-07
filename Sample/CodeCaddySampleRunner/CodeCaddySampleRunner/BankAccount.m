//
//  BankAccount.m
//  CodeCaddySampleRunner
//
//  Created by Chris Golding on 5/6/23.
//

#import "BankAccount.h"

@implementation BankAccount

- (instancetype)initWithAccountNumber:(NSString *)accountNumber accountHolderName:(NSString *)accountHolderName balance:(double)balance {
    self = [super init];
    if (self) {
        _accountNumber = accountNumber;
        _accountHolderName = accountHolderName;
        _balance = balance;
    }
    return self;
}

- (void)deposit:(double)amount {
    self.balance += amount;
}

- (void)withdraw:(double)amount {
    if (amount > self.balance) {
        NSLog(@"Insufficient funds");
    } else {
        self.balance -= amount;
    }
}

@end
