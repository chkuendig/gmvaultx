//
//  AppController.m
//  GMailVaultX
//
//  Created by christian on 15/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//

#import "AppController.h"


#import "AppDelegate.h"

@implementation AppController
@synthesize sheet = _sheet;
@synthesize appDelegate = _appDelegate;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [self.webView mainFrame]) {
        NSLog(@"Title: %@", title);
        if(
           
           [title isEqualToString: @"Success"]) {
            [self gotoSetupTab2:NULL];
            
        }
           

    }
}

-(IBAction)activateSheet:(id)sender {
    
    
    self.appDelegate =  (AppDelegate *)[NSApp delegate];
    
    
    
    if(!_sheet) {
        [NSBundle loadNibNamed:@"SetupWizard" owner:self];
    }
    [NSApp beginSheet:self.sheet
       modalForWindow:[[NSApp delegate] window]
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
    
    
  /*  CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(255.0, 0.0, 0.0, 0.4)]; //RGB plus Alpha Channel
    [self.superView
     setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.superView setLayer:viewLayer];
    // [self.test
    
    
    CALayer *viewLayer2 = [CALayer layer];
    [viewLayer2 setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 255.0, 0.4)]; //RGB plus Alpha Channel
    [self.tabView
     setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.tabView setLayer:viewLayer2];
    // [self.test
    [ self.tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];*/
   
    
}
-(IBAction)closeSheet:(id)sender{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
    [self.appDelegate stopTask:NULL];
}


- (IBAction)gotoOauth:(id)sender {
    [self.setupTab0NextButton setEnabled:NO];
    
    NSString* emailAddress = self.setupTab0EmailInput.stringValue;
    //     Database root directory.
    NSString* dbdir = [[NSFileManager defaultManager] applicationSupportDirectory];
    dbdir=   [dbdir stringByAppendingPathComponent:emailAddress];
    dbdir=   [dbdir stringByAppendingPathComponent:@"/gmvault-db/"];
    
    [self.appDelegate  printMessage:dbdir];
    // delete oauth file
    NSString* oauthFile = [[NSFileManager defaultManager] applicationSupportDirectory];
    oauthFile=   [oauthFile stringByAppendingPathComponent:emailAddress];
    oauthFile=   [oauthFile stringByAppendingString:@".oauth"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:oauthFile error:&error];
    if (error) {
        [self.appDelegate printError:error.description];
        NSLog(@"error: could not delete oauth-file %@", error);
        // return;
    }
    
    
    //sync -d email-directory
    NSArray *arguments = @[@"sync", @"--no-browser", @"-d", dbdir, emailAddress];
    /* [self runScript:arguments outputHandler:@selector(handleSetupMessage) returnHandler:@selector(handleSetupFinish)];
     */
    
    [self.appDelegate runScript:arguments
      outputHandler:^(NSString* message){
          [self.setupStatus setStringValue:message];
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
    // go to oauth webview
        [self gotoSetupTab1:oauthURL];
    }

}

- (IBAction)gotoSetupTab1:(NSString*)oauthURL {
    
    [[self tabView] selectTabViewItemAtIndex:1];
   // [self.sheet set setFrame:NSMakeRect(0, 0, 200, 100)];
       [self.appDelegate printError:oauthURL];
      NSURL *url = [NSURL URLWithString:oauthURL];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.sheet setFrame:NSMakeRect(0.f, 0.f, 750, 430) display:YES animate:YES];

    [[self.webView mainFrame] loadRequest:urlRequest];
    });
    [self.setupTab1NextButton setEnabled:NO];
 //   [self.appDelegate pressEnter];
    
}
- (IBAction)gotoSetupTab2:(id)sender {
      [self.sheet setFrame:NSMakeRect(0.f, 0.f, inititalSheetWidth, inititalSheetHeight) display:YES animate:YES];
    
    [[self tabView] selectTabViewItemAtIndex:2];
    [self.setupTab2NextButton setEnabled:NO];
    [self.appDelegate pressEnter];
    
}
/*- (IBAction)resetSetupWizard:(id)sender {
    [self.setupWizard close];
}*/


@end
