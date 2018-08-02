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

#import "KeycodeInformer.h"

@implementation KeycodeInformer

static KeycodeInformer *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[super allocWithZone:NULL] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (KeycodeInformer *)init {
    self = [super init];
    if (self) {
        keyboard = TISCopyCurrentKeyboardInputSource();
        keyLayoutData = TISGetInputSourceProperty(keyboard, kTISPropertyUnicodeKeyLayoutData);

        if (NULL == keyLayoutData) {
            keyboard = TISCopyCurrentASCIICapableKeyboardInputSource();
            keyLayoutData = TISGetInputSourceProperty(keyboard, kTISPropertyUnicodeKeyLayoutData);
            if (NULL == keyLayoutData) {
                [NSException raise:@"KeyboardLayoutException"
                            format:@"Sorry, cliclick cannot handle your keyboard layout, so emulating typing is not possible."];
            }
        }

        keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(keyLayoutData);

        map = [[NSMutableDictionary alloc] initWithCapacity:256];

        NSArray *keyCodes = [NSArray arrayWithObjects: @0,   @1,  @2, @3,   @4,  @5,  @6,  @7,  @8,  @9,
                                                       @10, @11, @12, @13, @14, @15, @16, @17, @18, @19,
                                                       @20, @21, @22, @23, @24, @25, @26, @27, @28, @29,
                                                       @30, @31, @32, @33, @34, @35,      @37, @38, @39,
                                                       @40, @41, @42, @43, @44, @45, @46, @47,      @49,
                                                       @50, nil];

        for (NSNumber *keyCode in keyCodes) {
            NSString *string1 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:0];
            [map setObject:[NSArray arrayWithObjects:keyCode, [NSNumber numberWithInt:0], nil]
                    forKey:[string1 decomposedStringWithCanonicalMapping]];

            NSString *string2 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_SHIFT];
            [map setObject:[NSArray arrayWithObjects:keyCode, NSNUMBER_MODIFIER_SHIFT, nil]
                    forKey:[string2 decomposedStringWithCanonicalMapping]];

            NSString *string3 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_ALT];
            [map setObject:[NSArray arrayWithObjects:keyCode, NSNUMBER_MODIFIER_ALT, nil]
                    forKey:[string3 decomposedStringWithCanonicalMapping]];

            NSString *string4 = [self stringForKeyCode:(CGKeyCode)[keyCode intValue] andModifiers:MODIFIER_SHIFT_ALT];
            [map setObject:[NSArray arrayWithObjects:keyCode, NSNUMBER_MODIFIER_SHIFT_ALT, nil]
                    forKey:[string4 decomposedStringWithCanonicalMapping]];
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

- (oneway void)release {
    CFRelease(keyLayoutData);
    CFRelease(keyboard);
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
    [map release];
    [super dealloc];
}

