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
    
    /*
     * NOTE: If you would like to add more keys, you can of course add key codes here, but
     * please be aware that the codes of most keys depend on the keyboard layout and thus
     * will not necessarily work as intended for other users. So feel free to add key codes
     * for your personal needs, but I will not merge pull requests that extend this
     * list of codes with keys that are not "safe" (such as the ones currently in the list).
     * Cf. https://github.com/BlueM/cliclick/pull/2
     */
    
    // For layout-independent key codes, see:
    // /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    NSDictionary *keycodes = [NSDictionary dictionaryWithObjectsAndKeys:@"59", @"ctrl", @"55", @"cmd", @"58", @"alt", @"36", @"return", @"53", @"esc", nil];
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
    return @"Will never be reached, but makes Xcode happy ;-)";
}

-(void)performActionWithKeycode:(CGKeyCode)code {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

@end
