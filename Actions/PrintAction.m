/**
 * Copyright (c) 2007-2015, Carsten Blüm <carsten@bluem.net>
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

#import "PrintAction.h"

@implementation PrintAction

#pragma mark - ActionProtocol

+(NSString *)commandShortcut {
    return @"p";
}

+(NSString *)commandDescription {
    return @"  p[:str] Will PRINT the given string. If the string is “.”, the current\n"
    "          MOUSE POSITION is printed. As a convenience, you can skip the\n"
    "          string completely and just write “p” to get the current position.\n"
    "          Example: “p:.” or “p” will print the current mouse position\n"
    "          Example: “p:'Hello world'” will print “Hello world”";
}

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode
            withEasingFactor:(unsigned)easing {

    if ([data isEqualToString:@""] ||
        [data isEqualToString:@"."]) {
        if (MODE_TEST == mode) {
            printf("Print the current mouse position");
        } else {
            CGEventRef ourEvent = CGEventCreate(NULL);
            CGPoint    ourLoc   = CGEventGetLocation(ourEvent);
            NSPoint    point    = NSPointFromCGPoint(ourLoc);
            printf("Current mouse position: %.0f,%.0f\n", point.x, point.y);
            CFRelease(ourEvent);
        }
        return;
    }
    
    if (MODE_TEST == mode) {
        printf("Print message “%s”\n", [data UTF8String]);
    } else {
        printf("%s\n", [data UTF8String]);
    }
}

@end
