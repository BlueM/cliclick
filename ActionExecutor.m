/**
 * Copyright (c) 2007-2021, Carsten Blüm <carsten@bluem.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * - Neither the name of Carsten Blüm nor the names of his contributors may be
 *   used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "ActionExecutor.h"
#include "ActionClassesMacro.h"
#include "ExecutionOptions.h"

@implementation ActionExecutor

+ (void)executeActions:(NSArray *)actions
           withOptions:(struct ExecutionOptions)options {

  NSDictionary *shortcuts = [self shortcuts];

  struct timespec waitingtime;
  waitingtime.tv_sec = 0;

  if (options.waitTime < 100) {
    options.waitTime = 100;
  }

  if (options.waitTime > 999) {
    waitingtime.tv_sec = (int)floor(options.waitTime / 1000);
    waitingtime.tv_nsec =
        (options.waitTime - waitingtime.tv_sec * 1000) * 1000000;
  } else {
    waitingtime.tv_sec = 0;
    waitingtime.tv_nsec = options.waitTime * 1000000;
  }

  NSUInteger i, count = [actions count];
  for (i = 0; i < count; i++) {
    NSArray *action =
        [[actions objectAtIndex:i] componentsSeparatedByString:@":"];
    Class actionClass = [shortcuts objectForKey:[action objectAtIndex:0]];
    if (nil == actionClass) {
      if ([[action objectAtIndex:0]
              isEqualToString:[actions objectAtIndex:i]]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Unrecognized action shortcut “%@”",
                           [action objectAtIndex:0]];
      } else {
        [NSException raise:@"InvalidCommandException"
                    format:@"Unrecognized action shortcut “%@” in “%@”",
                           [action objectAtIndex:0], [actions objectAtIndex:i]];
      }
    }

    id actionClassInstance = [[actionClass alloc] init];

    if (![actionClassInstance conformsToProtocol:@protocol(ActionProtocol)]) {
      [NSException raise:@"InvalidCommandException"
                  format:@"%@ does not conform to ActionProtocol", actionClass];
    }

    options.isFirstAction = i == 0;
    options.isLastAction = i == count - 1;

    if ([action count] > 1) {
      [actionClassInstance
          performActionWithData:[[action
                                    subarrayWithRange:NSMakeRange(
                                                          1,
                                                          [action count] - 1)]
                                    componentsJoinedByString:@":"]
                    withOptions:options];
    } else {
      [actionClassInstance performActionWithData:@"" withOptions:options];
    }

    [actionClassInstance release];

    if (options.isLastAction) {
      waitingtime.tv_sec = 0;
      waitingtime.tv_nsec = 1000000; // Arbitraray dummy value
      nanosleep(&waitingtime, NULL);
    } else {
      nanosleep(&waitingtime, NULL);
    }
  }
}

+ (NSArray *)actionClasses {
  NSArray *actionClasses = [NSArray arrayWithObjects:ACTION_CLASSES];
  return actionClasses;
}

+ (NSDictionary *)shortcuts {

  NSArray *actionClasses = [[self class] actionClasses];
  NSMutableDictionary *shortcuts =
      [NSMutableDictionary dictionaryWithCapacity:[actionClasses count]];
  NSUInteger i, ii;

  for (i = 0, ii = [actionClasses count]; i < ii; i++) {
    NSString *classname = [actionClasses objectAtIndex:i];
    Class actionClass = NSClassFromString(classname);
    NSString *shortcut = [actionClass commandShortcut];
    if (nil != [shortcuts objectForKey:shortcut]) {
      [NSException raise:@"ShortcutConflictException"
                  format:@"Shortcut “%@” is used by more than one action class",
                         shortcut];
    }
    [shortcuts setObject:actionClass forKey:shortcut];
  }

  return [[shortcuts retain] autorelease];
}

@end
