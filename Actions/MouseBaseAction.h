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

typedef enum {
    XAXIS = 1,
    YAXIS = 2
} CLICLICKAXIS;

@interface MouseBaseAction : NSObject {

}

/**
 * Takes an unparsed position string for a single axis and returns the corresponding position
 *
 * @param unparsedValue String in one of the supported formats, such as @@"934", @@"+17" or @@"=218"
 * @param axis The axis
 */
+ (int)getCoordinate:(NSString *)unparsedValue
             forAxis:(CLICLICKAXIS)axis;

/**
 * Checks if the given string is an acceptable X or Y coordinate value and throws an exception if not
 *
 * @param string String to test. See +getCoordinate:forAxis: for supported syntaxes
 * @param axis The axis
 */
+ (void)validateAxisValue:(NSString *)string
                  forAxis:(CLICLICKAXIS)axis;

/**
 * Returns a human-readable description of the action
 *
 * This should be a one-line string which will be used in “verbose” and in “test” mode.
 *
 * @param locationDescription A textual representation of the coordinates at which the action is performed.
 */
- (NSString *)actionDescriptionString:(NSString *)locationDescription;

/**
 * Performs the mouse-related action an inheriting command provides
 *
 * This method is called as last step of method performActionWithData:withOptions: It should only perform the action, not print a description when in MODE_VERBOSE mode, as this is done by performActionWithData:withOptions:
 *
 * @note This method will only be invoked when in MODE_REGULAR or MODE_VERBOSE mode.
 */
- (void)performActionAtPoint:(CGPoint)p;

/**
 * Performs the action
 *
 * Depending on the mode argument, this can be the action, printing a description of the action to STDOUT or both. This implementation performs the preparatory steps such as validating arguments, calculating the mouse position etc., but leaves performing the action to subclasses, whose performActionAtPoint: method it eventually invokes.
 *
 * @param data Part of the argument remaining after stripping the leading command identifier
 * @param options
 */
- (void)performActionWithData:(NSString *)data
                  withOptions:(struct ExecutionOptions)options;

- (void)postHumanizedMouseEventsWithEasingFactor:(unsigned)easing
                                             toX:(float)endX
                                             toY:(float)endY;

- (uint32_t)getMoveEventConstant;

- (float)distanceBetweenPoint:(NSPoint)a andPoint:(NSPoint)b;

- (float)cubicEaseInOut:(float)p;

@end
