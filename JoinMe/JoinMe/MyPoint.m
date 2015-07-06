//
//  MyPoint.m
//  JoinMe
//
//  Created by Lee Joe on 6/9/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t{
    self = [super init];
    if (self) {
        _coordinate = c;
        _title = t;
    }
    return self;
}

-(CLLocationCoordinate2D) getCoordinate
{
    return self.coordinate;
}

-(NSString*) getTitle
{
    return self.title;
}

@end
