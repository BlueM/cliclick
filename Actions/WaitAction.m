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

#import "WaitAction.h"

@implementation WaitAction

#pragma mark - ActionProtocol

+(NSString *)commandShortcut {
    return @"w";
}

+(NSString *)commandDescription {
    return @"  w:ms    Will WAIT/PAUSE for the given number of milliseconds.\n"
    "          Example: “w:500” will pause command execution for half a second";
}

-(void)performActionWithData:(NSString *)data
                      inMode:(unsigned)mode {

    unsigned milliseconds = abs([data intValue]);
    NSString *shortcut = [[self class] commandShortcut];
    
    if ([data isEqualToString:@""] ||
        !milliseconds) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Invalid or missing argument to command “%@”: Expected number of milliseconds. Example: “%@:50”", shortcut, shortcut];
    }
    
    if (MODE_REGULAR != mode) {
        printf("Wait %i milliseconds\n", milliseconds);
    }
    
    if (MODE_TEST == mode) {
        return;
    }
    
    struct timespec waitingtime;
    if (milliseconds > 999) {
        waitingtime.tv_sec = (int)floor(milliseconds / 1000);
        waitingtime.tv_nsec = (milliseconds - waitingtime.tv_sec * 1000) * 1000000;
    } else {
        waitingtime.tv_sec = 0;
        waitingtime.tv_nsec = milliseconds * 1000000;
    }
    
    nanosleep(&waitingtime, NULL);    
}

@end
