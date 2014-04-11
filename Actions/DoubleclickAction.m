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

#import "DoubleclickAction.h"

@implementation DoubleclickAction

+(NSString *)commandListShortcut {
    return @"dc";
}

+(NSString *)commandDescription {
    return @"  dc:x,y  Will DOUBLE-CLICK at the point with the given coordinates.\n"
    "          Example: “dc:12,34” will double-click at the point with x\n"
    "          coordinate 12 and y coordinate 34. Instead of x and y values,\n"
    "          you may also use “.”, which means: the current position.";
}

-(NSString *)actionDescriptionString:(NSString *)locationDescription {
    return [NSString stringWithFormat:@"Double-click at %@", locationDescription];
}

-(void)performActionAtPoint:(CGPoint) p {
    
    // Left button down
    CGEventRef mouseEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(p.x, p.y), kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseEvent);
    
    // Left button up
    CGEventSetType(mouseEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, mouseEvent);

    // 2nd click
    CGEventSetIntegerValueField(mouseEvent, kCGMouseEventClickState, 2);
    
    CGEventSetType(mouseEvent, kCGEventLeftMouseDown);  
    CGEventPost(kCGHIDEventTap, mouseEvent);  
    
    CGEventSetType(mouseEvent, kCGEventLeftMouseUp); 
    CGEventPost(kCGHIDEventTap, mouseEvent); 
    
    CFRelease(mouseEvent);    
}

@end
