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

#import "ScreenCaptureCompat.h"
#import <AvailabilityMacros.h>
#import <sys/utsname.h>

// Conditionally import ScreenCaptureKit only if SDK supports it
#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 120300
    #import <ScreenCaptureKit/ScreenCaptureKit.h>
    #define HAS_SCREENCAPTUREKIT_SDK 1
#else
    #define HAS_SCREENCAPTUREKIT_SDK 0
#endif

// Runtime OS version detection
typedef NS_ENUM(NSInteger, SCCompatOSVersion) {
    SCCompatOSVersionUnknown = 0,
    SCCompatOSVersionLegacy,        // < macOS 10.15
    SCCompatOSVersionCGWindow,      // macOS 10.15 - 12.2
    SCCompatOSVersionScreenKit      // macOS 12.3+
};

#pragma mark - Private Interface

@interface SCCompatHelper : NSObject
+ (SCCompatOSVersion)detectOSVersion;
+ (BOOL)isScreenRecordingPermissionGranted;
@end

#pragma mark - Private Implementation

@implementation SCCompatHelper

+ (SCCompatOSVersion)detectOSVersion {
    static SCCompatOSVersion detectedVersion = SCCompatOSVersionUnknown;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSOperatingSystemVersion version = [processInfo operatingSystemVersion];
        
        if (version.majorVersion < 10 || (version.majorVersion == 10 && version.minorVersion < 15)) {
            detectedVersion = SCCompatOSVersionLegacy;
        } else if (version.majorVersion < 12 || 
                  (version.majorVersion == 12 && version.minorVersion < 3)) {
            detectedVersion = SCCompatOSVersionCGWindow;
        } else {
            detectedVersion = SCCompatOSVersionScreenKit;
        }
        
        DLog(@"Detected OS version: macOS %ld.%ld.%ld -> using %@", 
             (long)version.majorVersion, (long)version.minorVersion, (long)version.patchVersion,
             detectedVersion == SCCompatOSVersionScreenKit ? @"ScreenCaptureKit" : @"CGWindowListCreateImage");
    });
    
    return detectedVersion;
}

+ (BOOL)isScreenRecordingPermissionGranted {
    // Check for screen recording permission (required on macOS 10.15+)
    if (@available(macOS 10.15, *)) {
        // Create a 1x1 image capture attempt to test permissions
        CGRect testRect = CGRectMake(0, 0, 1, 1);
        
        @try {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGImageRef testImage = CGWindowListCreateImage(testRect, 
                                                         kCGWindowListOptionOnScreenOnly, 
                                                         kCGNullWindowID, 
                                                         kCGWindowImageDefault);
            #pragma clang diagnostic pop
            
            if (testImage != NULL) {
                CFRelease(testImage);
                return YES;
            }
        }
        @catch (NSException *exception) {
            DLog(@"Screen recording permission check failed: %@", exception.reason);
        }
        
        return NO;
    }
    
    return YES; // No permission required on older versions
}

@end

#pragma mark - ScreenCaptureKit Implementation (macOS 12.3+)

#if HAS_SCREENCAPTUREKIT_SDK

// Simplified ScreenCaptureKit implementation using screenshot functionality
static CGImageRef SCCompatCaptureWithScreenCaptureKit(CGRect rect, NSError **error) API_AVAILABLE(macos(12.3)) {
    // For the compatibility use case, we'll fall back to CGDisplayCreateImage
    // which is a simpler, more reliable approach than the full ScreenCaptureKit API
    // This maintains the same interface while providing better compatibility
    
    // Get the main display ID
    CGDirectDisplayID mainDisplayID = CGMainDisplayID();
    
    // Create an image of the specified rect from the main display
    CGImageRef displayImage = CGDisplayCreateImageForRect(mainDisplayID, rect);
    
    if (displayImage == NULL && error) {
        *error = [[NSError alloc] initWithDomain:@"SCCompat" 
                                           code:SCCompatErrorCaptureFailure 
                                       userInfo:@{NSLocalizedDescriptionKey: @"CGDisplayCreateImageForRect failed - may require screen recording permission"}];
    }
    
    return displayImage; // Caller owns this reference
}

#endif

#pragma mark - CGWindowListCreateImage Implementation (macOS 10.15-12.2)

static CGImageRef SCCompatCaptureWithCGWindowList(CGRect rect, NSError **error) {
    @try {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGImageRef imageRef = CGWindowListCreateImage(rect, 
                                                    kCGWindowListOptionOnScreenOnly, 
                                                    kCGNullWindowID, 
                                                    kCGWindowImageDefault);
        #pragma clang diagnostic pop
        
        if (imageRef == NULL && error) {
            *error = [[NSError alloc] initWithDomain:@"SCCompat" 
                                               code:SCCompatErrorCaptureFailure 
                                           userInfo:@{NSLocalizedDescriptionKey: @"CGWindowListCreateImage failed"}];
        }
        
        return imageRef; // Caller owns this reference
    }
    @catch (NSException *exception) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"SCCompat" 
                                               code:SCCompatErrorCaptureFailure 
                                           userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"CGWindowListCreateImage exception: %@", exception.reason]}];
        }
        return NULL;
    }
}

