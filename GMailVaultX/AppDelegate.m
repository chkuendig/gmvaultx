//
//  AppDelegate.m
//  GMailVault X
//

#import "AppDelegate.h"
#import "NSFileManager+DirectoryLocations.h"
#import "NSTask+PTY.h"

@implementation AppDelegate

@synthesize window = _window;
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
    
    
    // Create a new NSOperationQueue instance.
    outputOperationQueue = [NSOperationQueue new];
    gmvOperationQueue = [NSOperationQueue new];
    

    // load inventory of email accounts
    [self refreshEmailSelector];
    
   }

/* Menubar Tabs */
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


/* Setup Wizard */
/*- (IBAction)selectSetupTab0:(id)sender {
   self.setupWizard = [[NSWindowController alloc] initWithWindow:self.setupDialog];
    [self.setupWizard showWindow:nil];
    
    [[self setupTabView] selectTabViewItemAtIndex:0];
   // NSWindow* _window = self.mainWindow;
    
    NSLog(@"%@",_window);
    
    // User has asked to see the custom display. Display it.
    
    {
        
       // if (!self.setupWizardSheet)
            
            //Check the myCustomSheet instance variable to make sure the custom sheet does not already exist.
            
            [NSBundle loadNibNamed: @"SetupWizard" owner: self];
        
        
        
        [NSApp beginSheet: self.setupWizardSheet
         
           modalForWindow: _window
         
            modalDelegate: self
         
           didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
         
              contextInfo: nil];
        
        
        
        // Sheet is up here.
        
        // Return processing to the event loop
        
    }
}*/

/*
 Console
 */
- (void)printMessage:(NSString*)message {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(printMessageSynced:)
                                                                              object:message ];
    [outputOperationQueue addOperation:operation];
}

- (void)printMessageSynced:(NSString*)message {
    NSLog(message);
    [self printMessage:message color:[NSColor whiteColor] ];
    }
- (void)printError:(NSString*)message {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(printErrorSynced:)
                                                                              object:message ];
    [outputOperationQueue addOperation:operation];
}
- (IBAction)selectEmailAccount:(id)sender {
    NSString *selectedEmail = self.eMailSelector.selectedItem.title;
    NSLog(selectedEmail);
    
}
- (void)printErrorSynced:(NSString*)message {
    NSLog(message);
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
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:message];
    [attr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@""]];
    [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[attr.string length])];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[self.outputText textStorage] appendAttributedString:attr];
        [self.outputText scrollRangeToVisible:NSMakeRange([[self.outputText string] length], 0)];
    });
    
}

/* 
 Main Window/Tab
 */
- (IBAction)startCustomTask:(id)sender {
    NSArray *arguments = [self.parameter.stringValue componentsSeparatedByString:@" "];
    [self runScript:arguments outputHandler:nil returnHandler:nil];
}
- (IBAction)refreshEmailSelector {
    
    
    NSError *error = nil;
        NSArray *desktopFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSFileManager defaultManager] applicationSupportDirectory] error:&error];
    
    if(desktopFiles == nil){
        NSLog(@"%@", [error localizedDescription]);
        [self printError:[error localizedDescription]];
        return;
    }
 
   
    [self.eMailSelector removeAllItems];
    
    [self.eMailSelector addItemWithTitle:@""];
    for (id filename in desktopFiles){
        BOOL isDir;
        NSString* emaildir = [[NSFileManager defaultManager] applicationSupportDirectory];
        emaildir=   [emaildir stringByAppendingPathComponent:filename];
        if([[NSFileManager defaultManager]
            
            fileExistsAtPath:emaildir isDirectory:&isDir] && isDir){
                       [self.eMailSelector addItemWithTitle:filename];
        }
    }
}




/* Start/Stop Task */

- (IBAction)pressEnter:(id)sender {
    [self pressEnter];
}
- (IBAction)pressEnter {
       [self.masterHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
/* NSOperationQueue   *adhocOperationQueue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(pressEnterSynced:)
                                                                              object:nil ];
    [adhocOperationQueue addOperation:operation];*/
}
- (IBAction)pressEnterSynced {
          [self.masterHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];

}

- (IBAction)stopTask:(id)sender {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    } else {
        [self printMessage:@"Not running"];
        [self.runButton setEnabled:YES];
        [self.spinner stopAnimation:self];
        self.isRunning = NO;
        self.buildTask = nil;
    }
}

    
- (void)runScript:(NSArray*)arguments
            outputHandler:(void(^)(NSString* string))outputHandler
            returnHandler:(void(^)())returnHandler{
   self.taskReturnHandler = returnHandler;
   self.taskOutputHandler = outputHandler;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(runScriptSynced:)
                                                                              object:arguments ];
    [gmvOperationQueue addOperation:operation];
}


- (void)runScriptSynced:(NSArray*)arguments {
    [self.runButton setEnabled:NO];
    [self.spinner startAnimation:self];
    /*
     //1
     Uses dispatch_async to run on a background thread. The application will
     continue to process things like button clicks on the main thread, but
     the NSTask will run on the background thread until it is complete.
     http://www.raywenderlich.com/36537/nstask-tutorial
     */
 //   dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
   // dispatch_async(taskQueue, ^{
        
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
                
                
              //  NSTask *_currentTask = [[NSTask alloc] init];
             //   _currentTask.launchPath = @"/usr/bin/python";
             //   _currentTask.arguments = @[[[NSBundle mainBundle] pathForResource:@"nameTest" ofType:@"py"]];
                
                NSError *error;
                self.masterHandle = [self.buildTask masterSideOfPTYOrError:&error];
                if (!self.masterHandle) {
                    [self printError:error.description];
                    NSLog(@"error: could not set up PTY for task: %@", error);
                    return;
                }
               

                // EXAMPLE:
                // http://stackoverflow.com/questions/13355363/nstask-requires-flush-when-reading-from-a-process-stdout-terminal-does-not
                /*dispatch_queue_t stdout_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                
                __block dispatch_block_t checkBlock;
                
                checkBlock = ^{
                    NSData *readData = [self.masterHandle availableData];
                    NSString *consoleOutput = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self printMessage:consoleOutput];
                    });
                    if ([self.buildTask isRunning]) {
                        [NSThread sleepForTimeInterval:0.1];
                        checkBlock();
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            NSData *readData = [self.masterHandle readDataToEndOfFile];
                            NSString *consoleOutput = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                           [self printMessage:consoleOutput];
                        });
                    }
                };
                
                dispatch_async(stdout_queue, checkBlock);*/

                // EXAMPLE:
                // http://www.raywenderlich.com/36537/nstask-tutorial
                
                [self.masterHandle waitForDataInBackgroundAndNotify];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

                // NSFileHandleReadCompletionNotification or NSFileHandleDataAvailableNotification
                [notificationCenter addObserverForName:NSFileHandleDataAvailableNotification object:self.masterHandle queue:nil usingBlock:^(NSNotification *notification){
                    //4
                    NSData *output = [self.masterHandle availableData];
                    NSString *outStr = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
                    [self printMessage:outStr];
                    if(self.taskOutputHandler) {
                        self.taskOutputHandler(outStr);
                    }
                    [self.masterHandle waitForDataInBackgroundAndNotify];
                }];

               // [self.masterHandle waitForDataInBackgroundAndNotify];
                
                
                
          /*      // Output Handling
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
                }];*/
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
            [self.runButton setEnabled:YES];
            [self.spinner stopAnimation:self];
            self.isRunning = NO;
            self.buildTask = nil;
            if(self.taskReturnHandler) {
                
                self.taskReturnHandler();
            }
            
        }
  // });
}




@end
