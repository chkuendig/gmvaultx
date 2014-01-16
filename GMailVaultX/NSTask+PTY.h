//
//  NSTask+PTY.h
//  GMailVaultX
//
//  Created by christian on 15/01/14.
//  Copyright (c) 2014 christian kuendig. All rights reserved.
//

@interface NSTask (PTY)

- (NSFileHandle *)masterSideOfPTYOrError:(NSError **)error;

@end