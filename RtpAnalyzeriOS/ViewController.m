//
//  ViewController.m
//  RtpAnalyzeriOS
//
//  Created by Kaleb on 7/28/15.
//  Copyright (c) 2015 Kaleb. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController ()

-(void) initSocket;

@end

@implementation ViewController

GCDAsyncUdpSocket* updSocket;

int sequenceOld;
double packetCount;
double missedPacketsCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSocket];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initSocket
{
    NSLog(@"Initializing socket...");
    
    sequenceOld = 0;
    packetCount = 0;
    missedPacketsCount = 0;
  
    updSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err = nil;
    
     NSLog(@"Attempting to bind to port...");
    
    if(![updSocket bindToPort:7654 error:&err])
    {
        NSLog(@"Binding Failed... %@", err);
    }
    else
    {
        NSLog(@"Beging recieving data..");
        
        [updSocket beginReceiving:&err];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    double ratio = 0;
    
    int b0 = 0;
    int b1 = 0;
    
    [data getBytes:&b0 range:NSMakeRange(2, 1)];
    [data getBytes:&b1 range:NSMakeRange(3, 1)];
    
    int sequence = (b0*256) + b1;
    
    if(sequenceOld == 0)
    {
        sequenceOld = sequence;
    }
    else
    {
        if (sequence != (sequenceOld + 1))
        {
            missedPacketsCount++;
        }
        
        sequenceOld = sequence;
        
        packetCount++;
        
        ratio = missedPacketsCount/packetCount;
    }
    
    NSLog(@"Ratio %f", ratio);
    //NSLog(@"Sequence: %i", sequence);
    //NSLog(@"B0: %i B1: %i", b0, b1);
}


@end
