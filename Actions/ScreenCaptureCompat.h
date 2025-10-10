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

#ifndef ScreenCaptureCompat_h
#define ScreenCaptureCompat_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Screen Capture Compatibility Layer
 * 
 * This module provides a unified interface for screen capture functionality
 * that works across different macOS versions:
 * 
 * - macOS 10.15 - 12.2: Uses CGWindowListCreateImage (deprecated in 15.0)
 * - macOS 12.3+: Uses ScreenCaptureKit framework
 * - macOS 15.0+: ScreenCaptureKit only (CGWindowListCreateImage unavailable)
 * 
 * The implementation automatically detects the runtime OS version and uses
 * the most appropriate API available.
 */

/**
 * Error codes for screen capture operations
 */
typedef NS_ENUM(NSInteger, SCCompatError) {
    SCCompatErrorNone = 0,
    SCCompatErrorUnsupportedOS = -1000,
    SCCompatErrorNoPermission = -1001,
    SCCompatErrorCaptureFailure = -1002,
    SCCompatErrorInvalidRect = -1003,
    SCCompatErrorUnknown = -1999
};

/**
 * Result structure for screen capture operations
 * Caller is responsible for releasing the CGImageRef if non-NULL
 */
typedef struct {
    CGImageRef imageRef;        // NULL on failure, caller must CFRelease when done
    SCCompatError errorCode;    // Error code if imageRef is NULL
    NSString *errorMessage;     // Human-readable error description (autoreleased)
} SCCompatCaptureResult;

/**
 * Captures a single pixel from the screen at the specified coordinates
 * 
 * This function provides a unified interface that works on all supported
 * macOS versions. It automatically selects the best available capture method
 * based on the runtime OS version and API availability.
 *
 * @param rect The screen rectangle to capture (typically 1x1 pixel for color picking)
 * @return SCCompatCaptureResult structure with either a valid CGImageRef or error info
 * 
 * @note The caller MUST call CFRelease() on the returned imageRef if it's non-NULL
 * @note This function is thread-safe but may block briefly during capture
 * @note On first call, may prompt user for screen recording permissions on macOS 10.15+
 */
SCCompatCaptureResult SCCompatCaptureScreenRect(CGRect rect);

/**
 * Convenience function to get the color at a specific screen point
 * 
 * @param point The screen coordinate to sample
 * @return NSColor object representing the pixel color, or nil on failure
 * 
 * @note This function handles the CGImageRef lifecycle internally
 * @note The returned NSColor is autoreleased
 */
NSColor* SCCompatGetColorAtPoint(CGPoint point);

/**
 * Check if screen capture is available and permitted
 * 
 * @return YES if screen capture should work, NO if not available or no permission
 * 
 * @note This performs a lightweight check without actually capturing
 * @note On macOS 10.15+, this checks for Screen Recording permission
 */
BOOL SCCompatIsScreenCaptureAvailable(void);

/**
 * Get a human-readable description of the current screen capture method
 * 
 * @return NSString describing which API is being used (for debugging/logging)
 * 
 * @note The returned string is autoreleased
 * @note Useful for troubleshooting compatibility issues
 */
NSString* SCCompatGetCaptureModeDescription(void);

#ifdef __cplusplus
}
#endif

#endif /* ScreenCaptureCompat_h */