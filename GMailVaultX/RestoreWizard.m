//
//  RestoreWizard.m
//  GMailVaultX
//
//  Created by christian on 17/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//

#import "RestoreWizard.h"

@implementation RestoreWizard

@synthesize sheet = _sheet;
@synthesize appDelegate = _appDelegate;

-(IBAction)activateSheet:(id)sender {
    self.appDelegate =  (AppDelegate *)[NSApp delegate];
    self.sourceAccount = self.appDelegate.activeAccount;
    if([self.sourceAccount length] != 0) {
    if(!_sheet) {
        [[NSBundle mainBundle] loadNibNamed:@"RestoreWizard"
                                      owner:self
                            topLevelObjects:nil];
    }
    [NSApp beginSheet:self.sheet
       modalForWindow:[[NSApp delegate] window]
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
    }
}

// get email and start gmvault
- (IBAction)gotoOauth:(id)sender {
    [self.restoreTab0NextButton setEnabled:NO];
    
    [self.closeButton setHidden:YES];
    
    // Database root directory.
    NSString* targetAccount = self.targetAccountInput.stringValue;
    
    NSString* dbdir = [[NSFileManager defaultManager] applicationSupportDirectory];
    dbdir=   [dbdir stringByAppendingPathComponent:self.sourceAccount];
    dbdir=   [dbdir stringByAppendingPathComponent:@"/gmvault-db/"];
    [self.appDelegate  printMessage:dbdir];
    
   // NSString* sourceAccount = self.appDelegate.activeAccount;
    
    // delete oauth file
    NSString* oauthFile = [[NSFileManager defaultManager] applicationSupportDirectory];
    oauthFile=   [oauthFile stringByAppendingPathComponent:targetAccount];
    oauthFile=   [oauthFile stringByAppendingString:@".oauth"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:oauthFile error:&error];
    if (error) {
        [self.appDelegate printError:error.description];
        NSLog(@"error: could not delete oauth-file %@", error);
    }
    
    //  ./gmvault restore -d ~/gmvault-db anewfoo.bar@gmail.com
    NSArray *arguments = @[@"restore",@"--resume", @"-d", dbdir, targetAccount]; //  @"--no-browser",
    
    [self.appDelegate runScript:arguments
                  outputHandler:^(NSString* message){
                      [self.restoreStatus setStringValue:message];
                      [self parseStdOut:message];
                  }
                  returnHandler:^() {
                      [self.closeButton setHidden:NO];
                      [[self tabView] selectTabViewItemAtIndex:3];
                      [self.appDelegate refreshEmailSelector];
                  }];
    
}

-(void) parseStdOut:(NSString*)message {
    NSString *re1=@"(Please log in and/or grant access via your browser at )";	// Word 1
    NSString *re3=@"( then hit enter)";	// Non-greedy match on filler
    NSString *re2=@"((?:http|https)(?::\\/{2}[\\w]+)(?:[\\/|\\.]?)(?:[^\\s\"]*))";	// HTTP URL 1
    NSString *pattern =@"";
    pattern = [pattern stringByAppendingString:re1];
    pattern = [pattern stringByAppendingString:re2];
    pattern = [pattern stringByAppendingString:re3];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        [self.appDelegate printError:error.description];
        NSLog(@"regex error:%@", error);
        return;
    }
    NSArray *arrayOfAllMatches = [regex matchesInString:message options:0 range:NSMakeRange(0, [message length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString *oauthURL  = [message substringWithRange:[match rangeAtIndex:2]];
        NSLog(@"Extracted URL: %@",oauthURL);
        [self gotoRestoreTab1:oauthURL];
    }
    
}

// Open OAuth Window
- (IBAction)gotoRestoreTab1:(NSString*)oauthURL {
    [[self tabView] selectTabViewItemAtIndex:1];
    
    [self.appDelegate printMessage:[@"\n" stringByAppendingString:oauthURL]];
    NSURL *url = [NSURL URLWithString:oauthURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.sheet setFrame:NSMakeRect(0.f, 0.f, 750, 430) display:YES animate:YES];
        [[self.webView mainFrame] loadRequest:urlRequest];
    });
    [self.restoreTab1NextButton setEnabled:NO];
}

// Wait for OAuth Success
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    if (frame == [self.webView mainFrame]) {
        NSLog(@"Title: %@", title);
        [self.appDelegate printMessage:[@"Title: %@" stringByAppendingString:title]];
        
        if([title isEqualToString: @"Success"]) {
            [self.sheet setFrame:NSMakeRect(0.f, 0.f, inititalSheetWidth, inititalSheetHeight) display:YES animate:YES];
            [self.appDelegate pressEnter];
            [self gotoWaitingTab:NULL];
            
        }
    }
}

// wait for gmvault to do its thing
- (IBAction)gotoWaitingTab:(id)sender {
    [[self tabView] selectTabViewItemAtIndex:2];
    [self.restoreTab2NextButton setEnabled:NO];
    
}

-(IBAction)closeSheet:(id)sender{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
    [self.appDelegate stopTask:NULL];
}

@end
