//
//  FriendPoint.m
//  JoinMe_Server
//
//  Created by Lee Joe on 6/10/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import "FriendPoint.h"

@implementation FriendPoint

-(id)initWithName:(NSString *)n andLatitude:(NSString *)la andLongitude:(NSString *)lo {
    self = [super init];
    if (self) {
        _name = n;
        _latitude = la;
        _longitude = lo;
    }
    return self;
}

-(NSString*)getName {
    return self.name;
}


-(NSString*)getLatitude {
    return self.latitude;
}

-(NSString*)getLongitude  {
    return self.longitude;
}

@end
