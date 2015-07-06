//
//  ViewController.m
//  JoinMe
//
//  Created by Lee Joe on 6/9/15.
//  Copyright (c) 2015 Lee Joe. All rights reserved.
//

#import "ViewController.h"

UITextView *mTextViewAlias;
UIScrollView *onlineMemberViewAlias;
NSMutableArray *friendLocationListAlias;
ViewController *vc;

CFSocketRef s;
bool TEST_MODE = false;
bool CONNECTED = false;

NSString* chatLog;
NSMutableArray* onlineMemList;
//UIViewController* vc;

/*

void updateMemberListView()
{
    for(UIView *view in [onlineMemberViewAlias subviews])
    {
        [view removeFromSuperview];
    }
    NSString *memberList=[[NSString alloc]init];
    for (int i=0; i<[onlineMemList count]; i++) {
        memberList = [[NSString alloc] initWithFormat:@"%@\n%@",memberList,[onlineMemList objectAtIndex:i]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake( 0 , i*16, 15, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button setTitle:[NSString stringWithFormat:@"%@",[onlineMemList objectAtIndex:i]] forState:normal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:vc action: @selector(memberButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[self.question_button_list addObject:button];
        [onlineMemberViewAlias addSubview:button];
        
        
    }
    //onlineMemberViewAlia = memberList;
}

*/

/*
NSString* getMemberList(NSString *str)
{
    onlineMemList = [[NSMutableArray alloc]init];
    NSString *str_left;
    if([str rangeOfString:@"*#"].location != NSNotFound)
    {
        NSRange range1 = [str rangeOfString:@"*#"];
        str_left = [str substringToIndex:range1.location];
        str = [str substringFromIndex:range1.location+2];
        
        while ([str rangeOfString:@"$"].location != NSNotFound) {
            
            NSRange range = [str rangeOfString:@"$"];
            NSString *str1 = [[NSString alloc] init];
            str1 = [str substringToIndex:range.location];
            [onlineMemList addObject:str1];
            NSLog(@"%@",str1);
            str = [str substringFromIndex:range.location+1];
            NSLog(@"%@",str);
        }
        updateMemberListView();
        return str_left;
    }
    else
    {
        return str;
    }
}
 */


void addFriendAnnotationToMap()
{
    //keep Current Location on the mapView
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[vc.mapView annotations]];
    for(int i=0;i<[pins count];i++)
    {
        if ([[[pins objectAtIndex:i] title] isEqualTString:@"Current Location"]) {
            [pins removeObjectAtIndex:i];
        }
    }
    [vc.mapView removeAnnotations:pins];
    
    for (int i; i<[friendLocationListAlias count]; i++) {
        MyPoint *tempPoint = [friendLocationListAlias objectAtIndex:i];
        CLLocationCoordinate2D coord = tempPoint.getCoordinate;
        MyPoint *temp = [[MyPoint alloc]initWithCoordinate:coord andTitle:[[NSString alloc]initWithFormat:@"%@",tempPoint.getTitle]];
        [vc.mapView addAnnotation:temp];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 2000, 2000);
        region.span.latitudeDelta = 1.0f;
        region.span.longitudeDelta = 1.0f;
        [vc.mapView setRegion:region animated:YES];
    }
    
}


