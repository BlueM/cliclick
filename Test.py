#!/usr/bin/python -t
# -*- coding: utf-8 -*-

import sys
import os.path
import tempfile
from subprocess import PIPE, Popen

def assertOutput(testDescription, args, stdOutOutput, stdErrOutput):
    cmd = "%s %s" % (sys.argv[1], args)
    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    errors = []

    if (stdOutOutput and -1 == stdout.find(stdOutOutput)):
        errors.append("Did not find this string in stdout: %s (actual: %s)" % (stdOutOutput, stdout.replace("\n", " ")))
    if (not stdOutOutput and stdout):
        errors.append("Expected empty stdout, but got: %s" % (stdout.replace("\n", " ")))

    if (stdErrOutput and -1 == stderr.find(stdErrOutput)):
        errors.append("Did not find this string in stderr: %s (actual: %s)" % (stdErrOutput, stderr.replace("\n", " ")))
    if (not stdErrOutput and stderr):
        errors.append("Expected empty stdout, but got: %s" % (stderr.replace("\n", " ")))

    if errors:
        print "[ ] %s" % (testDescription)
        for error in errors:
            print "    * %s" % (error)
        print "    * cliclick was called with argument(s): %s" % (args)
    else:
        print "[X] %s" % (testDescription)


def assertClipboardContains(testDescription, stdOutOutput):
    p = Popen("pbpaste", shell=True, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    if (-1 == stdout.find(stdOutOutput)):
        print "[ ] %s" % (testDescription)
    else:
        print "[X] %s" % (testDescription)


def assertFileContains(testDescription, filepath, needle):
    f = open(filepath, 'r')
    content = f.read()
    if (-1 == content.find(needle)):
        print "[ ] %s" % (testDescription)
    else:
        print "[X] %s" % (testDescription)


# Make sure cliclick path is passed as argument
if len(sys.argv) < 2:
    print "Argument missing.\nUsage: %s /absolute/or/relative/path/to/cliclick" % (sys.argv[0])
    sys.exit(1)


# No arguments
assertOutput(
    "When called without argument, should write nothing to stdout and usage info to stderr",
    "",
    "",
    "You did not pass any commands as argument"
)

assertOutput(
    "When called with an unknown action, should write nothing to stdout and error to stderr",
    "z",
    "",
    "Unrecognized action shortcut “z”"
)


# Assertions for move / m command
assertOutput(
    "When using “move” (“m”) command without coordinates, should write nothing to stdout and error to stderr",
    "m",
    "",
    "Missing argument to command “m”"
)

assertOutput(
    "When using “move” (“m”) command with colon, but without coordinates, should write nothing to stdout and error to stderr",
    "m",
    "",
    "Missing argument to command “m”"
)

assertOutput(
    "When using “move” (“m”) command with invalid X value, should write nothing to stdout and error to stderr",
    "m:foobar,-123",
    "",
    "Invalid X axis coordinate “foobar”"
)

assertOutput(
    "When using “move” (“m”) command with invalid Y value, should write nothing to stdout and error to stderr",
    "m:+123,xxx",
    "",
    "Invalid Y axis coordinate “xxx”"
)

assertOutput(
    "When using “move” (“m”) command with missing Y value, should write nothing to stdout and error to stderr",
    "m:+123,",
    "",
    "Invalid argument “+123,” to command “m”"
)

assertOutput(
    "When using “move” (“m”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test m:123,456",
    "Move to 123,456",
    ""
)

assertOutput(
    "When using “move” (“m”) in testing mode with relative coordinates, should write action to stdout and nothing to stderr",
    "-m test m:+20,-17",
    "Move to +20,-17",
    ""
)

# Assertions for click / c command
assertOutput(
    "When using “click” (“c”) command without coordinates, should write nothing to stdout and error to stderr",
    "c",
    "",
    "Missing argument to command “c”"
)

assertOutput(
    "When using “click” (“c”) command with colon, but without coordinates, should write nothing to stdout and error to stderr",
    "c",
    "",
    "Missing argument to command “c”"
)

assertOutput(
    "When using “click” (“c”) command with invalid X value, should write nothing to stdout and error to stderr",
    "c:foobar,-123",
    "",
    "Invalid X axis coordinate “foobar”"
)

assertOutput(
    "When using “click” (“c”) command with invalid Y value, should write nothing to stdout and error to stderr",
    "c:+123,xxx",
    "",
    "Invalid Y axis coordinate “xxx”"
)

assertOutput(
    "When using “click” (“c”) command with missing Y value, should write nothing to stdout and error to stderr",
    "c:+123,",
    "",
    "Invalid argument “+123,” to command “c”"
)

assertOutput(
    "When using “click” (“c”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test c:123,456",
    "Click at 123,456",
    ""
)

assertOutput(
    "When using “click” (“c”) in testing mode with relative coordinates, should write action to stdout and nothing to stderr",
    "-m test c:+20,-17",
    "Click at +20,-17",
    ""
)

assertOutput(
    "When using “click” (“c”) in testing mode with absolute negative coordinates, should write action to stdout and nothing to stderr",
    "-m test c:=-200,-100",
    "Click at =-200,-100",
    ""
)


# Assertions for double-click / command
assertOutput(
    "When using “doubleclick” (“dc”) command without coordinates, should write nothing to stdout and error to stderr",
    "dc",
    "",
    "Missing argument to command “dc”"
)

assertOutput(
    "When using “doubleclick” (“dc”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test dc:1129,64",
    "Double-click at 1129,64",
    ""
)

# Assertions for triple-click / command
assertOutput(
    "When using “tripleclick” (“tc”) command without coordinates, should write nothing to stdout and error to stderr",
    "tc",
    "",
    "Missing argument to command “tc”"
)

assertOutput(
    "When using “tripleclick” (“tc”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test tc:1129,64",
    "Triple-click at 1129,64",
    ""
)

# Assertions for right-click / command
assertOutput(
    "When using “rightclick” (“rc”) command without coordinates, should write nothing to stdout and error to stderr",
    "rc",
    "",
    "Missing argument to command “rc”"
)

assertOutput(
    "When using “rightclick” (“rc”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test rc:1129,64",
    "Right-click at 1129,64",
    ""
)

# Assertions for drag down / dd command
assertOutput(
    "When using “drag down” (“dd) command without coordinates, should write nothing to stdout and error to stderr",
    "dd",
    "",
    "Missing argument to command “dd”"
)

assertOutput(
    "When using “drag down” (“dd”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test dd:1129,64",
    "Drag press down at 1129,64",
    ""
)

# Assertions for drag up / du command
assertOutput(
    "When using “drag up” (“du) command without coordinates, should write nothing to stdout and error to stderr",
    "du:",
    "",
    "Missing argument to command “du”"
)

assertOutput(
    "When using “drag up” (“rc”) in testing mode, should write action to stdout and nothing to stderr",
    "-m test du:1129,64",
    "Drag release at 1129,64",
    ""
)

# Assertions for wait / w command
assertOutput(
    "When using “wait” (“w”) command without argument, should write nothing to stdout and error to stderr",
    "w",
    "",
    "Invalid or missing argument to command “w”"
)

assertOutput(
    "When using “wait” (“w”) command with a non-numeric argument, should write nothing to stdout and error to stderr",
    "w:abc",
    "",
    "Invalid or missing argument to command “w”"
)

assertOutput(
    "When using “wait” (“w”) command in testing mode, should write the action to stdout and nothing to stderr",
    "-m test w:150",
    "Wait 150 milliseconds",
    ""
)

# Assertions for key down / kd command
assertOutput(
    "When using “key down” (“kd”) command without argument, should write nothing to stdout and error to stderr",
    "kd",
    "",
    "Missing argument to command “kd”",
)

assertOutput(
    "When using “key down” (“kd”) with an invalid key, should write nothing to stdout and error to stderr",
    "kd:abc",
    "",
    "Invalid key “abc” given as argument to command “kd”",
)

assertOutput(
    "When using “key down” (“kd”) with a valid key, should write the action stdout and nothing to stderr",
    "-m test kd:ctrl",
    "Hold ctrl key down",
    "",
)

assertOutput(
    "When using “key down” (“kd”) with several valid keys, should write the action stdout and nothing to stderr",
    "-m test kd:ctrl,cmd,alt",
    "Hold ctrl key down\nHold cmd key down\nHold alt key down",
    "",
)

# Assertions for key up / ku command
assertOutput(
    "When using “key up” (“ku”) command without argument, should write nothing to stdout and error to stderr",
    "ku",
    "",
    "Missing argument to command “ku”",
)

assertOutput(
    "When using “key up” (“ku”) with an invalid key, should write nothing to stdout and error to stderr",
    "ku:abc",
    "",
    "Invalid key “abc” given as argument to command “ku”",
)

assertOutput(
    "When using “key up” (“ku”) with a valid key, should write the action to stdout and nothing to stderr",
    "-m test ku:ctrl",
    "Release ctrl key",
    "",
)

assertOutput(
    "When using “key up” (“ku”) with several valid keys, should write the action stdout and nothing to stderr",
    "-m test ku:ctrl,cmd,alt",
    "Release ctrl key\nRelease cmd key\nRelease alt key",
    "",
)

# Assertions for key press / kp command
assertOutput(
    "When using “key press” (“kp”) command without argument, should write nothing to stdout and error to stderr",
    "kp",
    "",
    "Missing argument to command “kp”"
)

assertOutput(
    "When using “key press” (“kp”) command with an invalid key, should write nothing to stdout and error to stderr",
    "kp:abc",
    "",
    "Invalid key “abc” given as argument to command “kp”"
)

assertOutput(
    "When using “key press” (“kp”) command with a valid key, should write the action to stdout and nothing to stderr",
    "-m test kp:return",
    "Press + release return key",
    ""
)

# Assertions for print / p command
assertOutput(
    "When using “print” (“p”) command without argument, should print the current mouse position",
    "-m test p",
    "Print the current mouse position",
    ""
)

assertOutput(
    "When using “print” (“p”) command with a dot as argument, should print the current mouse position",
    "-m test p:.",
    "Print the current mouse position",
    ""
)

assertOutput(
    "When using “print” (“p”) command with a string, should print the string",
    "-m test p:'Hello world'",
    "Print message “Hello world”",
    ""
)

# Assertions for type / t command
assertOutput(
    "When using “type” (“t”) command without argument, should write nothing to stdout and error to stderr",
    "t",
    "",
    "Missing argument to command “t”"
)

assertOutput(
    "When using “type” (“t”) command with a string as argument, should write the action to stdout and nothing to stderr",
    "-m test t:'Type this: How are you today?'",
    "Type: “Type this: How are you today?”",
    ""
)

# Assertions for color picker / cp command
assertOutput(
    "When using “color picker (“cp”) command without argument, should write nothing to stdout and error to stderr",
    "cp",
    "",
    "Missing argument to command “cp”"
)

assertOutput(
    "When using “color picker (“cp”) command with invalid coordinates, should write nothing to stdout and error to stderr",
    "cp:123",
    "",
    "Invalid argument “123” to command “cp”"
)

assertOutput(
    "When using color” (“cp”) command with a dot as argument, should write the action to stdout and nothing to stderr",
    "-m test cp:.",
    "Print color at current mouse position",
    ""
)

assertOutput(
    "When using color” (“cp”) command with coordinates as argument, should write the action to stdout and nothing to stderr",
    "-m test cp:123,456",
    "Print color at location 123,456",
    ""
)

assertOutput(
    "When setting the output destination for test mode to stderr, should write nothing to stdout and the action to stderr",
    "-m test:stderr c:. m:123,456",
    "",
    "Click at current location\nMove to 123,456"
)

# Test writing verbose messages to a file
assertOutput(
    "When setting the output destination for test mode to a file with an invalid path, should write nothing to stdout and the error to stderr",
    "-m test:/no/such/path.txt c:. m:123,456",
    "",
    "Cannot create file “/no/such/path.txt” specified as output destination"
)

tempfilePath = tempfile.mkstemp()[1]
assertOutput(
    "When setting the output destination for test mode to a file, should write nothing to stdout and nothing to stderr",
    "-m test:%s c:. m:123,456" % (tempfilePath),
    "",
    ""
)
assertFileContains(
    "When setting the output destination for test mode to a file, the file should contain the commands",
    tempfilePath,
    "Click at current location\nMove to 123,456"
)

# Test writing verbose messages to the clipboard
assertOutput(
    "When setting the output destination for test mode to the clipboard, should write nothing to stdout and nothing to stderr",
    "-m test:clipboard c:. m:123,456",
    "",
    ""
)
assertClipboardContains(
    "When setting the output destination for test mode to the clipboard, the clipboard should contain the commands",
    "Click at current location\nMove to 123,456"
)

# Test setting command output destination using -d
assertOutput(
    "When setting the destination for command output to stderr, should write nothing to stdout and the action to stderr",
    "-d stderr p:OK",
    "",
    "OK"
)

# Test setting command output destination using -d
assertOutput(
    "When setting the destination for command output to stdout, should write the action to stdout and nothing to stderr",
    "-d stdout p:OK",
    "OK",
    ""
)
