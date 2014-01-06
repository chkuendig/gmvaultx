//
//  AppDelegate.m
//  GmvaultX
//
//  Created by christian on 06/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//
#import <Python/Python.h>
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)buttonName:(id)sender {
    [self.textField setStringValue:@"my first osx app"];

}
@end
