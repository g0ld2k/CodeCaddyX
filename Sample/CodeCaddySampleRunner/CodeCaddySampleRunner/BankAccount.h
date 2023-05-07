//
//  BankAccount.h
//  CodeCaddySampleRunner
//
//  Created by Chris Golding on 5/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BankAccount : NSObject

@property (nonatomic, strong) NSString *accountNumber;
@property (nonatomic, strong) NSString *accountHolderName;
@property (nonatomic, assign) double balance;

- (instancetype)initWithAccountNumber:(NSString *)accountNumber accountHolderName:(NSString *)accountHolderName balance:(double)balance;
- (void)deposit:(double)amount;
- (void)withdraw:(double)amount;

@end

NS_ASSUME_NONNULL_END
