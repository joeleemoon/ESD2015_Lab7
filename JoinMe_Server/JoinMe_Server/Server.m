//
//  main.m
//  ImiPhone_CFSocketServer
//
//  Created by  on 12/2/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFSocket.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "FriendPoint.h"

void receiveData(CFSocketRef s, 
                 CFSocketCallBackType type, 
                 CFDataRef address, 
                 const void *data, 
                 void *info);

void sendData(CFSocketRef s,
                 CFSocketCallBackType type,
                 CFDataRef address,
                 const void *data,
                 void *info);

void acceptConnection(CFSocketRef s, 
                      CFSocketCallBackType type, 
                      CFDataRef address, 
                      const void *data, 
                      void *info);
void broadcast(NSString* message, CFDataRef address);
NSString* sendPrivate(NSString* message, CFDataRef address, NSString* sender_name,CFSocketRef);
void broadcastAllLocationList(CFDataRef);

void sendAllLocationList(CFDataRef,CFSocketRef);
void addToAllLocationList(NSString *mes, int sn);
bool requestAllLocationList(NSString *mes);


CFSocketRef getReceiveSocket(NSString *name);
NSMutableArray *socketArray;
NSMutableArray *addressArray;
NSMutableArray *allLocationList;


int main (int argc, const char * argv[])
{

    @autoreleasepool {
        struct sockaddr_in sin;
        int sock, yes = 1;
        CFSocketRef s;
        CFRunLoopSourceRef source;
        socketArray = [[NSMutableArray alloc] init];
        allLocationList = [[NSMutableArray alloc] init];
        
        //create a new socket
        sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        memset(&sin, 0, sizeof(sin));
        sin.sin_family = AF_INET;
        sin.sin_port = htons(6666); //port number
        
        //re-use the port or address when rerun the socket without error message
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, 
                   &yes, sizeof(yes));
        setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, 
                   &yes, sizeof(yes));

        //Check if the port is available
        if( bind(sock, (struct sockaddr *)&sin, sizeof(sin)) == -1){
            perror("bind");
            exit(1);
        }
        
        //Check if there is connection. limit 5 connection in listenning queue 
        listen(sock, 5);
        
        //Create a CFSocket object along with acceptConnection callback function
        s = CFSocketCreateWithNative(NULL, sock, 
                                     kCFSocketAcceptCallBack, 
                                     acceptConnection, 
                                     NULL);
        
        //Wait Message ...
        NSLog(@"socket %d Waiting for connection",sock);
        // Your code
        
        
        //Create a Run Loop source for CFSocket, and add it in the Current Run Loop
        source = CFSocketCreateRunLoopSource(NULL, s, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source,
                           kCFRunLoopDefaultMode);
        CFRelease(source);
        CFRelease(s);
        CFRunLoopRun();
        
    }
    return 0;
}

void receiveData(CFSocketRef s, 
                 CFSocketCallBackType type, 
                 CFDataRef address, 
                 const void *data, 
                 void *info)  
{
    CFDataRef df = (CFDataRef) data;
    int len = (int)CFDataGetLength(df);
    
    // Socket close handler
    if(len <= 0) {
        int sock = CFSocketGetNative(s);
        NSLog(@"%d just disconnected!  \n", CFSocketGetNative(s) );   //print in console
        for(int i=0;i<[socketArray count];i++) //remove disconnected sock from socketArray
        {
            CFSocketRef sn_temp = (CFSocketRef)[[socketArray objectAtIndex:i] pointerValue];
            int sock1 = CFSocketGetNative(sn_temp);
            if(sock == sock1){
                [socketArray removeObjectAtIndex:i];
                //sendMemberList(address);
                break;
            }
        }
        for (int i=0; i<[allLocationList count]; i++) //remove location of disconnect sock
        {
            NSString *sock_str = [[NSString alloc] initWithFormat:@"%d",sock];
            FriendPoint *friendPointTemp = [allLocationList objectAtIndex:i];
            if([sock_str isEqualToString:friendPointTemp.getName])
            {
                [allLocationList removeObjectAtIndex:i];
                
                break;
            }
        }
        
        return;
    }
    
    UInt8 buffer[len];
    for (int i=0; i<len; i++) {
        buffer[i]=0;
    }
    CFRange range = CFRangeMake(0,len);
    
    //Receiving Message...
    // Your code
    
    
    
    
    CFDataGetBytes(df, range, buffer);
    NSLog(@"Server received: %s from %d  \n", buffer, CFSocketGetNative(s) );   //print in console

    NSString* mes = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
    if(requestAllLocationList(mes))
    {
        sendAllLocationList(address,s);
    }
    else
    {
        addToAllLocationList(mes, CFSocketGetNative(s));
    }
    /*
    if(checkPrivate(mes))
    {
        NSString *receiver_name=[[NSString alloc] init];
        mes = [mes substringFromIndex:2];
        NSRange r = [mes rangeOfString:@" "];
        receiver_name = [mes substringToIndex:r.location];
        mes = [mes substringFromIndex:r.location];
        CFSocketRef receiver_socket = getReceiveSocket(receiver_name);
        if(receiver_socket != nil)
        {
            NSString* sender_name = [[NSString alloc]  initWithFormat:@"%d",CFSocketGetNative(s)];
            mes = sendPrivate(mes, address, sender_name ,receiver_socket);
            NSData *echo_message = [mes dataUsingEncoding:NSUTF8StringEncoding];
            CFDataRef message_data = CFDataCreate(NULL, [echo_message bytes], [echo_message length]);
            CFSocketSendData(s, address, message_data, 0);
        }
        else
        {
            NSString *cannot_find_mes = [[NSString alloc] initWithFormat:@"Can't find user %@", receiver_name];
            NSData *message = [cannot_find_mes dataUsingEncoding:NSUTF8StringEncoding];
            CFDataRef message_data = CFDataCreate(NULL, [message bytes], [message length]);
            CFSocketSendData(s, address, message_data, 0);
            NSLog(@"Can't find socket....");
        }
    }
    else
    {
        mes = [[NSString alloc] initWithFormat:@"%d:%@",CFSocketGetNative(s),mes];
        broadcast(mes, address);
    }
     */
}

