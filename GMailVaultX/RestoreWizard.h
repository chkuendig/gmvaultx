//
//  RestoreWizard.h
//  GMailVaultX
//
//  Created by christian on 17/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//



#import <WebKit/WebKit.h>
#import "AppDelegate.h"

#import "NSFileManager+DirectoryLocations.h"


@interface RestoreWizard : NSObject
@property (weak) IBOutlet NSButton *closeButton;

@property (assign) IBOutlet NSWindow *sheet;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSView *OauthView;
@property (assign) IBOutlet WebView *webView;

@property AppDelegate  *appDelegate;;

-(IBAction) activateSheet:(id)sender;
-(IBAction) closeSheet:(id)sender;

@property NSString* sourceAccount;

@property (weak) IBOutlet NSTextField *targetAccountInput;
@property (weak) IBOutlet NSButton *restoreTab0NextButton;
@property (weak) IBOutlet NSButton *restoreTab1NextButton;
@property (weak) IBOutlet NSButton *restoreTab2NextButton;
@property (weak) IBOutlet NSButton *restoreTab3NextButton;

@property (weak) IBOutlet NSTextField *restoreStatus;

@end
