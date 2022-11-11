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

#import "ScheduleAction.h"

@implementation ScheduleAction

#pragma mark - ActionProtocol

+ (NSString *)commandShortcut {
    return @"s";
}

+ (NSString *)commandDescription {
    return @"  s:UTC(s)    Will WAIT/PAUSE until reach the giving UTC(s) time.\n"
    "          Example: “s:1668172060” will pause command execution until 2022-11-11 21:07:40";
}

- (void)performActionWithData:(NSString *)data
                  withOptions:(struct ExecutionOptions)options {

    NSTimeInterval targetUTC = [data doubleValue];
    NSString *shortcut = [[self class] commandShortcut];

    if ([data isEqualToString:@""] ||
        !targetUTC) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Invalid or missing argument to command “%@”: Expected number of milliseconds. Example: “%@:50”", shortcut, shortcut];
    }

    if (MODE_REGULAR != options.mode) {
        [options.verbosityOutputHandler write:[NSString stringWithFormat:@"schedule UTC :%.3f", targetUTC]];
    }

    if (MODE_TEST == options.mode) {
        return;
    }
    
    NSDate *target = [NSDate dateWithTimeIntervalSince1970:targetUTC];
    NSTimeInterval waitTime = [target timeIntervalSinceNow];
    if (waitTime < 0.1) {
        waitTime = 0.1;
    }
    unsigned milliseconds = waitTime * 1000;
    
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
