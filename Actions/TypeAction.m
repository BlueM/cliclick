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

#import "TypeAction.h"

@implementation TypeAction

+(NSString *)commandListShortcut {
    return @"t";
}

+(NSString *)commandDescription {
    return @"  t:text  Will emulate typing the given text. If the text includes space(s), it\n"
            "          must be enclosed in quotes.\n"
            "          Example: “type:Test” will type “Test” into the frontmost application\n"
            "          Example: “type:'Viele Grüße'” will type “Viele Grüße” into the frontmost application";
}

-(void)performActionWithKeycode:(CGKeyCode)code {    
    CGEventRef e1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, true);
    CGEventPost(kCGSessionEventTap, e1);

    CGEventRef e2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, false);
    CGEventPost(kCGSessionEventTap, e2);
}

-(void)performActionWithData:(NSString *)data inMode:(unsigned)mode {

    struct timespec waitingtime;
    waitingtime.tv_sec = 0;
    waitingtime.tv_nsec = 5 * 1000000; // Milliseconds

    NSString *shortcut = [[self class] commandListShortcut];
    
    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected s string. Examples: “%@:Hello” or “%@:'Hello world'”",
         shortcut, shortcut, shortcut];
    }
  
    if (MODE_TEST == mode) {
        printf("Type: “%s”\n", [data UTF8String]);
        return;
    }

    // Generate the key code mapping
    KeyInfo *ki = [[KeyInfo alloc] init];
     
    for (unsigned i = 0, ii = [data length]; i < ii; i ++) {

        NSRange range = [data rangeOfComposedCharacterSequenceAtIndex:i];
        if (range.length > 1) {
            i += range.length - 1;
        }
        
        NSArray *keyCodeInfo = [ki keyCodeForString:[data substringWithRange:range]];

        CGKeyCode keyCode = [[keyCodeInfo objectAtIndex:0] intValue];

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_SHIFT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_SHIFT, true);
            CGEventPost(kCGSessionEventTap, e);
        }

        nanosleep(&waitingtime, NULL); // Note: the delay is not needed for all keys. Strange, but true.

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_ALT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_ALT, true);
            CGEventPost(kCGSessionEventTap, e);
        }

        nanosleep(&waitingtime, NULL);

        CGEventPost(kCGSessionEventTap, CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, true));
        CGEventPost(kCGSessionEventTap, CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, false));

        nanosleep(&waitingtime, NULL);

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_ALT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_ALT, false);
            CGEventPost(kCGSessionEventTap, e);
        }

        nanosleep(&waitingtime, NULL);

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_SHIFT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_SHIFT, false);
            CGEventPost(kCGSessionEventTap, e);
        }

        nanosleep(&waitingtime, NULL);
    }

}

@end
