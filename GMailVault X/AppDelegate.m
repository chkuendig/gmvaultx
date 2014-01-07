//
//  AppDelegate.m
//  TasksProject
//
//  Created by Andy on 3/23/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
- (IBAction)startTask:(id)sender {
    
    //1
    self.outputText.string = @"";
    
    //2
 //   NSString *projectLocation  = [self.projectPath.URL path];
  //  NSString *finalLocation    = [self.repoPath.URL path];
    
    //3
  //  NSString *projectName      = [self.projectPath.URL lastPathComponent];
   // NSString *xcodeProjectFile = [projectLocation stringByAppendingString:[NSString stringWithFormat:@"/%@.xcodeproj", projectName]];
    
    //4
 //   NSString *buildLocation    = [projectLocation stringByAppendingString:@"/build/Release-iphoneos"];
    
    // 5
/*    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:xcodeProjectFile];
    [arguments addObject:self.targetName.stringValue];
    [arguments addObject:buildLocation];
    [arguments addObject:projectName];
    [arguments addObject:finalLocation];*/
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:self.parameter.stringValue];
    // 6
    [self.buildButton setEnabled:NO];
    [self.spinner startAnimation:self];
    [self runScript:arguments];
}

- (IBAction)stopTask:(id)sender {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
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

- (void)runScript:(NSArray*)arguments {
    //1
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        //2
        self.isRunning = YES;
        
        //3
        @try {
            //1
            NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"gmv_runner"]];
            
            //2
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
            
            // Output Handling
            //1
            self.outputPipe               = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            self.errorPipe               = [[NSPipe alloc] init];
            self.buildTask.standardError = self.errorPipe;
            
            //2
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            [[self.errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            //3
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                //4
                NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                //5
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.outputText.string = [self.outputText.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outStr]];
                    // Scroll to end of outputText field
                    NSRange range;
                    range = NSMakeRange([self.outputText.string length], 0);
                    [self.outputText scrollRangeToVisible:range];
                });
                //6
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.errorPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                //4
                NSData *output = [[self.errorPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                
                //5
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.outputText.string = [self.outputText.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outStr]];
                    // Scroll to end of outputText field
                    NSRange range;
                    range = NSMakeRange([self.outputText.string length], 0);
                    [self.outputText scrollRangeToVisible:range];
                });
                //6
                [[self.errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            //3
            [self.buildTask launch];
            
            //4
            [self.buildTask waitUntilExit];
        }
        //4
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        //5
        @finally {
            [self.buildButton setEnabled:YES];
            [self.spinner stopAnimation:self];
            self.isRunning = NO;
        }
    });
}

@end