void getFriendLocation(NSString *str)  //*#name$latitude$longitude$name$latitude$longitude.....
{
    if([str rangeOfString:@"*#"].location != NSNotFound)
    {
        [friendLocationListAlias removeAllObjects];
        NSRange range1 = [str rangeOfString:@"*#"];
        //str_left = [str substringToIndex:range1.location];
        str = [str substringFromIndex:range1.location+2];
        while ([str rangeOfString:@"$"].location != NSNotFound) {
            NSRange range = [str rangeOfString:@"$"];
            NSString *name = [[NSString alloc] initWithString:[str substringToIndex:range.location]];
            if([name isEqualToString:@"NOITEM"])  //server send NOITEM 
            {
                break;
            }
            str = [str substringFromIndex:range.location+1];
            range = [str rangeOfString:@"$"];
            NSString *latitude =[[NSString alloc] initWithString:[str substringToIndex:range.location]];
            str = [str substringFromIndex:range.location+1];
            range = [str rangeOfString:@"$"];
            NSString *longitude =[[NSString alloc] initWithString:[str substringToIndex:range.location]];
            str = [str substringFromIndex:range.location+1];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            MyPoint *friendPoint = [[MyPoint alloc] initWithCoordinate:[loc coordinate] andTitle:name];
            /*
            int objIdx = -1;
            for(int i=0; i <[friendLocationListAlias count] ;i++)
            {
                if([name isEqualToString:[[friendLocationListAlias objectAtIndex:i] getTitle]])
                {
                    objIdx =i;
                }
            }
            
            if(objIdx < 0) //Item not found in allLocationList
            {
                [friendLocationListAlias addObject:friendPoint];
            }
            else //replace item in allLocationList
            {
                [friendLocationListAlias replaceObjectAtIndex:objIdx withObject:friendPoint];
            }
             */
            [friendLocationListAlias addObject:friendPoint];
            
            NSLog(@"%@ , %@ , %@",name,latitude,longitude);
            
        }
    }
    addFriendAnnotationToMap();
    
}





void receiveData(CFSocketRef s,
                 CFSocketCallBackType type,
                 CFDataRef address,
                 const void *data,
                 void *info)
{
    CFDataRef df = (CFDataRef) data;
    int len =  (int)CFDataGetLength(df);
    if(len <= 0){
        NSLog(@"Can not Connect to Server for any reason.");
        [vc.WhereAreMyFriends_button setEnabled:NO];
        CONNECTED = false;
        return;
    };
    
    CFRange range = CFRangeMake(0,len);
    UInt8 buffer[len];
    
    //recv message
    NSLog(@"Received %d bytes from socket %d\n",
          len, CFSocketGetNative(s));
    
    CFDataGetBytes(df, range, buffer);
    NSLog(@"Client received: %s\n", buffer);
    NSString *mes = [[NSString alloc] initWithFormat:@"%s\n",buffer];
    getFriendLocation(mes);
}



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    if (self.locationManger == nil) {
        self.locationManger = [[CLLocationManager alloc] init];
        [self.locationManger setDelegate:self];
        [self.locationManger setDesiredAccuracy:kCLLocationAccuracyKilometer];
        //for IOS 8
        [self.locationManger requestWhenInUseAuthorization];
        //Set a movement threshold for new events.
        //self.locationManger.distanceFilter = 500;
        
        [self.locationManger startUpdatingLocation];
    }
    MKCoordinateRegion theRegion = {{0.0 , 0.0}, {0.0, 0.0}};
    /*
    CLLocationCoordinate2D coord = [self.locationManger.location coordinate];
    MyPoint *selfLocTemp = [[MyPoint alloc]initWithCoordinate:coord andTitle:[[NSString alloc]initWithFormat:@"%@",@"Current Location"]];
    [self.mapView addAnnotation:selfLocTemp];
     */
    
    theRegion.center = self.locationManger.location.coordinate;
    
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 1.0f;
    theRegion.span.latitudeDelta = 1.0f;
    [self.mapView setRegion:theRegion animated:YES];
    [self.mapView setShowsUserLocation:YES];
    
    self.friendLocationList = [[NSMutableArray alloc]init];
    friendLocationListAlias = self.friendLocationList;
    
    vc = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MKAnnotationView* )mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *pinView = nil;
    static NSString *defaultPinID = @"com.invasivecode.pin_YAYAYA";
    pinView = (MKPinAnnotationView* ) [mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];

    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation  reuseIdentifier:defaultPinID];
        pinView.canShowCallout=YES;
        pinView.animatesDrop = YES;
    }
    else {
        pinView.annotation = annotation;
    }
    
    if([annotation.title isEqualToString:@"Current Location"])
    {
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    else
    {
        pinView.pinColor = MKPinAnnotationColorGreen;
    }
    
    return pinView;
    
}


