//
//  ViewController.h
//  JoinMe
//
//  Created by Lee Joe on 6/9/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyPoint.h"
#import <CoreFoundation/CFSocket.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>


@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) MKMapView *unknownMapView;
@property (nonatomic,strong) IBOutlet UITextField *latitudeField;
@property (nonatomic,strong) IBOutlet UITextField *longitudeField;
@property CLLocationManager *locationManger;
@property (nonatomic,strong) NSMutableArray *friendLocationList;
@property (nonatomic,strong) NSString *myName;
@property (nonatomic,strong) MKUserLocation* userLoc;
@property (nonatomic,strong) MyPoint *testLoc;
@property (nonatomic,strong) MKAnnotationView *myMKAView;

@property (nonatomic,strong) IBOutlet UIButton *WhereAreMyFriends_button;


void receiveData(CFSocketRef s,CFSocketCallBackType type,CFDataRef address,const void *data,void *info);



@end

