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

#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#import <Cocoa/Cocoa.h>
#import "ActionExecutor.h"
#import "MoveAction.h"

void error();
void help();
NSArray* parseCommandsFile(NSString *filepath);

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSString *modeOption = nil;
    NSString *filepath = nil;
    NSArray *actions;
    CGPoint initialMousePosition;
    BOOL restoreOption = NO;
    unsigned mode;
    unsigned waitTime = 0;
    int optchar;

    while ((optchar = getopt(argc, (char * const *)argv, "hoVm:rf:w:n")) != -1) {
        switch(optchar) {
            case 'h':
                help();
                [pool release];
                return EXIT_SUCCESS;
            case 'V':
                printf("%s\n", [[NSString stringWithFormat:@"cliclick %@, %@", VERSION, RELEASEDATE] UTF8String]);
                [pool release];
                return EXIT_SUCCESS;
            case 'n':
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:DONATIONS_URL]];
                [pool release];
                return EXIT_SUCCESS;
            case 'o':
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HISTORY_URL]];
                [pool release];
                return EXIT_SUCCESS;
            case 'm':
                modeOption = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                break;
            case 'f':
                filepath = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                break;
            case 'r':
                restoreOption = YES;
                break;
            case 'w':
                waitTime = atoi(optarg);
                break;
            default:
                [pool release];
                return EXIT_FAILURE;
        }
    }

    if ([modeOption isEqualToString:@"verbose"]) {
        mode = MODE_VERBOSE;
    } else if ([modeOption isEqualToString:@"test"]) {
        mode = MODE_TEST;
    } else if (!modeOption) {
        mode = MODE_REGULAR;
    } else {
        printf("Only “verbose” or “test” are valid values for the -m argument\n");
        [pool release];
        return EXIT_FAILURE;
    }

    if (restoreOption) {
        CGEventRef ourEvent = CGEventCreate(NULL);
        initialMousePosition = CGEventGetLocation(ourEvent);
    }

    if (optind == argc && !filepath) {
        error();
        [pool release];
        return EXIT_FAILURE;
    }

    if (mode == MODE_TEST) {
        printf("Running in test mode. These command(s) would be executed:\n");
    }

    if (filepath) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([filepath isEqualToString:@""]) {
            printf("Option -f expects a path: -f /path/to/the/file\n");
            [pool release];
            return EXIT_FAILURE;
        }
        if (![filepath isEqualToString:@"-"] && ![fm fileExistsAtPath:filepath]) {
            printf("There is no file at %s\n", [filepath UTF8String]);
            [pool release];
            return EXIT_FAILURE;
        }
        actions = parseCommandsFile(filepath);
    } else {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        actions = [arguments subarrayWithRange:NSMakeRange(optind, argc - optind)];
    }

    @try {
        [ActionExecutor executeActions:actions
                                inMode:mode
                   waitingMilliseconds:waitTime];
    }
    @catch (NSException *e) {
        printf("%s\n", [[e reason] UTF8String]);
        [pool release];
        return EXIT_FAILURE;
    }
    @finally {
        // Nothing to clean up
    }

    if (restoreOption) {
        NSString *positionString = [NSString stringWithFormat:@"%d,%d", (int)initialMousePosition.x, (int)initialMousePosition.y];
        id moveAction = [[MoveAction alloc] init];
        [moveAction performActionWithData:positionString
                                   inMode:MODE_REGULAR];
        [moveAction release];
        if (mode == MODE_VERBOSE) {
            printf("Restoring mouse position to %s\n", [positionString UTF8String]);
        }
    }

    [pool release];
    return EXIT_SUCCESS;
}

