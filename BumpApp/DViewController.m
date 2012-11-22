//
//  DViewController.m
//  BumpApp
//
//  Created by Darshan Sonde on 21/11/12.
//  Copyright (c) 2012 Darshan Sonde. All rights reserved.
//

#import "DViewController.h"
#import "BumpClient.h"

@interface DViewController () {
    BumpChannelID _channel;
}
@property (weak, nonatomic) IBOutlet UITextView *outputLabel;

@end

@implementation DViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sendButton.enabled = NO;
    [self configureBump];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendDataTapped:(id)sender {
    NSString *dateTime = [[NSString alloc] initWithFormat:@"%@",[NSDate date] ];
    [[BumpClient sharedClient] sendData:[[NSString stringWithFormat:@"Bump %@!",dateTime] dataUsingEncoding:NSUTF8StringEncoding]
                              toChannel:_channel];
    
}

- (void) configureBump {
    [BumpClient configureWithAPIKey:@"b8283fabcf1345559951c466d387432c" andUserID:[[UIDevice currentDevice] name]];
    
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        NSString *str = [NSString stringWithFormat:@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]];
        self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSString *str = [NSString stringWithFormat:@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]];
        self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
        _channel = channel;
        self.sendButton.enabled = YES;
    }];
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        NSString *str = [NSString stringWithFormat:@"Data received from %@: %@",
              [[BumpClient sharedClient] userIDForChannel:channel],
              [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]];
        self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
    }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            NSString *str = [NSString stringWithFormat:@"Bump connected..."];
            self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
        } else {
            NSString *str = [NSString stringWithFormat:@"Bump disconnected..."];
            self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
        }
    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP: {
                NSString *str = @"Bump detected.";
                self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
            }
                break;
            case BUMP_EVENT_NO_MATCH: {
                NSString *str = @"No match.";
                self.outputLabel.text = [NSString stringWithFormat:@"%@\n%@",self.outputLabel.text,str];
            }
                break;
        }
    }];
}


@end
