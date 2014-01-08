//
//  AppDelegate.m
//  GMailVault X
//

#import "AppDelegate.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // load menubar images
    NSString *path;
    path = [[NSBundle mainBundle] pathForResource:@"gmvault" ofType:@"png"];
    self.tabImage1 =  [[NSImage alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"scheduler" ofType:@"png"];
    self.tabImage2 =  [[NSImage alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"png"];
    self.tabImage3 =  [[NSImage alloc] initWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"gmvault_selected" ofType:@"png"];
    self.tabImage1_selected =  [[NSImage alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"scheduler_selected" ofType:@"png"];
    self.tabImage2_selected =  [[NSImage alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"settings_selected" ofType:@"png"];
    self.tabImage3_selected =  [[NSImage alloc] initWithContentsOfFile:path];
    
   }

- (IBAction)startCustomTask:(id)sender {
    NSArray *arguments = [self.parameter.stringValue componentsSeparatedByString:@" "];
 
    [self runScript:arguments];
}


- (IBAction)selectSetup:(id)sender {
  
    
    NSWindowController* controller = [[NSWindowController alloc] initWithWindow:self.setupDialog];
    [controller showWindow:nil];
}

- (IBAction)stopTask:(id)sender {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    } else {
        [self printMessage:@"Not running"];
        [self.buildButton setEnabled:YES];
        [self.spinner stopAnimation:self];
        self.isRunning = NO;
        self.buildTask = nil;
    }
    

}
- (IBAction)selectTab1:(id)sender {
    self.tabButton2.image = self.tabImage2;
    self.tabButton3.image = self.tabImage3;
    [[self tabView] selectTabViewItemAtIndex:0];
    self.tabButton1.image = self.tabImage1_selected;
    
}
- (IBAction)selectTab2:(id)sender {
    self.tabButton1.image = self.tabImage1;
    self.tabButton3.image = self.tabImage3;
    [[self tabView] selectTabViewItemAtIndex:1];
    self.tabButton2.image = self.tabImage2_selected;
}
- (IBAction)selectTab3:(id)sender {
    self.tabButton1.image = self.tabImage1;
    self.tabButton2.image = self.tabImage2;
    [[self tabView] selectTabViewItemAtIndex:2];
    self.tabButton3.image = self.tabImage3_selected;
}
- (IBAction)pressEnter:(id)sender {
    
    [[self.inputPipe fileHandleForWriting] writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
}
- (void)printMessage:(NSString*)message {
    [self printMessage:message color:[NSColor whiteColor] ];
}
- (void)printError:(NSString*)message {
    [self printMessage:message color:[NSColor redColor] ];
}
- (void)printMessage:(NSString*)message color:(NSColor*)color {
    /*
     //5
     On the main thread, append the string from the previous step to the end of
     the text in outputText and scroll the text area so that the user can see the 
     latest output as it arrives. This must be on the main thread as all GUI 
     redraws and user interactions occur on that thread, and you need to make sure
     you aren’t trying to modify the GUI while one of those things is happening.
     http://www.raywenderlich.com/36537/nstask-tutorial
     */
        
   // dispatch_sync(dispatch_get_main_queue(), ^{
        NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:message];
        [attr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[attr.string length])];
        
        [[self.outputText textStorage] appendAttributedString:attr];
        [self.outputText scrollRangeToVisible:NSMakeRange([[self.outputText string] length], 0)];
   // });

}
- (IBAction)startSetupTask:(id)sender {
    NSString* emailAddress = self.emailAddressInput.stringValue;
//     Database root directory.
    NSString* dbdir = [[NSFileManager defaultManager] applicationSupportDirectory];
 dbdir=   [dbdir stringByAppendingPathComponent:emailAddress];
    dbdir=   [dbdir stringByAppendingPathComponent:@"/gmvault-db/"];

    [self printMessage:dbdir];
    //sync -d email-directory
    
    NSArray *arguments = @[@"sync", @"-d", dbdir, emailAddress];
    [self runScript:arguments];
}



- (void)runScript:(NSArray*)arguments {
    
    [self.buildButton setEnabled:NO];
    [self.spinner startAnimation:self];
    
    /*
     //1
     Uses dispatch_async to run on a background thread. The application will 
     continue to process things like button clicks on the main thread, but 
     the NSTask will run on the background thread until it is complete.
     http://www.raywenderlich.com/36537/nstask-tutorial
     */
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        //2
        self.isRunning = YES;
        
        //3
        @try {
            if(!self.buildTask) {
            //1
            NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"gmv_runner"]];
            
            //2
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
        //    NSDictionary *env = self.buildTask.environment;
            
            
            // Set Homedirectory
            NSMutableDictionary* environment = [[NSMutableDictionary alloc] init];
            NSString *gmvaultHome =[[NSFileManager defaultManager] applicationSupportDirectory];

            [environment setValue:gmvaultHome forKey:@"GMVAULT_DIR"];
            [self.buildTask setEnvironment:environment];
            
            
            // Output Handling
            //1
            self.outputPipe               = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            self.errorPipe               = [[NSPipe alloc] init];
            self.buildTask.standardError = self.errorPipe;
            
            [self.buildTask setStandardError: [self.buildTask standardOutput]];
       
            //input handling
            self.inputPipe               = [[NSPipe alloc] init];
            [self.buildTask setStandardInput: self.inputPipe];
            

            //2
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            [[self.errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            //3 output pipe
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                //4
                NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
                [self printMessage:outStr];
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            //3 error pipe
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.errorPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                //4
                NSData *output = [[self.errorPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                [self printError:outStr];
                [[self.errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            }
            //3
            [self.buildTask launch];
            
            //4
            [self.buildTask waitUntilExit];
        }
        //4
        @catch (NSException *exception) {
            [self printError:[exception name]];
            [self printError:[exception description]];
            
            [self printError:[exception reason]];
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        //5
        @finally {
            [self.buildButton setEnabled:YES];
            [self.spinner stopAnimation:self];
            self.isRunning = NO;
            self.buildTask = nil;
           
        }
    });
}



@end