NSArray* parseCommandsFile(NSString *filepath) {
    NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:32];
    NSArray *lines;

    if ([filepath isEqualToString:@"-"]) {
        // stdin
        NSData *stdinData = [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
        NSString *configString = [[NSString alloc] initWithData:stdinData encoding:NSUTF8StringEncoding];
        lines = [configString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    } else {
        // File
        NSString *fileContents = [NSString stringWithContentsOfFile:filepath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        lines = [fileContents componentsSeparatedByString:@"\n"];
    }

    NSUInteger i, count = [lines count];
    for (i = 0; i < count; i++) {
        NSString *command = [[lines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([command isEqualToString:@""]) {
            continue;
        }
        if ([[command substringToIndex:1] isEqualToString:@"#"]) {
            continue;
        }
        [commands addObject:command];
    }

    return [commands autorelease];
}

void error() {
    printf("You did not pass any commands as argument to cliclick.\n");
    printf("Call cliclick with option -h to see usage instructions.\n");
}

void help() {

    NSArray *actionClasses = [ActionExecutor actionClasses];
    NSUInteger i, count = [actionClasses count];

    NSString *help = @"\ncliclick (short for “Command Line Interface Click”) is a tool for "
    "executing mouse- and keyboard-related actions from the shell/Terminal\n"
    "\n"
    "USAGE\n"
    "  cliclick [-m <mode>] [-f <file>] [-w <num>] [-r] command1 [command2] [...]\n"
    "\n"
    "OPTIONS\n"
    "  -r        Restore initial mouse location when finished\n"
    "  -m <mode> The mode can be either “verbose” (cliclick will print a\n"
    "            description of each action to stdout just before it is\n"
    "            performed) or “test” (cliclick will only print the\n"
    "            description, but not perform the action)\n"
    "  -f <file> Instead of passing commands as arguments, you may instead\n"
    "            specify a file from which cliclick will read the commands\n"
    "            (or stdin, when - is given as filename).\n"
    "            Each line in the file is expected to contain a command\n"
    "            in the same format/syntax as commands given as arguments\n"
    "            at the shell. Additionally, lines starting with the hash\n"
    "            character # are regarded as comments, i.e.: ignored. Leading\n"
    "            and trailing whitespace is ignored, too.\n"
    "  -w <num>  Wait the given number of milliseconds after each event.\n"
    "            If you find that you use the “wait” command too often,\n"
    "            using -w could make things easier. Please note that “wait”\n"
    "            is not affected by -w. This means that invoking\n"
    "            “cliclick -w 200 wait:500” will wait for 700 milliseconds.\n"
    "            The default (and minimum) value for -w is 20.\n"
    "  -V        Show cliclick version number and release date\n"
    "  -o        Open version history in a browser\n"
    "  -n        Send a donation\n"
    "\n"
    "COMMANDS\n"
    "To use cliclick, you pass an arbitrary number of commands as arguments. A command consists of a "
    "command identifier (a string that tells cliclick what kind of action to perform) and usually one "
    "or more arguments to the command, which are separated from the command identifier with a colon. "
    "Example: “c:123,456” is the command for clicking (the “c” is the command identifier for clicking) "
    "at the position with x coordinate 123 and y coordinate 456. See below for a list of all commands "
    "and the arguments they expect.\nWhenever a command expects a pair of coordinates, you may provide "
    "relative values by prefixing the number with “+” or “-”. For example, “m:+50,+0” will move the mouse 50 "
    "pixels to the right. Of course, relative and absolute values can be mixed, and negative values "
    "are possible, so “c:100,-20” would be perfectly valid. (If you need to specify absolute negative "
    "values in case you have a setup with a second display arranged to the left of your main display, "
    "prefix the number with “=”, for instance “c:100,=-200”.)\n\n"
    "LIST OF COMMANDS\n\n";

    printf("%s", [help UTF8String]);

    for (i = 0; i < count; i++) {
        NSString *className = [actionClasses objectAtIndex:i];
        printf("%s\n\n", [[NSClassFromString(className) commandDescription] UTF8String]);
    }

    NSString *author = [NSString stringWithFormat:@"Version %@, released %@\n"
                        "Author: Carsten Blüm, <carsten@bluem.net>\n"
                        "List of contributors: https://github.com/BlueM/cliclick/graphs/contributors\n"
                        "Website: www.bluem.net/jump/cliclick/\n\n",
                        VERSION,
                        RELEASEDATE];
    printf("%s", [author UTF8String]);
}
