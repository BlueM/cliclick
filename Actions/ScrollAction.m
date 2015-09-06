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

#import "ScrollAction.h"

@implementation ScrollAction

#pragma mark - ActionProtocol

+(NSString *)commandShortcut {
    return @"sp";
}

+(NSString *)commandDescription {
    return @"  sp:str  Will send a mouse scroll event in the specifed number of pixels.\n"
    "          Pixel scrolling is generally interpreted as smooth scrolling.\n"
    "          You can specify up to three values, corresponding to three scroll wheels,\n"
    "          usually interpreted as vertical, horizontal, and depth.\n"
    "          Example: sp:10,2,0\n";
}

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {

    NSString *shortcut = [[self class] commandShortcut];

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected one to three values (separated by a comma). Example: “%@:5” or “%@:0,5,0”",
                           shortcut, shortcut, shortcut];
    } else {
        NSArray *scrollStrVals = [data componentsSeparatedByString:@","];
	int scrollVals[3];

        CGEventRef scrollEvent;

        switch([scrollStrVals count]) {
            case 1:
		scrollVals[0] = [[scrollStrVals objectAtIndex:0] intValue];
                scrollVals[1] = 0;
                scrollVals[2] = 0;
                if (MODE_VERBOSE == mode || MODE_TEST == mode) {
                    printf("Scroll up/down %d pixels\n", scrollVals[0]);
                }
                break;
            case 2:
		scrollVals[0] = [[scrollStrVals objectAtIndex:0] intValue];
		scrollVals[1] = [[scrollStrVals objectAtIndex:1] intValue];
                scrollVals[2] = 0;
                if (MODE_VERBOSE == mode || MODE_TEST == mode) {
                    printf("Scroll up/down %d pixels, left/right %d pixels\n", scrollVals[0], scrollVals[1]);
                }
                break;
            case 3:
		scrollVals[0] = [[scrollStrVals objectAtIndex:0] intValue];
		scrollVals[1] = [[scrollStrVals objectAtIndex:1] intValue];
		scrollVals[2] = [[scrollStrVals objectAtIndex:2] intValue];
                if (MODE_VERBOSE == mode || MODE_TEST == mode) {
                    printf("Scroll up/down %d pixels, left/right %d pixels, in/out %d pixels\n", scrollVals[0], scrollVals[1], scrollVals[2]);
                }
                break;
            default:
                [NSException raise:@"InvalidCommandException"
                            format:@"Invalid argument “%@” to command “%@”: Expected one to three values (separated by a comma). Example: “%@:5” or “%@:0,5,0”",
                                   data, shortcut, shortcut, shortcut];
                break;
        }

        if (MODE_TEST != mode) {
            /*
             * Rather than do a massive scroll all at once, split it into chunks of 10 pixels or fewer.
             * This is according to Apple docs:
             *
             * Scrolling movement is generally represented by small signed integer values, typically in a
             * range from -10 to +10. Large values may have unexpected results, depending on the application
             * that processes the event. 
             */
            int scrollDir[3];
            for (int i=0; i<3; i++) {
                if (scrollVals[i] > 0) {
                    scrollDir[i] = 1;
                } else {
                    scrollDir[i] = -1;
                    scrollVals[i] *= -1;
                }
            }
            while (scrollVals[0] > 0 ||
                   scrollVals[1] > 0 ||
                   scrollVals[2] > 0) {
                int scrollPart[3];
                for (int i=0; i<3; i++) {
                    scrollPart[i] = scrollVals[i];
                    if (scrollPart[i] > 10) {
                        scrollPart[i] = 10;
                        scrollVals[i] -= 10;
                    } else {
                        scrollVals[i] = 0;
                    }
                    scrollPart[i] *= scrollDir[i];
                }
                scrollEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, 3, scrollPart[0], scrollPart[1], scrollPart[2]);
                CGEventPost(kCGHIDEventTap, scrollEvent);
                CFRelease(scrollEvent);
            }
        }
    }

}

@end
