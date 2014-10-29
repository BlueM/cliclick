/**
 * Copyright (c) 2007-2014, Carsten Blüm <carsten@bluem.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * - Neither the name of Carsten Blüm nor the names of his contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MouseBaseAction.h"

@implementation MouseBaseAction

+(int)getCoordinate:(NSString *)unparsedValue
            forAxis:(CLICLICKAXIS)axis {

    if ([[unparsedValue substringToIndex:1] isEqualToString:@"+"] ||
        [[unparsedValue substringToIndex:1] isEqualToString:@"-"]) {
        // Relative value
        CGEventRef dummyEvent = CGEventCreate(NULL);
        CGPoint ourLoc        = CGEventGetLocation(dummyEvent);
        int positionDiff      = [unparsedValue intValue];
        int currentPosition   = axis == XAXIS ? (int)ourLoc.x : (int)ourLoc.y;
        CFRelease(dummyEvent);

        return (int) currentPosition + positionDiff;
    }

    if ([[unparsedValue substringToIndex:1] isEqualToString:@"="]) {
        // Forced absolute value
        return [[unparsedValue substringFromIndex:1] intValue];
    }

    // Else. Absolute value
    return [unparsedValue intValue];
}

-(NSString *)actionDescriptionString:(NSString *)locationDescription {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
    return @"Will never be reached, but makes Xcode happy ;-)";
}

-(void)performActionAtPoint:(CGPoint)p {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

#pragma mark - ActionProtocol

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {
    
    CGPoint p;
    NSString *shortcut = [[self class] commandShortcut];
    NSString *verboseLoc;

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected two coordinates (separated by a comma) or “.”. Examples: “%@:123,456” or “%@.”",
                           shortcut, shortcut, shortcut];
    } else if ([data isEqualToString:@"."]) {
        // Click at current location
        CGEventRef ourEvent = CGEventCreate(NULL);
        CGPoint    ourLoc   = CGEventGetLocation(ourEvent);
        CFRelease(ourEvent);
        p.x = (int)ourLoc.x;
        p.y = (int)ourLoc.y;
        verboseLoc = @"current location";
    } else {
        NSArray *coords = [data componentsSeparatedByString:@","];
        
        if ([coords count] != 2 ||
            [[coords objectAtIndex:1] isEqualToString:@""])
        {
            [NSException raise:@"InvalidCommandException"
                        format:@"Invalid argument “%@” to command “%@”: Expected two coordinates, separated by a comma. Example: “%@:123,456”",
                               data, shortcut, shortcut];
        }
        
        p.x = [[self class] getCoordinate:[coords objectAtIndex:0] forAxis:XAXIS];        
        p.y = [[self class] getCoordinate:[coords objectAtIndex:1] forAxis:YAXIS];

        verboseLoc = [NSString stringWithFormat:@"%@,%@", [coords objectAtIndex:0], [coords objectAtIndex:1]];
    }
    
    if (MODE_REGULAR != mode) {
        printf("%s\n", [[self actionDescriptionString:verboseLoc] UTF8String]);
    }
    
    if (MODE_TEST == mode) {
        return;
    }

    // Move
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, CGPointMake(p.x, p.y), kCGMouseButtonLeft); // kCGMouseButtonLeft is ignored
    CGEventPost(kCGHIDEventTap, move);
    CFRelease(move);
    
    [self performActionAtPoint:p];
}

@end
