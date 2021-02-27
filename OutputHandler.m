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

#import "OutputHandler.h"

@implementation OutputHandler

- (id)initWithTarget:(NSString *)target {
    self = [super init];

    if (self) {
        if (!target) {
            outputTarget = @"stdout";
        } else if ([target isEqualToString:@"stdout"] ||
                   [target isEqualToString:@"stderr"]) {
            outputTarget = target;
        } else if ([target isEqualToString:@"clipboard"]) {
            outputTarget = target;
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
            [pasteboard setString:@""
                          forType:NSStringPboardType];
        } else {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:target]) {
                if (![fm isWritableFileAtPath:target]) {
                    [NSException raise:@"InvalidDestinationException"
                                format:@"Cannot write to the file “%@” specified as output destination.", target];
                }
            } else {
                if (![fm createFileAtPath:target contents:nil attributes:nil]) {
                    [NSException raise:@"InvalidDestinationException"
                                format:@"Cannot create file “%@” specified as output destination.", target];
                }
            }
            outputTarget = target;
        }
    }
    return self;
}

- (void)write:(NSString *)message {
    if ([outputTarget isEqualToString:@"stdout"]) {
        printf("%s\n", [message UTF8String]);
        return;
    }

    if ([outputTarget isEqualToString:@"stderr"]) {
        fprintf(stderr, "%s\n", [message UTF8String]);
        return;
    }

    if ([outputTarget isEqualToString:@"clipboard"]) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard setString:[NSString stringWithFormat:@"%@%@\n", [pasteboard stringForType:NSStringPboardType], message]
                      forType:NSStringPboardType];
        return;
    }

    // Still here? must be file target
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:outputTarget];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

@end
