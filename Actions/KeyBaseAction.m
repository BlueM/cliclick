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

#import "KeyBaseAction.h"

@implementation KeyBaseAction

+(NSDictionary *)getSupportedKeycodes {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
    return [NSDictionary dictionaryWithObject:@"Will never be reached, but makes Xcode happy" forKey:@"Foo"];
}

+(NSString *)getSupportedKeysAsStringBreakingAt:(unsigned)width indentWith:(NSString *)indent {

    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:8];
    NSRange range;
    unsigned lastRangeStart = 0;
    unsigned effectiveWidth = width + [indent length];
    
    NSArray *sortedkeyNames = [[[[self class] getSupportedKeycodes] allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSString *keys = [NSString stringWithFormat:@"“%@”", [sortedkeyNames componentsJoinedByString:@"”, “"]];
    
    if ([keys length] <= effectiveWidth) {
        effectiveWidth = [keys length];
    }
    
    do {
        range = [keys rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(lastRangeStart, effectiveWidth)];
        if (range.location == NSNotFound || ([keys length] - range.location <= effectiveWidth)) {
            // No rest or rest of the string fits in last part
            [lines addObject:[indent stringByAppendingString:[keys substringFromIndex:lastRangeStart]]];
            break;
        }
        [lines addObject:[indent stringByAppendingString:[keys substringWithRange:NSMakeRange(lastRangeStart, range.location - lastRangeStart)]]];
        lastRangeStart = range.location + 1;
    } while (1);

    NSString *keyList = [lines componentsJoinedByString:@"\n"];
    [lines release];
    return keyList;
}

-(NSString *)actionDescriptionString:(NSString *)keyName {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
    return @"Will never be reached, but makes Xcode happy";
}

-(void)performActionWithKeycode:(CGKeyCode)code {
    [NSException raise:@"InvalidCommandException"
                format:@"To be implemented by subclasses"];
}

#pragma mark - ActionProtocol

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {

    NSString *shortcut = [[self class] commandShortcut];

    struct timespec waitingtime;
    waitingtime.tv_sec = 0;
    waitingtime.tv_nsec = 5 * 1000000; // Milliseconds

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected one or more keys (separated by a comma). Examples: “%@:ctrl” or “%@:cmd,alt”",
         shortcut, shortcut, shortcut];
    }

    NSDictionary *keycodes = [[self class] getSupportedKeycodes];
    NSArray *keys          = [data componentsSeparatedByString:@","];
    NSUInteger i, count    = [keys count];

    // First, validate the key names
    for (i = 0; i < count; i++) {
        NSObject *keyname = [keys objectAtIndex:i];
        if (![keycodes objectForKey:keyname]) {
            [NSException raise:@"InvalidCommandException"
                        format:@"Invalid key “%@” given as argument to command “%@”.\nThe key name may only be one of:\n%@",
                               keyname, shortcut, [[self class] getSupportedKeysAsStringBreakingAt:60 indentWith:@"  "]];
        }
    }
    
    // Then, perform whatever action is requested
    for (i = 0; i < count; i++) {
        unsigned code = [[keycodes objectForKey:[keys objectAtIndex:i]] intValue];

        if (MODE_REGULAR != mode) {
            NSString *description = [self actionDescriptionString:[keys objectAtIndex:i]];
            printf("%s\n", [description UTF8String]);
        }

        if (MODE_TEST != mode) {
            nanosleep(&waitingtime, NULL);
            [self performActionWithKeycode:(CGKeyCode)code];
        }
    }
}

@end
