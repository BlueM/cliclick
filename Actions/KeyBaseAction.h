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

#import <Cocoa/Cocoa.h>
#import "ActionProtocol.h"
#import "ExecutionOptions.h"

@interface KeyBaseAction : NSObject {

}

/**
 * Returns the keys that are supported by the command.
 *
 * @return An NSDictionary which has keyboard key name as dictionary keys and keyboard key codes (strings) as dictionary values.
 */
+ (NSDictionary *)getSupportedKeycodes;

/**
 * Returns the list of keys supported by the command
 *
 * @param indent String to use as indentation string at the beginning of each line
 *
 * @return Newline-separated string
 */
+ (NSString *)getSupportedKeysIndentedWith:(NSString *)indent;

/**
 * Returns a string describing the action performed be the command
 *
 * @param keyName Name of the key
 * @return Human-readable phrase such as @@"Press blahblah key"
 * @note This method must be overwritten by subclasses
 */
- (NSString *)actionDescriptionString:(NSString *)keyName;

/**
 * Performs the command's action
 *
 * @param code The key code
 *
 * @note This method must be overwritten by subclasses
 */
- (void)performActionWithKeycode:(CGKeyCode)code;

#pragma mark - ActionProtocol

/**
 * Performs the action
 *
 * Depending on the `mode` argument, this can be the action, printing a description of the action to STDOUT or both.
 *
 * @param data Part of the argument remaining after stripping the leading command identifier
 * @param options
 */
- (void)performActionWithData:(NSString *)data
                  withOptions:(struct ExecutionOptions)options;

@end