void addToAllLocationList(NSString *str,int sn)
{
    if([str rangeOfString:@"*#"].location != NSNotFound)
    {
        NSRange range1 = [str rangeOfString:@"*#"];
        str = [str substringFromIndex:range1.location+2];
            NSString *name = [[NSString alloc] initWithFormat:@"%d",sn];
            NSRange range = [str rangeOfString:@"$"];
            NSString *latitude =[[NSString alloc] initWithString:[str substringToIndex:range.location]];
            str = [str substringFromIndex:range.location+1];
            range = [str rangeOfString:@"$"];
            NSString *longitude =[[NSString alloc] initWithString:[str substringToIndex:range.location]];
            str = [str substringFromIndex:range.location+1];
        FriendPoint *tmp = [[FriendPoint alloc] initWithName:name andLatitude:latitude andLongitude:longitude];
        
        int objIdx = -1;
        for(int i=0; i <[allLocationList count] ;i++)
        {
            if([name isEqualToString:[[allLocationList objectAtIndex:i] getName]])
            {
                objIdx =i;
            }
        }
        
        if(objIdx < 0) //Item not found in allLocationList
        {
            [allLocationList addObject:tmp];
        }
        else //replace item in allLocationList
        {
            [allLocationList replaceObjectAtIndex:objIdx withObject:tmp];
        }
            
        
        NSLog(@"%@ , %@ , %@",name,latitude,longitude);
            
    }
}



CFSocketRef getReceiveSocket(NSString *name)
{
    for(int i=0;i<[socketArray count];i++)
    {
        CFSocketRef s = (CFSocketRef)[[socketArray objectAtIndex:i] pointerValue];
        int k = CFSocketGetNative(s);
        if([[[NSString alloc]initWithFormat:@"%d",k] isEqualToString:name])
        {
            return s;
        }
    }
    return nil;
}


/*
NSString* sendPrivate(NSString* mes, CFDataRef address, NSString* sender_name,CFSocketRef receiver)
{
    mes = [[NSString alloc] initWithFormat:@"(PRIVATE)%@:%@",sender_name,mes];
    NSData *message = [mes dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef message_data = CFDataCreate(NULL, [message bytes], [message length]);
    CFSocketSendData(receiver, address, message_data, 0);
    return mes;
}
 */


void acceptConnection(CFSocketRef s, 
                      CFSocketCallBackType type, 
                      CFDataRef address, 
                      const void *data, 
                      void *info)  
{
    //retieve child socket
    CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
    CFSocketRef sn;
    CFRunLoopSourceRef source;  
    
    //Accepting Message ...
    // Your code
    NSLog(@"socket %d Received connection socket %d",CFSocketGetNative(s),csock);

    //Create a CFSopcket object along with receiveData call back function
    sn = CFSocketCreateWithNative(NULL, csock,
                                  kCFSocketDataCallBack,
                                  receiveData, 
                                  NULL);
    //int senderId = CFSocketGetNative(sn);
    NSValue *Id = [NSValue valueWithPointer:sn];
    [socketArray addObject:Id];
    /*
    NSString *str = [[NSString alloc]initWithFormat:@"%d just entered the chat room.\n",senderId];
    broadcast(str, address);
        sendMemberList(address);
     */
    
    //[addressArray addObject:(__bridge id)(address)];
    //Registor the source to Run Loop
    source = CFSocketCreateRunLoopSource(NULL, sn, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source,
                       kCFRunLoopDefaultMode);
    //release
    CFRelease(source);
    CFRelease(sn);
}

void sendAllLocationList(CFDataRef address,CFSocketRef s)
{
    NSString *mes = [[NSString alloc] initWithFormat:@"*#"];
    NSString *mes_temp = [[NSString alloc] init];
    NSString *sock_str = [[NSString alloc] initWithFormat:@"%d",CFSocketGetNative(s)];
    bool hasItemToSend = false;
    for (int i=0; i<[allLocationList count]; i++) {
        FriendPoint *FPtemp = [allLocationList objectAtIndex:i];
        if( ![FPtemp.getName isEqualToString:sock_str] )
        {
            mes_temp = [[NSString alloc] initWithFormat:@"%@$%@$%@$",FPtemp.name,FPtemp.latitude,FPtemp.longitude];
            mes = [[NSString alloc]initWithFormat:@"%@%@",mes,mes_temp ];
            hasItemToSend = true;
        }
    }
    
    if(!hasItemToSend)
    {
        mes_temp = [[NSString alloc] initWithFormat:@"NOITEM$"];
        mes = [[NSString alloc]initWithFormat:@"%@%@",mes,mes_temp ];
        
    }
    
    NSData *message = [mes dataUsingEncoding:NSUTF8StringEncoding];
    CFDataRef message_data = CFDataCreate(NULL, [message bytes], [message length]);
    CFSocketSendData(s, address, message_data, 0);
    CFRelease(message_data);
}

bool requestAllLocationList(NSString* mes)
{
    if([mes rangeOfString:@"*&"].location != NSNotFound)
    {
        return true;
    }
    else
    {
        return false;
    }
    
}


