/**
 * Copyright (c) 2007-2021, Carsten Blüm <carsten@bluem.net>
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

#pragma mark - ActionProtocol

+ (NSString *)commandShortcut {
    return @"t";
}

+ (NSString *)commandDescription {
    return @"  t:text  Will TYPE the given TEXT into the frontmost application.\n"
            "          If the text includes space(s), it must be enclosed in quotes.\n"
            "          Example: “t:Test” will type “Test” \n"
            "          Example: “t:'Viele Grüße'” will type “Viele Grüße”";
}

#pragma mark - KeyBaseAction

- (void)performActionWithKeycode:(CGKeyCode)code {
    CGEventRef e1 = CGEventCreateKeyboardEvent(NULL, code, true);
    CGEventPost(kCGSessionEventTap, e1);
    CFRelease(e1);

    CGEventRef e2 = CGEventCreateKeyboardEvent(NULL, code, false);
    CGEventPost(kCGSessionEventTap, e2);
    CFRelease(e2);
}

- (void)performActionWithData:(NSString *)data
                  withOptions:(struct ExecutionOptions)options {

    struct timespec waitingtime;
    waitingtime.tv_sec = 0;
    waitingtime.tv_nsec = 10 * 1000000; // Milliseconds

    NSString *shortcut = [[self class] commandShortcut];

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected a string. Examples: “%@:Hello” or “%@:'Hello world'”",
         shortcut, shortcut, shortcut];
    }

    if (MODE_REGULAR != options.mode) {
        [options.verbosityOutputHandler write:[NSString stringWithFormat:@"Type: “%@”", data]];
        if (MODE_TEST == options.mode) {
            return;
        }
    }

    // Generate the key code mapping
    KeycodeInformer *ki = [KeycodeInformer sharedInstance];

    NSArray *keyCodeInfos = [ki keyCodesForString:data];

    NSUInteger j, jj;

    for (j = 0, jj = [keyCodeInfos count]; j < jj; ++j) {

        NSArray *keyCodeInfo = [keyCodeInfos objectAtIndex:j];

        CGKeyCode keyCode = [[keyCodeInfo objectAtIndex:0] intValue];

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_SHIFT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_SHIFT, true);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);
        }

        nanosleep(&waitingtime, NULL); // Note: the delay is not needed for all keys. Strange, but true.

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_ALT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_ALT, true);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);
        }

        nanosleep(&waitingtime, NULL);

        CGEventRef keyDownEvent = CGEventCreateKeyboardEvent(NULL, keyCode, true);
        CGEventPost(kCGSessionEventTap, keyDownEvent);
        CFRelease(keyDownEvent);

        CGEventRef keyUpEvent = CGEventCreateKeyboardEvent(NULL, keyCode, false);
        CGEventPost(kCGSessionEventTap, keyUpEvent);
        CFRelease(keyUpEvent);

        nanosleep(&waitingtime, NULL);

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_ALT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_ALT, false);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);
        }

        nanosleep(&waitingtime, NULL);

        if ([[keyCodeInfo objectAtIndex:1] intValue] & MODIFIER_SHIFT) {
            CGEventRef e = CGEventCreateKeyboardEvent(NULL, KEYCODE_SHIFT, false);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);
        }

        nanosleep(&waitingtime, NULL);
    }
}

@end
