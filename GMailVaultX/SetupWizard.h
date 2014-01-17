//
//  AppController.h
//  GMailVaultX
//
//  Created by christian on 15/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//


#import <WebKit/WebKit.h>
#import "AppDelegate.h"

#import "NSFileManager+DirectoryLocations.h"


@interface SetupWizard : NSObject
@property (weak) IBOutlet NSButton *closeButton;

@property (assign) IBOutlet NSWindow *sheet;
@property (weak) IBOutlet NSView *superView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *OauthView;
@property (assign) IBOutlet WebView *webView;

@property AppDelegate  *appDelegate;;

-(IBAction) activateSheet:(id)sender;
-(IBAction) closeSheet:(id)sender;


@property (weak) IBOutlet NSTextField *setupTab0EmailInput;
@property (weak) IBOutlet NSButton *setupTab0NextButton;
@property (weak) IBOutlet NSButton *setupTab1NextButton;
@property (weak) IBOutlet NSButton *setupTab2NextButton;
@property (weak) IBOutlet NSButton *setupTab3NextButton;

@property (weak) IBOutlet NSTextField *setupStatus;

@end
