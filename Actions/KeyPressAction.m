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

#import "KeyPressAction.h"

@implementation KeyPressAction

+(NSString *)commandShortcut {
    return @"kp";
}

+(NSString *)commandDescription {
    NSString *keyList = [[self class] getSupportedKeysAsStringBreakingAt:65 indentWith:@"          "];
    NSString *format = @"  kp:key  Will emulate PRESSING A KEY (key down + key up). Possible keys are:\n%@\n"
                       "          Example: “kp:return” will hit the return key.";
    return [NSString stringWithFormat:format, keyList];
}

-(void)performActionWithKeycode:(CGKeyCode)code {    
    CGEventRef e1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, true);
    CGEventPost(kCGSessionEventTap, e1);

    CGEventRef e2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, false);
    CGEventPost(kCGSessionEventTap, e2);
}

-(NSString *)actionDescriptionString:(NSString *)keyName {
    return [NSString stringWithFormat:@"Press + release %@ key", keyName];
}

+(NSDictionary *)getSupportedKeycodes {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"36", @"return",
            @"53", @"esc",
            @"48", @"tab",
            @"49", @"space",
            @"51", @"delete",
            @"117", @"fwd-delete",
            @"122", @"f1",
            @"120", @"f2",
            @"99",  @"f3",
            @"118", @"f4",
            @"96",  @"f5",
            @"97",  @"f6",
            @"98",  @"f7",
            @"100", @"f8",
            @"101", @"f9",
            @"109", @"f10",
            @"103", @"f11",
            @"111", @"f12",
            @"105", @"f13",
            @"107", @"f14",
            @"113", @"f15",
            @"106", @"f16",
            @"126", @"arrow-up",
            @"125", @"arrow-down",
            @"123", @"arrow-left",
            @"124", @"arrow-right",
            @"115", @"home",
            @"119", @"end",
            @"116", @"page-up",
            @"121", @"page-down",
            @"74",  @"mute",
            @"72",  @"volume-up",
            @"73",  @"volume-down",
            @"114", @"help",
            nil];
}

@end
