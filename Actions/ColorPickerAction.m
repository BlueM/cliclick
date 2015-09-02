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

#import "ColorPickerAction.h"
#import "MouseBaseAction.h"

@implementation ColorPickerAction

#pragma mark - ActionProtocol

+(NSString *)commandShortcut {
    return @"cp";
}

+(NSString *)commandDescription {
    return @"  cp:str  Will PRINT the color value at the given screen location.\n"
    "          The color value is printed as four 8-bit values in decimal,\n"
    "          representing, in order, red, green, blue, and alpha.\n"
    "          Example: “cp:123,456” might print “127 63 0 255”";
}

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {

    NSString *shortcut = [[self class] commandShortcut];

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected two coordinates (separated by a comma). Example: “%@:123,456”",
                           shortcut, shortcut];
    } else {
        NSArray *coords = [data componentsSeparatedByString:@","];

        if ([coords count] != 2 ||
            [[coords objectAtIndex:1] isEqualToString:@""])
        {
            [NSException raise:@"InvalidCommandException"
                        format:@"Invalid argument “%@” to command “%@”: Expected two coordinates, separated by a comma. Example: “%@:123,456”",
                               data, shortcut, shortcut];
        }

        if (MODE_TEST == mode) {
            printf("Print color value of given location\n");
        } else {
            CGPoint p;
            p.x = [MouseBaseAction getCoordinate:[coords objectAtIndex:0] forAxis:XAXIS];
            p.y = [MouseBaseAction getCoordinate:[coords objectAtIndex:1] forAxis:YAXIS];

            CGRect imageRect = CGRectMake(p.x, p.y, 1, 1);
            CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
            NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
            NSColor *color = [bitmap colorAtX:0 y:0];

            printf("%d %d %d %d\n", (int)(color.redComponent*255), (int)(color.greenComponent*255), (int)(color.blueComponent*255), (int)(color.alphaComponent*255));
        }
    }

}

@end