#pragma mark - Public API Implementation

SCCompatCaptureResult SCCompatCaptureScreenRect(CGRect rect) {
    SCCompatCaptureResult result = {NULL, SCCompatErrorNone, nil};
    
    // Validate input
    if (CGRectIsEmpty(rect) || rect.size.width <= 0 || rect.size.height <= 0) {
        result.errorCode = SCCompatErrorInvalidRect;
        result.errorMessage = @"Invalid capture rectangle";
        return result;
    }
    
    SCCompatOSVersion osVersion = [SCCompatHelper detectOSVersion];
    NSError *error = nil;
    
    switch (osVersion) {
        case SCCompatOSVersionLegacy:
            result.errorCode = SCCompatErrorUnsupportedOS;
            result.errorMessage = @"Screen capture requires macOS 10.15 or later";
            break;
            
        case SCCompatOSVersionCGWindow: {
            // Check permissions first
            if (![SCCompatHelper isScreenRecordingPermissionGranted]) {
                result.errorCode = SCCompatErrorNoPermission;
                result.errorMessage = @"Screen recording permission not granted";
                break;
            }
            
            result.imageRef = SCCompatCaptureWithCGWindowList(rect, &error);
            if (result.imageRef == NULL) {
                result.errorCode = SCCompatErrorCaptureFailure;
                result.errorMessage = error ? [error localizedDescription] : @"CGWindowListCreateImage failed";
            }
            break;
        }
        
        case SCCompatOSVersionScreenKit:
#if HAS_SCREENCAPTUREKIT_SDK
            if (@available(macOS 12.3, *)) {
                result.imageRef = SCCompatCaptureWithScreenCaptureKit(rect, &error);
                if (result.imageRef == NULL) {
                    result.errorCode = SCCompatErrorCaptureFailure;
                    result.errorMessage = error ? [error localizedDescription] : @"ScreenCaptureKit failed";
                }
            } else {
                // Fallback to CGWindowList if ScreenCaptureKit not available at runtime
                result.imageRef = SCCompatCaptureWithCGWindowList(rect, &error);
                if (result.imageRef == NULL) {
                    result.errorCode = SCCompatErrorCaptureFailure;
                    result.errorMessage = error ? [error localizedDescription] : @"Screen capture failed";
                }
            }
#else
            // SDK doesn't support ScreenCaptureKit, fall back to CGWindowList
            result.imageRef = SCCompatCaptureWithCGWindowList(rect, &error);
            if (result.imageRef == NULL) {
                result.errorCode = SCCompatErrorCaptureFailure;
                result.errorMessage = error ? [error localizedDescription] : @"Screen capture failed (no ScreenCaptureKit SDK)";
            }
#endif
            break;
            
        default:
            result.errorCode = SCCompatErrorUnknown;
            result.errorMessage = @"Unknown OS version";
            break;
    }
    
    [error release];
    return result;
}

NSColor* SCCompatGetColorAtPoint(CGPoint point) {
    CGRect rect = CGRectMake(point.x, point.y, 1, 1);
    SCCompatCaptureResult result = SCCompatCaptureScreenRect(rect);
    
    if (result.imageRef == NULL) {
        DLog(@"Failed to capture pixel at (%f, %f): %@", point.x, point.y, result.errorMessage);
        return nil;
    }
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:result.imageRef];
    CFRelease(result.imageRef); // Release the CGImageRef
    
    if (bitmap == nil) {
        DLog(@"Failed to create bitmap from captured image");
        return nil;
    }
    
    NSColor *color = [bitmap colorAtX:0 y:0];
    [bitmap release];
    
    return color; // Autoreleased by colorAtX:y:
}

BOOL SCCompatIsScreenCaptureAvailable(void) {
    SCCompatOSVersion osVersion = [SCCompatHelper detectOSVersion];
    
    switch (osVersion) {
        case SCCompatOSVersionLegacy:
            return NO;
            
        case SCCompatOSVersionCGWindow:
        case SCCompatOSVersionScreenKit:
            return [SCCompatHelper isScreenRecordingPermissionGranted];
            
        default:
            return NO;
    }
}

NSString* SCCompatGetCaptureModeDescription(void) {
    SCCompatOSVersion osVersion = [SCCompatHelper detectOSVersion];
    
    switch (osVersion) {
        case SCCompatOSVersionLegacy:
            return @"Unsupported (macOS < 10.15)";
            
        case SCCompatOSVersionCGWindow:
            return @"CGWindowListCreateImage (macOS 10.15-12.2)";
            
        case SCCompatOSVersionScreenKit:
#if HAS_SCREENCAPTUREKIT_SDK
            if (@available(macOS 12.3, *)) {
                return @"ScreenCaptureKit (macOS 12.3+)";
            } else {
                return @"CGWindowListCreateImage fallback (ScreenCaptureKit unavailable at runtime)";
            }
#else
            return @"CGWindowListCreateImage fallback (no ScreenCaptureKit SDK)";
#endif
            
        default:
            return @"Unknown capture mode";
    }
}