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

#import "KeyPressAction.h"

@implementation KeyPressAction

#pragma mark - ActionProtocol

+ (NSString *)commandShortcut {
    return @"kp";
}

+ (NSString *)commandDescription {
    NSString *keyList = [[self class] getSupportedKeysIndentedWith:@"            - "];
    NSString *format = @"  kp:key  Will emulate PRESSING A KEY (key down + key up). Possible keys are:\n%@\n"
                       "          Example: “kp:return” will hit the return key.";
    return [NSString stringWithFormat:format, keyList];
}

#pragma mark - KeyBaseAction

+ (NSDictionary *)getSupportedKeycodes {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // See /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
            @"36", @"return",
            @"76", @"enter",
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
            // The following keys are also from Events.h, but are hardware-dependend (= represent physical
            // keys, what is probably wanted when triggering numpad keys)
            @"82",  @"num-0",
            @"83",  @"num-1",
            @"84",  @"num-2",
            @"85",  @"num-3",
            @"86",  @"num-4",
            @"87",  @"num-5",
            @"88",  @"num-6",
            @"89",  @"num-7",
            @"91",  @"num-8",
            @"92",  @"num-9",
            @"71",  @"num-clear",
            @"81",  @"num-equals",
            @"75",  @"num-divide",
            @"67",  @"num-multiply",
            @"78",  @"num-minus",
            @"69",  @"num-plus",
            @"76",  @"num-enter",

            // "NSSystemDefined" events, see list in IOKit/hidsystem/ev_keymap.h
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_MUTE], @"mute",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_SOUND_UP], @"volume-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_SOUND_DOWN], @"volume-down",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_BRIGHTNESS_UP], @"brightness-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_BRIGHTNESS_DOWN], @"brightness-down",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_PLAY], @"play-pause",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_PREVIOUS], @"play-previous",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_NEXT], @"play-next",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_TOGGLE], @"keys-light-toggle",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_UP], @"keys-light-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_DOWN], @"keys-light-down",
            nil];
}

- (BOOL)keyCodeRequiresSystemDefinedEvent:(CGKeyCode)code {
    return code == NX_KEYTYPE_SOUND_UP ||
           code == NX_KEYTYPE_SOUND_DOWN ||
           code == NX_KEYTYPE_MUTE ||
           code == NX_KEYTYPE_PLAY ||
           code == NX_KEYTYPE_BRIGHTNESS_UP ||
           code == NX_KEYTYPE_BRIGHTNESS_DOWN ||
           code == NX_KEYTYPE_PLAY ||
           code == NX_KEYTYPE_PREVIOUS ||
           code == NX_KEYTYPE_NEXT ||
           code == NX_KEYTYPE_ILLUMINATION_UP ||
           code == NX_KEYTYPE_ILLUMINATION_DOWN ||
           code == NX_KEYTYPE_ILLUMINATION_TOGGLE
           ;
}

- (void)performActionWithKeycode:(CGKeyCode)code {

    if ([self keyCodeRequiresSystemDefinedEvent:code]) {
        NSEvent *e1 = [NSEvent otherEventWithType:NSSystemDefined
                                         location:NSZeroPoint
                                    modifierFlags:0xa00
                                        timestamp:0
                                     windowNumber:0
                                          context:0
                                          subtype:8
                                            data1:((code << 16) | (0xa << 8))
                                            data2:-1];
        CGEventPost(0, [e1 CGEvent]);

        NSEvent *e2 = [NSEvent otherEventWithType:NSSystemDefined
                                         location:NSZeroPoint
                                    modifierFlags:0xb00
                                        timestamp:0
                                     windowNumber:0
                                          context:0
                                          subtype:8
                                            data1:((code << 16) | (0xb << 8))
                                            data2:-1];

        CGEventPost(0, [e2 CGEvent]);
    } else {
        CGEventRef e1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, true);
        CGEventRef e2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)code, false);
        CGEventPost(kCGSessionEventTap, e1);
        CGEventPost(kCGSessionEventTap, e2);
        CFRelease(e1);
        CFRelease(e2);
    }
}

- (NSString *)actionDescriptionString:(NSString *)keyName {
    return [NSString stringWithFormat:@"Press + release %@ key", keyName];
}

@end
