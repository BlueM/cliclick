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

#import "KeyPressAction.h"
#import "KeycodeInformer.h"

@implementation KeyPressAction

#pragma mark - ActionProtocol

+(NSString *)commandShortcut {
    return @"kp";
}

+(NSString *)commandDescription {
    NSString *keyList = [[self class] getSupportedKeysIndentedWith:@"            - "];
    NSString *format = @"  kp:key  Will emulate PRESSING A KEY (key down + key up). Possible keys are:\n%@\n"
                       "          Example: “kp:return” will hit the return key.";
    return [NSString stringWithFormat:format, keyList];
}

#pragma mark - KeyBaseAction
+(NSString*)keyCodesForCharacter:(NSString*)character
{
    KeycodeInformer *ki = [KeycodeInformer sharedInstance];
    NSArray* keyCodeInfo = [ki keyCodesForString:character].firstObject;
    NSString* keyCode = [keyCodeInfo objectAtIndex:0];
    return keyCodeInfo?keyCode: @"-1";
}

+(NSDictionary *)getSupportedKeycodes {

    return [NSDictionary dictionaryWithObjectsAndKeys:
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
            // "NSSystemDefined" events, see list in IOKit/hidsystem/ev_keymap.h
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_MUTE],  @"mute",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_SOUND_UP],  @"volume-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_SOUND_DOWN],  @"volume-down",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_BRIGHTNESS_UP],  @"brightness-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_BRIGHTNESS_DOWN],  @"brightness-down",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_PLAY],  @"play-pause",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_PREVIOUS],  @"play-previous",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_NEXT],  @"play-next",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_TOGGLE],  @"keys-light-toggle",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_UP],  @"keys-light-up",
            [NSString stringWithFormat:@"%i", NX_KEYTYPE_ILLUMINATION_DOWN],  @"keys-light-down",

            // Char
            [self keyCodesForCharacter:@"!"], @"!",
            [self keyCodesForCharacter:@"\""], @"\"",
            [self keyCodesForCharacter:@"#"], @"#",
            [self keyCodesForCharacter:@"$"], @"$",
            [self keyCodesForCharacter:@"%"], @"%",
            [self keyCodesForCharacter:@"&"], @"&",
            [self keyCodesForCharacter:@"'"], @"'",
            [self keyCodesForCharacter:@"("], @"(",
            [self keyCodesForCharacter:@")"], @")",
            [self keyCodesForCharacter:@"*"], @"*",
            [self keyCodesForCharacter:@"+"], @"+",
            [self keyCodesForCharacter:@","], @",",
            [self keyCodesForCharacter:@"-"], @"-",
            [self keyCodesForCharacter:@"."], @".",
            [self keyCodesForCharacter:@"/"], @"/",
            [self keyCodesForCharacter:@"0"], @"0",
            [self keyCodesForCharacter:@"1"], @"1",
            [self keyCodesForCharacter:@"2"], @"2",
            [self keyCodesForCharacter:@"3"], @"3",
            [self keyCodesForCharacter:@"4"], @"4",
            [self keyCodesForCharacter:@"5"], @"5",
            [self keyCodesForCharacter:@"6"], @"6",
            [self keyCodesForCharacter:@"7"], @"7",
            [self keyCodesForCharacter:@"8"], @"8",
            [self keyCodesForCharacter:@"9"], @"9",
            [self keyCodesForCharacter:@":"], @":",
            [self keyCodesForCharacter:@";"], @";",
            [self keyCodesForCharacter:@"<"], @"<",
            [self keyCodesForCharacter:@"="], @"=",
            [self keyCodesForCharacter:@">"], @">",
            [self keyCodesForCharacter:@"?"], @"?",
            [self keyCodesForCharacter:@"@"], @"@",
            [self keyCodesForCharacter:@"A"], @"A",
            [self keyCodesForCharacter:@"B"], @"B",
            [self keyCodesForCharacter:@"C"], @"C",
            [self keyCodesForCharacter:@"D"], @"D",
            [self keyCodesForCharacter:@"E"], @"E",
            [self keyCodesForCharacter:@"F"], @"F",
            [self keyCodesForCharacter:@"G"], @"G",
            [self keyCodesForCharacter:@"H"], @"H",
            [self keyCodesForCharacter:@"I"], @"I",
            [self keyCodesForCharacter:@"J"], @"J",
            [self keyCodesForCharacter:@"K"], @"K",
            [self keyCodesForCharacter:@"L"], @"L",
            [self keyCodesForCharacter:@"M"], @"M",
            [self keyCodesForCharacter:@"N"], @"N",
            [self keyCodesForCharacter:@"O"], @"O",
            [self keyCodesForCharacter:@"P"], @"P",
            [self keyCodesForCharacter:@"Q"], @"Q",
            [self keyCodesForCharacter:@"R"], @"R",
            [self keyCodesForCharacter:@"S"], @"S",
            [self keyCodesForCharacter:@"T"], @"T",
            [self keyCodesForCharacter:@"U"], @"U",
            [self keyCodesForCharacter:@"V"], @"V",
            [self keyCodesForCharacter:@"W"], @"W",
            [self keyCodesForCharacter:@"X"], @"X",
            [self keyCodesForCharacter:@"Y"], @"Y",
            [self keyCodesForCharacter:@"Z"], @"Z",
            [self keyCodesForCharacter:@"["], @"[",
            [self keyCodesForCharacter:@"\\"], @"\\",
             [self keyCodesForCharacter:@"]"], @"]",
             [self keyCodesForCharacter:@"^"], @"^",
             [self keyCodesForCharacter:@"_"], @"_",
             [self keyCodesForCharacter:@"`"], @"`",
             [self keyCodesForCharacter:@"a"], @"a",
             [self keyCodesForCharacter:@"b"], @"b",
             [self keyCodesForCharacter:@"c"], @"c",
             [self keyCodesForCharacter:@"d"], @"d",
             [self keyCodesForCharacter:@"e"], @"e",
             [self keyCodesForCharacter:@"f"], @"f",
             [self keyCodesForCharacter:@"g"], @"g",
             [self keyCodesForCharacter:@"h"], @"h",
             [self keyCodesForCharacter:@"i"], @"i",
             [self keyCodesForCharacter:@"j"], @"j",
             [self keyCodesForCharacter:@"k"], @"k",
             [self keyCodesForCharacter:@"l"], @"l",
             [self keyCodesForCharacter:@"m"], @"m",
             [self keyCodesForCharacter:@"n"], @"n",
             [self keyCodesForCharacter:@"o"], @"o",
             [self keyCodesForCharacter:@"p"], @"p",
             [self keyCodesForCharacter:@"q"], @"q",
             [self keyCodesForCharacter:@"r"], @"r",
             [self keyCodesForCharacter:@"s"], @"s",
             [self keyCodesForCharacter:@"t"], @"t",
             [self keyCodesForCharacter:@"u"], @"u",
             [self keyCodesForCharacter:@"v"], @"v",
             [self keyCodesForCharacter:@"w"], @"w",
             [self keyCodesForCharacter:@"x"], @"x",
             [self keyCodesForCharacter:@"y"], @"y",
             [self keyCodesForCharacter:@"z"], @"z",
             [self keyCodesForCharacter:@"{"], @"{",
             [self keyCodesForCharacter:@"|"], @"|",
             [self keyCodesForCharacter:@"}"], @"}",
             [self keyCodesForCharacter:@"~"], @"~",

            nil];
}

-(BOOL)keyCodeRequiresSystemDefinedEvent:(CGKeyCode)code {
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

-(void)performActionWithKeycode:(CGKeyCode)code {

    if ([self keyCodeRequiresSystemDefinedEvent:code]) {
        NSEvent *e1 = [NSEvent otherEventWithType:NSSystemDefined
                                         location:NSPointFromCGPoint(CGPointZero)
                                    modifierFlags:0xa00
                                        timestamp:0
                                     windowNumber:0
                                          context:0
                                          subtype:8
                                            data1:((code << 16) | (0xa << 8))
                                            data2:-1];
        CGEventPost(0, [e1 CGEvent]);

        NSEvent *e2 = [NSEvent otherEventWithType:NSSystemDefined
                                         location:NSPointFromCGPoint(CGPointZero)
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

-(NSString *)actionDescriptionString:(NSString *)keyName {
    return [NSString stringWithFormat:@"Press + release %@ key", keyName];
}

@end
