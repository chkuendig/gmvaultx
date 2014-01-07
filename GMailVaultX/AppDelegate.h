//
//  AppDelegate.h
//  TasksProject
//
//  Created by Andy on 3/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSToolbarItem *tabButton1;
@property (weak) IBOutlet NSToolbarItem *tabButton2;
@property (weak) IBOutlet NSToolbarItem *tabButton3;
@property (weak) IBOutlet NSTabView *tabView;

@property  NSImage *tabImage1;
@property  NSImage *tabImage2;
@property  NSImage *tabImage3;

@property  NSImage *tabImage1_selected;
@property  NSImage *tabImage2_selected;
@property  NSImage *tabImage3_selected;

/**
 * Project Package
 */
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSButton *buildButton;
@property (weak) IBOutlet NSTextField *parameter;
- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;

/**
 * NSTask 
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe *errorPipe;


@end
