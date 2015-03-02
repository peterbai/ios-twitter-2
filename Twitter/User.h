//
//  User.h
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *profileImageUrlBigger;
@property (nonatomic, strong) NSString *profileImageUrlOriginal;
@property (nonatomic, strong) NSString *profileBannerUrl;
@property (nonatomic, strong) NSString *profileBannerUrlMedium;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSNumber *numberOfTweets;
@property (nonatomic, strong) NSNumber *numberFollowing;
@property (nonatomic, strong) NSNumber *numberOfFollowers;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (NSArray *)allUsers;

+ (void)setcurrentUser:(User *)currentUser;

+ (void)addUser:(User *)user;

+ (void)logout;

@end
