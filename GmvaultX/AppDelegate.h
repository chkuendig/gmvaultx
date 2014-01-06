//
//  AppDelegate.h
//  GmvaultX
//
//  Created by christian on 06/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSTextField *textField;

@property (assign) IBOutlet NSWindow *window;

- (IBAction)buttonName:(id)sender;
@end
