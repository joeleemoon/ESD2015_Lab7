//
//  FriendPoint.h
//  JoinMe_Server
//
//  Created by Lee Joe on 6/10/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendPoint : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;


-(id)initWithName:(NSString*)n andLatitude:(NSString*)la andLongitude:(NSString*)lo;
-(NSString*)getName;
-(NSString*)getLatitude;
-(NSString*)getLongitude;
@end
