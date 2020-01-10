/**
 * Copyright (c) 2007-2018, Carsten Blüm <carsten@bluem.net>
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
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

@implementation MouseBaseAction

+ (int)getCoordinate:(NSString *)unparsedValue
             forAxis:(CLICLICKAXIS)axis {

    [[self class] validateAxisValue:unparsedValue forAxis:axis];

    if ([[unparsedValue substringToIndex:1] isEqualToString:@"+"] ||
        [[unparsedValue substringToIndex:1] isEqualToString:@"-"]) {
        // Relative value
        CGEventRef dummyEvent = CGEventCreate(NULL);
        CGPoint ourLoc = CGEventGetLocation(dummyEvent);
        int positionDiff = [unparsedValue intValue];
        int currentPosition = axis == XAXIS ? (int)ourLoc.x : (int)ourLoc.y;
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

+ (void)validateAxisValue:(NSString *)string
                  forAxis:(CLICLICKAXIS)axis {
    NSString *regex = @"^=?[+-]?\\d+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:string] != YES) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Invalid %@ axis coordinate “%@” given", XAXIS == axis ? @"X" : @"Y", string];
    }
}

- (NSString *)actionDescriptionString:(NSString *)locationDescription {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
    return @"Will never be reached, but makes Xcode happy ;-)";
}

- (void)performActionAtPoint:(CGPoint)p {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

#pragma mark - ActionProtocol

- (void)performActionWithData:(NSString *)data
                 withOptions:(struct ExecutionOptions)options {

    CGPoint p;
    NSString *shortcut = [[self class] commandShortcut];
    NSString *verboseLoc;

    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint currentLocation = CGEventGetLocation(ourEvent);
    CFRelease(ourEvent);

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected two coordinates (separated by a comma) or “.”. Examples: “%@:123,456” or “%@:.”",
                           shortcut, shortcut, shortcut];
    } else if ([data isEqualToString:@"."]) {
        // Use current location
        p.x = (int)currentLocation.x;
        p.y = (int)currentLocation.y;
        verboseLoc = @"current location";
    } else {
        NSArray *coords = [data componentsSeparatedByString:@","];

        if ([coords count] != 2 ||
            [[coords objectAtIndex:0] isEqualToString:@""] ||
            [[coords objectAtIndex:1] isEqualToString:@""])
        {
            [NSException raise:@"InvalidCommandException"
                        format:@"Invalid argument “%@” to command “%@”: Expected two coordinates (separated by a comma) or “.”. Examples: “%@:123,456” or “%@:.”",
                               data, shortcut, shortcut, shortcut];
        }

        p.x = [[self class] getCoordinate:[coords objectAtIndex:0] forAxis:XAXIS];
        p.y = [[self class] getCoordinate:[coords objectAtIndex:1] forAxis:YAXIS];

        verboseLoc = [NSString stringWithFormat:@"%@,%@", [coords objectAtIndex:0], [coords objectAtIndex:1]];
    }

    if (MODE_REGULAR != options.mode) {
        [options.verbosityOutputHandler write:[self actionDescriptionString:verboseLoc]];
    }

    if (MODE_TEST == options.mode) {
        return;
    }

    if (options.easing) {
        // Eased move
        [self postHumanizedMouseEventsWithEasingFactor:options.easing
                                                   toX:(float)p.x
                                                   toY:(float)p.y];
    } else {
        // Move
        CGEventRef move = CGEventCreateMouseEvent(NULL, [self getMoveEventConstant], p, kCGMouseButtonLeft); // kCGMouseButtonLeft is ignored
        CGEventPost(kCGHIDEventTap, move);
        CFRelease(move);
    }

    [self performActionAtPoint:p];
}

- (uint32_t)getMoveEventConstant {
    return kCGEventMouseMoved;
}

- (void)postHumanizedMouseEventsWithEasingFactor:(unsigned)easing
                                             toX:(float)endX
                                             toY:(float)endY {

    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint currentLocation = CGEventGetLocation(ourEvent);
    CFRelease(ourEvent);
    uint32_t eventConstant = [self getMoveEventConstant];
    float startX = currentLocation.x;
    float startY = currentLocation.y;
    float distance = [self distanceBetweenPoint:NSPointFromCGPoint(currentLocation) andPoint:NSMakePoint(endX, endY)];

    unsigned steps = ((int)(distance * easing / 100)) + 1;
    float xDiff = (endX - startX);
    float yDiff = (endY - startY);
    float stepSize = 1.0 / (float)steps;

    for (unsigned i = 0; i < steps; i ++) {
        float factor = [self cubicEaseInOut:(stepSize * i)];
        CGEventRef eventRef = CGEventCreateMouseEvent(NULL, eventConstant, CGPointMake(startX + (factor * xDiff), startY + (factor * yDiff)), 0);
        CGEventPost(kCGHIDEventTap, eventRef);
        CFRelease(eventRef);
        usleep(220);
    }
}

- (float) distanceBetweenPoint:(NSPoint)a andPoint:(NSPoint)b {
    float dX = a.x - b.x,
          dY = a.y - b.y;
    return sqrt(dX * dX + dY * dY);
}

// Modeled after the piecewise cubic
// y = (1/2)((2x)^3)       ; [0, 0.5]
// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
//
// Source: AHEasing, License: WTFPL
//
// Expects [whatever action] to be split up into small steps represented
// by a float from 0 (start) to 1 (end). Method is to be called with the float
// and returns an "eased float" for it.
- (float)cubicEaseInOut:(float)p {
    if (p < 0.5) {
        return 4 * p * p * p;
    } else {
        float f = ((2 * p) - 2);
        return 0.5 * f * f * f + 1;
    }
}

@end
