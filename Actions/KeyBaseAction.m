/**
 * Copyright (c) 2007-2013, Carsten Blüm <carsten@bluem.net>
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

#import "KeyBaseAction.h"

@implementation KeyBaseAction

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {
    
    NSString *shortcut = [[self class] commandListShortcut];
    
    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected one or more keys (separated by a comma). Examples: “%@:ctrl” or “%@:cmd,alt”",
         shortcut, shortcut, shortcut];
    }
    
    NSDictionary *keycodes = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"59", @"ctrl",
                              @"55", @"cmd",
                              @"58", @"alt",
                              @"36", @"return",
                              @"53", @"esc",
                              // Based on http://web.archive.org/web/20100501161453/http://www.classicteck.com/rbarticles/mackeyboard.php
                              @"0", @"a",
                              @"1", @"s",
                              @"2", @"d",
                              @"3", @"f",
                              @"4", @"h",
                              @"5", @"g",
                              @"6", @"z",
                              @"7", @"x",
                              @"8", @"c",
                              @"9", @"v",
                              // 10 what are you?
                              @"11", @"b",
                              @"12", @"q",
                              @"13", @"w",
                              @"14", @"e",
                              @"15", @"r",
                              @"16", @"y",
                              @"17", @"t",
                              @"18", @"1",
                              @"19", @"2",
                              @"20", @"3",
                              @"21", @"4",
                              @"22", @"6",
                              @"23", @"5",
                              @"24", @"=",
                              @"25", @"9",
                              @"26", @"7",
                              @"27", @"-",
                              @"28", @"8",
                              @"29", @"0",
                              @"30", @"]",
                              @"31", @"o",
                              @"32", @"u",
                              @"33", @"[",
                              @"34", @"i",
                              @"35", @"p",
                              // return is above
                              @"37", @"l",
                              @"38", @"j",
                              @"39", @"'",
                              @"40", @"k",
                              @"41", @";",
                              @"42", @"\\",
                              @"43", @"comma",
                              @"44", @"/",
                              @"45", @"n",
                              @"46", @"m",
                              @"47", @".",
                              @"48", @"tab",
                              @"49", @"space",
                              @"50", @"tilde",
                              @"51", @"delete",
                              // esc is above
                              // cmd is above
                              // More unmappped
                              @"56", @"shift",
                              @"57", @"capslock",
                              // menu/alt/option is above
                              // control is above
                              // More unmapped
                              @"63", @"fn",
                              // More unmapped
                              @"65", @"decimal",
                              // More unmapped
                              @"67", @"multiply",
                              // More unmapped
                              @"69", @"add",
                              // More unmapped
                              @"75", @"divide",
                              @"76", @"enter",
                              // More unmapped
                              @"78", @"subtract",
                              // More unmapped
                              @"81", @"numequal",
                              @"82", @"num0",
                              @"83", @"num1",
                              @"84", @"num2",
                              @"85", @"num3",
                              @"86", @"num4",
                              @"87", @"num5",
                              @"88", @"num6",
                              @"89", @"num7",
                              // More unmapped
                              @"91", @"num8",
                              @"92", @"num9",
                              // More unmapped
                              @"96", @"f5",
                              @"97", @"f6",
                              @"98", @"f7",
                              @"99", @"f3",
                              @"100", @"f8",
                              @"101", @"f9",
                              @"103", @"f11",
                              // More unmapped
                              @"109", @"f10",
                              @"110", @"winapp",
                              @"111", @"f12",
                              // More unmapped
                              @"114", @"help",
                              @"115", @"home",
                              @"116", @"pageup",
                              @"117", @"backspace",
                              @"118", @"f4",
                              @"119", @"end",
                              @"120", @"f2",
                              @"121", @"pagedown",
                              @"122", @"f1",
                              @"123", @"left",
                              @"124", @"right",
                              @"125", @"down",
                              @"126", @"up",
                              nil];
    NSArray *keys = [data componentsSeparatedByString:@","];
    NSUInteger i, count = [keys count];
    
    // First, validate the key names
    for (i = 0; i < count; i++) {
        NSObject *keyname = [keys objectAtIndex:i];
        if (![keycodes objectForKey:keyname]) {
            [NSException raise:@"InvalidCommandException"
                        format:@"Invalid argument key name “%@” to command “%@”.\nThe key name may only be one of: %@",
                               keyname, shortcut, [[keycodes allKeys] componentsJoinedByString:@" "]];
        }
    }
    
    // Then, "press" the key down
    for (i = 0; i < count; i++) {
        unsigned code = [[keycodes objectForKey:[keys objectAtIndex:i]] intValue];

        if (MODE_REGULAR != mode) {
            NSString *description = [self actionDescriptionString:[keys objectAtIndex:i]];
            printf("%s\n", [description UTF8String]);
        }
        
        if (MODE_TEST != mode) {
            [self performActionWithKeycode:(CGKeyCode)code];
        }        
    }    
}

-(NSString *)actionDescriptionString:(NSString *)keyName {    
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

-(void)performActionWithKeycode:(CGKeyCode)code {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

@end