-(IBAction) pressTestButton:(id)sender{
    /*
    if(self.unknownMapView!=nil)
    {
        [self.unknownMapView removeAnnotations:[self.unknownMapView annotations]];
      
    }
     */
    [self.mapView setShowsUserLocation:NO];
   
    TEST_MODE = true;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[self.latitudeField.text floatValue] longitude:[self.longitudeField.text floatValue]];
    self.testLoc = [[MyPoint alloc] initWithCoordinate:[loc coordinate] andTitle:@"Current Location"];
    
    //[self.mapView removeAnnotation:<#(id<MKAnnotation>)#>]
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView addAnnotation:self.testLoc];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([loc coordinate], 1000, 1000);
    region.span.latitudeDelta = 1.0f;
    region.span.longitudeDelta = 1.0f;
    [vc.mapView setRegion:region animated:YES];
    [vc sendSelfLocation];

    
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //if(!TEST_MODE)
    //{
    self.unknownMapView = mapView;
        CLLocationCoordinate2D loc = [userLocation coordinate];
        self.userLoc = userLocation;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
        region.span.latitudeDelta = 1.0f;
        region.span.longitudeDelta = 1.0f;
        [self.mapView setRegion:region animated:YES];
    if(CONNECTED)
    {
        [self sendSelfLocation];
    }
    //}
}


 

-(IBAction) connectClicked:(id)sender{
    UIButton *uiButton = (UIButton *) sender;
    [uiButton setEnabled: NO];
    
    vc = self;
    
    s = CFSocketCreate(NULL, PF_INET,
                       SOCK_STREAM, IPPROTO_TCP,
                       kCFSocketDataCallBack,
                       receiveData,
                       NULL);
    
    struct sockaddr_in      sin;
    struct hostent          *host;
    
    memset(&sin, 0, sizeof(sin));
    host = gethostbyname("localhost");
    memcpy(&(sin.sin_addr), host->h_addr,host->h_length);
    
    sin.sin_family = AF_INET;
    sin.sin_port = htons(6666);
    
    CFDataRef address;
    CFRunLoopSourceRef source;
    
    address = CFDataCreate(NULL, (UInt8 *)&sin, sizeof(sin));
    CFSocketConnectToAddress(s, address, 0);
    
    // Connecting message
    printf("Connect to socket %d\n",CFSocketGetNative(s));
    CONNECTED = true;
    if(CONNECTED)
    {
        [self sendSelfLocation];
        [self.WhereAreMyFriends_button setEnabled:YES];
    }
    
    CFRelease(address);
    
    source = CFSocketCreateRunLoopSource(NULL, s, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       source,
                       kCFRunLoopDefaultMode);
    CFRelease(source);
    CFRunLoopRun();
    
}


-(void)sendSelfLocation
{
    //NSData *message = [self.myTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    printf("Sending self location...\n");
    float self_latitude=0.0f;
    float self_longitude=0.0f;
    if (TEST_MODE) {
        self_latitude =  self.testLoc.getCoordinate.latitude;
        self_longitude = self.testLoc.getCoordinate.longitude;
    }
    else
    {
        self_latitude = self.locationManger.location.coordinate.latitude;
        self_longitude = self.locationManger.location.coordinate.longitude;
    }
    NSString *mes = [[NSString alloc] initWithFormat:@"*#%f$%f$",self_latitude,self_longitude];
    NSData *message = [mes dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef message_data = CFDataCreate(NULL, [message bytes], [message length]);
    CFSocketSendData(s, NULL, message_data, 0);
    CFRelease(message_data);
}


-(IBAction)clickedWhereAreMyFriends:(id)sender
{
    NSString *mes = [[NSString alloc] initWithFormat:@"*&"];
    NSData *message = [mes dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef message_data = CFDataCreate(NULL, [message bytes], [message length]);
    CFSocketSendData(s, NULL, message_data, 0);
    CFRelease(message_data);
}



@end
