#!/usr/bin/python -t
# -*- coding: utf-8 -*-

# Tests command line parsing and output
# Expects to find an executable “cliclick” in <projectdir>/build/Debug

import sys
import os.path

def runWithArguments(args = ""):
    projdir = os.path.dirname(__file__)
    executable = projdir  + "/build/Debug/cliclick"
    cmd = "%s -m test %s" % (executable, args)
    result = ''.join(os.popen(cmd, 'r').readlines())
    return result

def expectStringForArguments(string, args):
    result = runWithArguments(args)
    if (-1 == result.find(string)):
        print "Did not find [%s] in result when calling with arguments [%s].\nGot [%s]\n" % (string, args, result)

# No arguments
expectStringForArguments("You did not pass any commands as argument", "")

# Invalid action shortcut
expectStringForArguments("Unrecognized action shortcut “z”", "z")

# “m” (move)
expectStringForArguments("Missing argument to command “m”: Expected", "m")
expectStringForArguments("Missing argument to command “m”: Expected", "m:")
expectStringForArguments("Invalid argument “123” to command “m”: Expected", "m:123")
expectStringForArguments("Invalid argument “123,” to command “m”: Expected", "m:123,")
expectStringForArguments("Move to 123,456", "m:123,456")
expectStringForArguments("Move to +20,-17", "m:+20,-17")

# “w” (wait)
expectStringForArguments("Invalid or missing argument to command “w”: Expected", "w")
expectStringForArguments("Invalid or missing argument to command “w”: Expected", "w:")
expectStringForArguments("Invalid or missing argument to command “w”: Expected", "w:a")
expectStringForArguments("Wait 150 milliseconds", "w:150")
expectStringForArguments("Wait 2000 milliseconds", "w:2000")

# “c” (click)
expectStringForArguments("Missing argument to command “c”: Expected", "c")
expectStringForArguments("Missing argument to command “c”: Expected", "c:")
expectStringForArguments("Invalid argument “1” to command “c”: Expected two coordinates", "c:1")
expectStringForArguments("Invalid argument “1,” to command “c”: Expected two coordinates", "c:1,")
expectStringForArguments("Click at 1129,64", "c:1129,64")
expectStringForArguments("Click at +0,80", "c:+0,80")

# “dc” (double-click)
expectStringForArguments("Missing argument to command “dc”: Expected", "dc")
expectStringForArguments("Missing argument to command “dc”: Expected", "dc:")
expectStringForArguments("Invalid argument “1” to command “dc”: Expected two coordinates", "dc:1")
expectStringForArguments("Invalid argument “1,” to command “dc”: Expected two coordinates", "dc:1,")
expectStringForArguments("Double-click at 1129,64", "dc:1129,64")

# “tc” (triple-click)
expectStringForArguments("Missing argument to command “tc”: Expected", "tc")
expectStringForArguments("Missing argument to command “tc”: Expected", "tc:")
expectStringForArguments("Invalid argument “1” to command “tc”: Expected two coordinates", "tc:1")
expectStringForArguments("Invalid argument “1,” to command “tc”: Expected two coordinates", "tc:1,")
expectStringForArguments("Triple-click at 1129,64", "tc:1129,64")

# “kd” (key down)
expectStringForArguments("Missing argument to command “kd”: Expected", "kd")
expectStringForArguments("Missing argument to command “kd”: Expected", "kd:")
expectStringForArguments("Invalid argument key name “abc” to command “kd”", "kd:abc")
expectStringForArguments("Press ctrl key", "kd:ctrl")
expectStringForArguments("Press ctrl key\nPress cmd key\nPress alt key", "kd:ctrl,cmd,alt")

# “ku” (key up)
expectStringForArguments("Missing argument to command “ku”: Expected", "ku")
expectStringForArguments("Missing argument to command “ku”: Expected", "ku:")
expectStringForArguments("Invalid argument key name “abc” to command “ku”", "ku:abc")
expectStringForArguments("Release ctrl key", "ku:ctrl")
expectStringForArguments("Release ctrl key\nRelease cmd key\nRelease alt key", "ku:ctrl,cmd,alt")

# “kp” (key up)
expectStringForArguments("Missing argument to command “kp”: Expected", "kp")
expectStringForArguments("Missing argument to command “kp”: Expected", "kp:")
expectStringForArguments("Invalid argument key name “abc” to command “kp”", "kp:abc")
expectStringForArguments("Press + release return key", "kp:return")

# “p” (print)
expectStringForArguments("Print the current mouse position", "p")
expectStringForArguments("Print the current mouse position", "p:.")
expectStringForArguments("Print the current mouse position", "p:'.'")
expectStringForArguments("Print message “Hello world”", "p:'Hello world'")
