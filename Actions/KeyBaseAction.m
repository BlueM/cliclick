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
    
    NSDictionary *keycodes = [NSDictionary dictionaryWithObjectsAndKeys:@"59", @"ctrl", @"55", @"cmd", @"58", @"alt", 
                                                                        @"36", @"return", @"53", @"esc", 
                                                                        @"48", @"tab", @"49",@"space",
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
                                                                        @"37", @"l", 
                                                                        @"38", @"j", 
                                                                        @"39", @"'", 
                                                                        @"40", @"k", 
                                                                        @"41", @";", 
                                                                        @"42", @"\\", 
                                                                        @"43", @",", 
                                                                        @"44", @"/", 
                                                                        @"45", @"n", 
                                                                        @"46", @"m", 
                                                                        @"47", @".", 
                                                                        @"50", @"`", 
                                                                        @"51", @"delete", 
                                                                        @"65", @".", 
//                                                                        @"66", @"", 
                                                                        @"67", @"*", 
//                                                                        @"68", @"", 
                                                                        @"69", @"+", 
                                                                        @"70", @"", 
                                                                        @"71", @"CLEAR", 
                                                                        @"75", @"/", 
                                                                        @"78", @"-", 
                                                                        @"81", @"=", 
                                                                        @"82", @"0", 
                                                                        @"83", @"1", 
                                                                        @"84", @"2", 
                                                                        @"85", @"3", 
                                                                        @"86", @"4", 
                                                                        @"87", @"5", 
                                                                        @"88", @"6", 
                                                                        @"89", @"7", 
                                                                        @"91", @"8", 
                                                                        @"92", @"9", 
                                                                        @"96", @"F5", 
                                                                        @"97", @"F6", 
                                                                        @"98", @"F7", 
                                                                        @"99", @"F3", 
                                                                        @"100", @"F8", 
                                                                        @"101", @"F9", 
                                                                        @"103", @"F11", 
                                                                        @"105", @"F13", 
                                                                        @"107", @"F14", 
                                                                        @"109", @"F10", 
                                                                        @"111", @"F12", 
                                                                        @"113", @"F15", 
                                                                        @"114", @"help", 
                                                                        @"115", @"home", 
                                                                        @"116", @"pgup", 
                                                                        @"117", @"delete", 
                                                                        @"118", @"F4", 
                                                                        @"119", @"end", 
                                                                        @"120", @"F2", 
                                                                        @"121", @"pgdown", 
                                                                        @"122", @"F1", 
                                                                        @"123", @"left", 
                                                                        @"124", @"right", 
                                                                        @"125", @"down", 
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
    return @"";
}

-(void)performActionWithKeycode:(CGKeyCode)code {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

@end
