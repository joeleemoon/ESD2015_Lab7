//
//  MyPoint.h
//  JoinMe
//
//  Created by Lee Joe on 6/9/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyPoint : NSObject <MKAnnotation>

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;

-(id) initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)t;
-(CLLocationCoordinate2D) getCoordinate;
-(NSString*) getTitle;

@end