- (NSArray *)keyCodesForString:(NSString *)string {
    NSMutableArray *keyCodes = [[NSMutableArray alloc] initWithCapacity:[string length]];
    string = [[self prepareString:string] decomposedStringWithCanonicalMapping];
    NSUInteger i, ii;

    for (i = 0, ii = [string length]; i < ii; i++) {

        NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:i];

        if (range.length > 1) {
            i += range.length - 1;
        }

        id keyCodeInfo = [map objectForKey:[string substringWithRange:range]];
        if (keyCodeInfo) {
            [keyCodes addObject:keyCodeInfo];
        } else {
            NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
            NSString *url = [NSString stringWithFormat:CHARINFO_URL_TEMPLATE, VERSION];
            NSString *msg = [NSString stringWithFormat:@"Unable to get key code for %@ (see %@)\n", [string substringWithRange:range], url];
            [fh writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    return [keyCodes autorelease];
}

- (NSString *)prepareString:(NSString *)string {
    NSString *layoutName = TISGetInputSourceProperty(keyboard, kTISPropertyLocalizedName);
    NSDictionary *replacementMap = [self getReplacementMapForKeyboardLayoutNamed:layoutName];
    NSMutableString *tmp = [NSMutableString stringWithString:string];
    NSEnumerator *enumerator = [replacementMap keyEnumerator];
    NSString *key;

    DLog(@"Current keyboard layout: %@", layoutName);

    if (nil != replacementMap) {
        while ((key = [enumerator nextObject])) {
            [tmp replaceOccurrencesOfString:key withString:[replacementMap objectForKey:key] options:NSLiteralSearch range:NSMakeRange(0, [tmp length])];
        }
    }

    return tmp;
}

- (NSString *)stringForKeyCode:(CGKeyCode)keyCode andModifiers:(UInt32)modifiers {
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

    return [NSString stringWithCharacters:chars length:1];
}

- (NSDictionary *)getReplacementMapForKeyboardLayoutNamed:(NSString *)layoutName {
    // Incomplete lists of characters which (dependent on the keyboard layout) cannot
    // be typed by a combination of keys, but require consecutive key presses. Many
    // characters are missing, as I did not yet find a way to auto-generate the map.

    if ([@"German" isEqualToString:layoutName]) {
        #pragma mark - German replacement map
        // #SUPPORTED German: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÕÑãõñ
        // #KNOWN_UNSUPPORTED German: ŃńǸǹŇňŘřŠšŮů
        return @{
            // Umlauts
            @"Ë": @"¨E",
            @"Ÿ": @"¨Y",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ÿ": @"¨y",

            // Acute
            @"Á": @"´A",
            @"É": @"´E",
            @"Í": @"´I",
            @"Ó": @"´O",
            @"Ú": @"´U",
            @"á": @"´a",
            @"é": @"´e",
            @"í": @"´i",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"À": @"`A",
            @"È": @"`E",
            @"Ì": @"`I",
            @"Ò": @"`O",
            @"Ù": @"`U",
            @"à": @"`a",
            @"è": @"`e",
            @"ì": @"`i",
            @"ò": @"`o",
            @"ù": @"`u",

            // Circumflex
            @"Â": @"^A",
            @"Ê": @"^E",
            @"Î": @"^I",
            @"Ô": @"^O",
            @"Û": @"^U",
            @"â": @"^a",
            @"ê": @"^e",
            @"î": @"^i",
            @"ô": @"^o",
            @"û": @"^u",

            // Tilde
            @"Ã": @"~A",
            @"Ñ": @"~N",
            @"Õ": @"~O",
            @"ã": @"~a",
            @"ñ": @"~n",
            @"õ": @"~o"
        };
    }

    if ([@"U.S. Extended" isEqualToString:layoutName]) {
        #pragma mark - U.S. Extended replacement map
        // #SUPPORTED U.S. Extended: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÕÑãõñŃńǸǹŇňŘřŠšÅåŮů
        // #KNOWN_UNSUPPORTED U.S. Extended:
        // See http://symbolcodes.tlt.psu.edu/accents/codemacext.html
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ï": @"¨I",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"Ÿ": @"¨Y",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"Á": @"´A",
            @"É": @"´E",
            @"Í": @"´I",
            @"Ń": @"´N",
            @"Ó": @"´O",
            @"Ú": @"´U",
            @"á": @"´a",
            @"é": @"´e",
            @"í": @"´i",
            @"ń": @"´n",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"À": @"`A",
            @"È": @"`E",
            @"Ì": @"`I",
            @"Ǹ": @"`N",
            @"Ò": @"`O",
            @"Ù": @"`U",
            @"à": @"`a",
            @"è": @"`e",
            @"ì": @"`i",
            @"ò": @"`o",
            @"ù": @"`u",
            @"ǹ": @"`n",

            // Circumflex
            @"Â": @"ˆA",
            @"Ê": @"ˆE",
            @"Î": @"ˆI",
            @"Ô": @"ˆO",
            @"Û": @"ˆU",
            @"â": @"ˆa",
            @"ê": @"ˆe",
            @"î": @"ˆi",
            @"ô": @"ˆo",
            @"û": @"ˆu",

            // Tilde
            @"Ã": @"˜A",
            @"Ñ": @"˜N",
            @"Õ": @"˜O",
            @"ã": @"˜a",
            @"ñ": @"˜n",
            @"õ": @"˜o",

            // Caron
            @"Ň": @"ˇN",
            @"Ř": @"ˇR",
            @"Š": @"ˇS",
            @"ň": @"ˇn",
            @"ř": @"ˇr",
            @"š": @"ˇs",

            // A ring
            @"Å": @"˚A",
            @"å": @"˚a",
            @"Ů": @"˚U",
            @"ů": @"˚u"
        };
    }

    if ([@"Polish" isEqualToString:layoutName]) {
        #pragma mark - Polish replacement map
        // #SUPPORTED Polish: ÄÖÜäöüÁÉÍÓÚáéíóúŃńŇňŘřŠš
        // #KNOWN_UNSUPPORTED Polish: ËÏŸëïÿÀÈÌÒÙàèìòùǸǹÂÊÎÔÛâêîôûÃÕÑãõñŒœÅåØøÆæ
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"ä": @"¨a",
            @"ö": @"¨o",
            @"ü": @"¨u",

            // Acute
            @"Á": @"´A",
            @"É": @"´E",
            @"Í": @"´I",
            @"Ú": @"´U",
            @"á": @"´a",
            @"é": @"´e",
            @"í": @"´i",
            @"ú": @"´u",

            // Caron
            @"Ň": @"ˇN",
            @"Ř": @"ˇR",
            @"Š": @"ˇS",
            @"ň": @"ˇn",
            @"ř": @"ˇr",
            @"š": @"ˇs"
        };
    }

    if ([@"French" isEqualToString:layoutName]) {
        #pragma mark - French replacement map
        // #SUPPORTED French: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôû
        // #KNOWN_UNSUPPORTED French: ÃÑÕãñõŃńǸǹŇňŘřŠšŮů
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"É": @"´E",
            @"á": @"´a",
            @"í": @"´i",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"À": @"`A",
            @"ì": @"`i",
            @"ò": @"`o",

            // Circumflex
            @"â": @"^A",
            @"û": @"^U",
            @"Ǹ": @"`N",
            @"ǹ": @"`n"
         };
    }

    if ([@"Canadian French - CSA" isEqualToString:layoutName]) {
        #pragma mark - Canadian French replacement map
        // #SUPPORTED Canadian French - CSA: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÑÕãñõ
        // #KNOWN_UNSUPPORTED Canadian French - CSA: ŇŘŠňřšǸǹŃńÅåŮů
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ï": @"¨I",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"Ÿ": @"¨Y",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"Á": @"´A",
            @"É": @"´E",
            @"Í": @"´I",
            @"Ó": @"´O",
            @"Ú": @"´U",
            @"á": @"´a",
            @"í": @"´i",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"Ì": @"`I",
            @"Ò": @"`O",
            @"ì": @"`i",
            @"ò": @"`o",

            // Circumflex
            @"Â": @"^A",
            @"Ê": @"^E",
            @"Î": @"^I",
            @"Ô": @"^O",
            @"Û": @"^U",
            @"â": @"^a",
            @"ê": @"^e",
            @"î": @"^i",
            @"ô": @"^o",
            @"û": @"^u",

            // Tilde
            @"Ã": @"~A",
            @"Ñ": @"~N",
            @"Õ": @"~O",
            @"ã": @"~a",
            @"ñ": @"~n",
            @"õ": @"~o"
        };
    }

    if ([@"Spanish" isEqualToString:layoutName]) {
        #pragma mark - Spanish replacement map
        // #SUPPORTED Spanish: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñ
        // #KNOWN_UNSUPPORTED Spanish: ÃÕãõŇŘŠňřšǸǹŃńŮů
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"É": @"´E",
            @"í": @"´i",
            @"á": @"´a",
            @"é": @"´e",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"À": @"`A",
            @"à": @"`a",
            @"è": @"`e",
            @"ì": @"`i",
            @"ò": @"`o",
            @"ù": @"`u",

            // Circumflex
            @"â": @"^a",
            @"ê": @"^e",
            @"î": @"^i",
            @"ô": @"^o",
            @"û": @"^u"
         };
    }

    if ([@"Portuguese" isEqualToString:layoutName]) {
        #pragma mark - Portuguese replacement map
        // #SUPPORTED Portuguese: ÄËÏÖÜäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñÃÕãõ
        // #KNOWN_UNSUPPORTED Portuguese: ŸŇŘŠňřšǸǹŃńŮů
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ï": @"¨I",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"Á": @"´A",
            @"É": @"´E",
            @"Í": @"´I",
            @"Ó": @"´O",
            @"Ú": @"´U",
            @"á": @"´a",
            @"é": @"´e",
            @"í": @"´i",
            @"ó": @"´o",
            @"ú": @"´u",

            // Agrave
            @"À": @"`A",
            @"È": @"`E",
            @"Ì": @"`I",
            @"Ò": @"`O",
            @"Ù": @"`U",
            @"à": @"`a",
            @"è": @"`e",
            @"ì": @"`i",
            @"ò": @"`o",
            @"ù": @"`u",

            // Circumflex
            @"Â": @"^A",
            @"Ê": @"^E",
            @"Î": @"^I",
            @"Ô": @"^O",
            @"Û": @"^U",
            @"â": @"^a",
            @"ê": @"^e",
            @"î": @"^i",
            @"ô": @"^o",
            @"û": @"^u",

            // Tilde
            @"Ã": @"˜A",
            @"Õ": @"˜O",
            @"Ñ": @"˜N",
            @"ã": @"˜a",
            @"õ": @"˜o",
            @"ñ": @"˜n"
         };
    }

    if ([@"Italian" isEqualToString:layoutName]) {
        #pragma mark - Italian replacement map
        // #SUPPORTED Italian: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñÃÕãõ
        // #KNOWN_UNSUPPORTED Italian: ŸŇŘŠňřšǸǹŃńŮů
        return @{
            // Umlauts
            @"Ä": @"¨A",
            @"Ë": @"¨E",
            @"Ï": @"¨I",
            @"Ö": @"¨O",
            @"Ü": @"¨U",
            @"Ÿ": @"¨Y",
            @"ä": @"¨a",
            @"ë": @"¨e",
            @"ï": @"¨i",
            @"ö": @"¨o",
            @"ü": @"¨u",
            @"ÿ": @"¨y",

            // Acute
            @"á": @"´a",
            @"í": @"´i",
            @"ó": @"´o",
            @"ú": @"´u",

            // Circumflex
            @"Â": @"ˆA",
            @"Ê": @"ˆE",
            @"Î": @"ˆI",
            @"Ô": @"ˆO",
            @"Û": @"ˆU",
            @"â": @"ˆa",
            @"ê": @"ˆe",
            @"î": @"ˆi",
            @"ô": @"ˆo",
            @"û": @"ˆu",

            // Tilde
            @"Ã": @"˜A",
            @"Ñ": @"˜N",
            @"Õ": @"˜O",
            @"ã": @"˜a",
            @"ñ": @"˜n",
            @"õ": @"˜o"
         };
    }

    if ([@"Canadian English" isEqualToString:layoutName]) {
        #pragma mark - Canadian English replacement map

        // Note: When physically typing on a keyboard with this layout, typing with combining
        // characters (e.g. ¨ plus u) works. But for some reason, when typing programmatically,
        // they require a pretty long delay between keystrokes (50+ ms). And, more important,
        // in a sequence of those characters (e.g. "Äñé"), only the first one is correct,
        // while the others will result in the two characters (the right side of the map),
        // not in the character that should be typed (the left side of the map).
        //
        // Any hints why this is the case and how that could be fixed are welcome.

        return nil;
    }

    if ([@"Brazilian" isEqualToString:layoutName]) {
        #pragma mark - Brazilian replacement map

        // Note: When physically typing on a keyboard with this layout, typing with combining
        // characters (e.g. ¨ plus u) works. But for some reason, when typing programmatically,
        // they require a pretty long delay between keystrokes (50+ ms). And, more important,
        // in a sequence of those characters (e.g. "Äñé"), only the first one is correct,
        // while the others will result in the two characters (the right side of the map),
        // not in the character that should be typed (the left side of the map).
        //
        // Any hints why this is the case and how that could be fixed are welcome.

        return nil;
    }

    return nil;
}

@end
