#!/usr/bin/python -t
# -*- coding: utf-8 -*-

# Tests command line parsing and output
# Expects to find an executable “cliclick” in <projectdir>/Build/Products/Debug/

import sys
import os.path

def runWithArguments(args = ""):
    projdir = os.path.dirname(__file__)
    executable = projdir  + "/Build/Products/Debug/cliclick"
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

# Invalid X value
expectStringForArguments("Invalid X axis coordinate “foobar”", "m:foobar,-123")

# Invalid Y value
expectStringForArguments("Invalid Y axis coordinate “foobar”", "m:+123,foobar")

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
expectStringForArguments("Invalid key “abc” given as argument to command “kd”", "kd:abc")
expectStringForArguments("Invalid key “return” given as argument to command “kd”", "kd:return")
expectStringForArguments("Hold ctrl key down", "kd:ctrl")
expectStringForArguments("Hold ctrl key down\nHold cmd key down\nHold alt key down", "kd:ctrl,cmd,alt")
expectStringForArguments("Invalid key “return” given as argument", "kd:return")

# “ku” (key up)
expectStringForArguments("Missing argument to command “ku”: Expected", "ku")
expectStringForArguments("Missing argument to command “ku”: Expected", "ku:")
expectStringForArguments("Invalid key “abc” given as argument to command “ku”", "ku:abc")
expectStringForArguments("Release ctrl key", "ku:ctrl")
expectStringForArguments("Release ctrl key\nRelease cmd key\nRelease alt key", "ku:ctrl,cmd,alt")

# “kp” (key press)
expectStringForArguments("Missing argument to command “kp”: Expected", "kp")
expectStringForArguments("Missing argument to command “kp”: Expected", "kp:")
expectStringForArguments("Invalid key “abc” given as argument to command “kp”", "kp:abc")
expectStringForArguments("Invalid key “cmd” given as argument to command “kp”", "kp:cmd")
expectStringForArguments("Press + release return key", "kp:return")

# “p” (print)
expectStringForArguments("Print the current mouse position", "p")
expectStringForArguments("Print the current mouse position", "p:.")
expectStringForArguments("Print the current mouse position", "p:'.'")
expectStringForArguments("Print message “Hello world”", "p:'Hello world'")

# “dd” (drag down)
expectStringForArguments("Missing argument to command “dd”: Expected", "dd")
expectStringForArguments("Missing argument to command “dd”: Expected", "dd:")
expectStringForArguments("Invalid argument “1” to command “dd”: Expected two coordinates", "dd:1")
expectStringForArguments("Invalid argument “1,” to command “dd”: Expected two coordinates", "dd:1,")
expectStringForArguments("Drag press down at 1129,64", "dd:1129,64")

# “du” (drag up)
expectStringForArguments("Missing argument to command “du”: Expected", "du")
expectStringForArguments("Missing argument to command “du”: Expected", "du:")
expectStringForArguments("Invalid argument “1” to command “du”: Expected two coordinates", "du:1")
expectStringForArguments("Invalid argument “1,” to command “du”: Expected two coordinates", "du:1,")
expectStringForArguments("Drag release at 1129,64", "du:1129,64")

# “t” (type)
expectStringForArguments("Missing argument to command “t”: Expected", "t")
expectStringForArguments("Missing argument to command “t”: Expected", "t:")
expectStringForArguments("Type: “Type this: How are you today?”", "t:'Type this: How are you today?'")

# “cp” (color picker)
expectStringForArguments("Missing argument to command “cp”: Expected", "cp")
expectStringForArguments("Missing argument to command “cp”: Expected", "cp:")
expectStringForArguments("Print color at location 123,456", "cp:123,456")

# “sl” (scroll line)
expectStringForArguments("Missing argument to command “sl”: Expected", "sl")
expectStringForArguments("Missing argument to command “sl”: Expected", "sl:")
expectStringForArguments("Scroll up/down -20, left/right 13 lines", "sl:+20,-13")

# “sp” (scroll pixels)
expectStringForArguments("Missing argument to command “sp”: Expected", "sp")
expectStringForArguments("Missing argument to command “sp”: Expected", "sp:")
expectStringForArguments("Scroll up/down 200, left/right -85 pixels", "sp:-200,85")
