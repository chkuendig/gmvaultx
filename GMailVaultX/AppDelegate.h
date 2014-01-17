//
//  AppDelegate.h
//  TasksProject
//
//  Created by Andy on 3/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>



extern int const inititalSheetWidth;
extern int const inititalSheetHeight;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSOperationQueue *gmvOperationQueue;
    NSOperationQueue *outputOperationQueue;
}

// Interface
-(void)printMessage:(NSString*)message;
-(void)printError:(NSString*)message;
-(IBAction)pressEnter;
-(IBAction)refreshEmailSelector;
- (void)runScript:(NSArray*)arguments
    outputHandler:(void(^)(NSString* string))outputHandler
    returnHandler:(void(^)())returnHandler;
- (IBAction)stopTask:(id)sender;

// toolbar
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

// console

@property (unsafe_unretained) IBOutlet NSTextView *outputText;

/**
 * Project Package
 */


/* 
 Main Window/Tab
 */
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *eMailSelector;
@property NSString *activeAccount;
@property (weak) IBOutlet NSTextField *lastScheduledRun;

/**
 * NSTask 
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property NSFileHandle *masterHandle;
@property (copy) void (^taskReturnHandler) () ;
@property (copy) void (^taskOutputHandler) (NSString* string);

@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSButton *runButton;
@property (weak) IBOutlet NSTextField *parameter;

@end
