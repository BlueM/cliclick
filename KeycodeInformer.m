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

#import "KeycodeInformer.h"

@implementation KeycodeInformer

static KeycodeInformer *sharedInstance = nil;

+ (id)sharedInstance
{
    @synchronized(self) {
        if(sharedInstance == nil)
            sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        map = [[NSMutableDictionary alloc] initWithCapacity:256];
        
        NSArray *keyCodes = @[ @0,  @1,  @2,  @3,  @4,  @5,  @6,  @7,  @8,  @9, @10, @11, @12, @13, @14, @15,
                               @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29, @30, @31,
                               @32, @33, @34, @35, @37, @38, @39, @40, @41, @42, @43, @44, @45, @46, @47, @49];
        
        for (NSNumber *keyCode in keyCodes) {
            NSString *string1 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:0];
            [map setObject:@[keyCode, @0] forKey:[string1 decomposedStringWithCanonicalMapping]];
            
            NSString *string2 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_SHIFT];
            [map setObject:@[keyCode, NSNUMBER_MODIFIER_SHIFT] forKey:[string2 decomposedStringWithCanonicalMapping]];
            
            NSString *string3 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_ALT];
            [map setObject:@[keyCode, NSNUMBER_MODIFIER_ALT] forKey:[string3 decomposedStringWithCanonicalMapping]];
            
            NSString *string4 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_SHIFT_ALT];
            [map setObject:@[keyCode, NSNUMBER_MODIFIER_SHIFT_ALT] forKey:[string4 decomposedStringWithCanonicalMapping]];
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (oneway void)release
{
    
}

- (id)autorelease {
    return self;
}

- (void)dealloc
{
    [map release];
    [super dealloc];
}

- (NSArray *)keyCodesForString:(NSString *)string
{
    NSMutableArray *keyCodes = [[NSMutableArray alloc] initWithCapacity:[string length]];
    string                   = [[self prepareString:string] decomposedStringWithCanonicalMapping];

    for (unsigned i = 0, ii = [string length]; i < ii; i++) {

        NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:i];

        if (range.length > 1) {
            i += range.length - 1;
        }

        // [ki keyCodesForString:[data substringWithRange:range]];
        id keyCodeInfo = [map objectForKey:[string substringWithRange:range]];
        if (keyCodeInfo) {
            [keyCodes addObject:keyCodeInfo];
        } else {
            // @todo-api Save unresolvable strings and make them retrievable via a method
            NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
            NSString *msg = [NSString stringWithFormat:@"Unable to get key code for: %@\n", [string substringWithRange:range]];
            [fh writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        }

    }

    return [keyCodes autorelease];
}

- (NSString *)prepareString:(NSString *)string
{
    // Incomplete list of characters which (dependent on the keyboard layout) cannot
    // be typed by a combination of keys, but may require consecutive key presses or
    // key combinations. Many characters are missing, as I did not yet find a way to
    // auto-generate the map.
    NSDictionary *replacementMap = @{
        @"Ä": @"¨A",
        @"Ö": @"¨O",
        @"Ü": @"¨U",
        @"ä": @"¨a",
        @"ö": @"¨o",
        @"ü": @"¨u",
        @"ü": @"¨u",
        @"ë": @"¨e",
        @"Á": @"´A",
        @"É": @"´E",
        @"á": @"´a",
        @"é": @"´e",
        @"À": @"`A",
        @"È": @"`E",
        @"à": @"`a",
        @"è": @"`e",
        @"Ã": @"~A",
        @"ã": @"~a",
        @"Ñ": @"~N",
        @"ñ": @"~n",
        @"Â": @"^A",
        @"Ê": @"^E",
        @"Î": @"^I",
        @"Ô": @"^O",
        @"Û": @"^U",
        @"â": @"^a",
        @"ê": @"^e",
        @"î": @"^i",
        @"ô": @"^o",
        @"û": @"^u"
    };

    NSMutableString *tmp     = [NSMutableString stringWithString:string];
    NSEnumerator *enumerator = [replacementMap keyEnumerator];
    NSString *key;

    while ((key = [enumerator nextObject])) {
        // @todo-internal Could somehow get rid of executing [tmp length] each time?
        [tmp replaceOccurrencesOfString:key withString:[replacementMap objectForKey:key] options:NSLiteralSearch range:NSMakeRange(0, [tmp length])];
    }

    return tmp;
}

- (NSString *)stringForKeyCode:(CGKeyCode)keyCode andModifiers:(UInt32)modifiers
{
    TISInputSourceRef keyboard             = TISCopyCurrentKeyboardInputSource();
    CFDataRef keyLayoutData                = TISGetInputSourceProperty(keyboard, kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(keyLayoutData);

    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;

    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   modifiers,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(keyboard);
    
    return [NSString stringWithCharacters:chars length:1];
}

@end
