#!/bin/bash

cliclickPath="$1"

if [[ "" = "$cliclickPath" ]]
then
    echo "Usage: $0 /path/to/cliclick" >&2
    exit 1
fi

if [[ ! -x "$cliclickPath" ]]
then
    echo "$cliclickPath does not exist or is not executable" >&2
    exit 1
fi


function assertStdoutOutput() {
    actual=$("$cliclickPath" $2)
    runStringComparison "$1" "$3" "$actual"
}

function assertStderrOutput() {
    actual=$("$cliclickPath" $2 3>&1 1>&2 2>&3)
    runStringComparison "$1" "$3" "$actual"
}

function assertClipboardContains() {
    local testDescription="$1"
    local expectedString="$2"

    pbContents=$(pbpaste)

    if [[ "$expectedString" = "$pbContents" ]]
    then
        echo "✅ $testDescription"
    else
        echo "⚠️  Failed test: $testDescription"
        echo "  Expected: $expectedString"
        echo "  Actual: $pbContents"
    fi
}

function assertFileContains() {
    local testDescription="$1"
    local path="$2"
    local expectedString="$3"
    fileContents=$(cat "$path")
    runStringComparison "$1" "$fileContents" "$3"
}

function runStringComparison {
    local testDescription="$1"
    local expected="$2"
    local actual="$3"
    local expectedLength=${#expected}

    if [[ "$expected" = ${actual:0:$expectedLength} ]]
    then
        echo "✅ $testDescription"
    else
        echo "⚠️  Failed test: $testDescription"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
    fi
}

# No arguments
assertStderrOutput \
    "When called without argument, should write info to stderr" \
    "" \
    "You did not pass any commands as argument to cliclick."$'\n'"Call cliclick with option -h to see usage instructions."

assertStderrOutput \
    "When called with an unknown action, should write error to stderr" \
    "z" \
    "Unrecognized action shortcut “z”"


# Assertions for move / m command
assertStderrOutput \
    "When using “move” (“m”) without coordinates, should write error to stderr" \
    "m" \
    "Missing argument to command “m”: Expected two coordinates (separated by a comma) or “.”"

assertStderrOutput \
    "When using “move” (“m”) with colon, but without coords, should write error to stderr" \
    "m:" \
    "Missing argument to command “m”: Expected two coordinates (separated by a comma) or “.”. Examples: “m:123,456” or “m:.”"

assertStderrOutput \
    "When using “move” (“m”) with invalid X value, should write error to stderr" \
    "m:foobar,-123" \
    "Invalid X axis coordinate “foobar” given"

assertStderrOutput \
    "When using “move” (“m”) with invalid Y value, should write error to stderr" \
    "m:+123,xxx" \
    "Invalid Y axis coordinate “xxx” given"

assertStderrOutput \
    "When using “move” (“m”) with missing Y value, should write error to stderr" \
    "m:+123," \
    "Invalid argument “+123,” to command “m”: Expected two coordinates (separated by a comma) or “.”. Examples: “m:123,456” or “m:.”"


# Move, testing mode
assertStdoutOutput \
    "When using “move” (“m”) in test mode, should write action to stdout" \
    "-m test m:123,456" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Move to 123,456"

assertStdoutOutput \
    "When using “move” (“m”) in test mode with relative coords, should write action to stdout" \
    "-m test m:+20,-17" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Move to +20,-17"


# Assertions for click / c command
assertStderrOutput \
    "When using “click” (“c”) without coords, should write error to stderr" \
    "c" \
    "Missing argument to command “c”: Expected two coordinates (separated by a comma) or “.”. Examples: “c:123,456” or “c:.”"

assertStderrOutput \
    "When using “click” (“c”) with colon, but without coordinates, should write error to stderr" \
    "c" \
    "Missing argument to command “c”: Expected two coordinates (separated by a comma) or “.”. Examples: “c:123,456” or “c:.”"

assertStderrOutput \
    "When using “click” (“c”) with invalid X value, should write error to stderr" \
    "c:foobar,-123" \
    "Invalid X axis coordinate “foobar” given"

assertStderrOutput \
    "When using “click” (“c”) with invalid Y value, should write error to stderr" \
    "c:+123,xxx" \
    "Invalid Y axis coordinate “xxx” given"

assertStderrOutput \
    "When using “click” (“c”) with missing Y value, should write error to stderr" \
    "c:+123," \
    "Invalid argument “+123,” to command “c”: Expected two coordinates (separated by a comma) or “.”. Examples: “c:123,456” or “c:.”"

assertStdoutOutput \
    "When using “click” (“c”) in test mode, should write action to stdout" \
    "-m test c:123,456" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at 123,456"

assertStdoutOutput \
    "When using “click” (“c”) in test mode with relative coords, should write action to stdout" \
    "-m test c:+20,-17" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at +20,-17"

assertStdoutOutput \
    "When using “click” (“c”) in test mode with absolute negative coords, should write action to stdout" \
    "-m test c:=-200,-100" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at =-200,-100"


# Assertions for double-click / command
assertStderrOutput \
    "When using “doubleclick” (“dc”) without coords, should write error to stderr" \
    "dc" \
    "Missing argument to command “dc”: Expected two coordinates (separated by a comma) or “.”. Examples: “dc:123,456” or “dc:.”"

assertStdoutOutput \
    "When using “doubleclick” (“dc”) in test mode, should write action to stdout" \
    "-m test dc:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Double-click at 1129,64"


# Assertions for triple-click / command
assertStderrOutput \
    "When using “tripleclick” (“tc”) without coords, should write error to stderr" \
    "tc" \
    "Missing argument to command “tc”: Expected two coordinates (separated by a comma) or “.”. Examples: “tc:123,456” or “tc:.”"

assertStdoutOutput \
    "When using “tripleclick” (“tc”) in test mode, should write action to stdout" \
    "-m test tc:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Triple-click at 1129,64"


# Assertions for right-click / command
assertStderrOutput \
    "When using “rightclick” (“rc”) without coords, should write error to stderr" \
    "rc" \
    "Missing argument to command “rc”: Expected two coordinates (separated by a comma) or “.”. Examples: “rc:123,456” or “rc:.”"

assertStdoutOutput \
    "When using “rightclick” (“rc”) in test mode, should write action to stdout" \
    "-m test rc:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Right-click at 1129,64"


# Assertions for drag down / dd command
assertStderrOutput \
    "When using “drag down” (“dd) without coords, should write error to stderr" \
    "dd" \
    "Missing argument to command “dd”: Expected two coordinates (separated by a comma) or “.”. Examples: “dd:123,456” or “dd:.”"

assertStdoutOutput \
    "When using “drag down” (“dd”) in test mode, should write action to stdout" \
    "-m test dd:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Drag press down at 1129,64"

# Assertions for drag up / du command
assertStderrOutput \
    "When using “drag up” (“du) without coords, should write error to stderr" \
    "du:" \
    "Missing argument to command “du”: Expected two coordinates (separated by a comma) or “.”. Examples: “du:123,456” or “du:.”"

assertStdoutOutput \
    "When using “drag up” (“rc”) in test mode, should write action to stdout" \
    "-m test du:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Drag release at 1129,64"


# Assertions for drag move / dm command
assertStderrOutput \
    "When using “drag move” (“dm”) without coords, should write error to stderr" \
    "dm" \
    "Missing argument to command “dm”: Expected two coordinates (separated by a comma) or “.”. Examples: “dm:123,456” or “dm:.”"

assertStdoutOutput \
    "When using “drag move (“dm”) in test mode, should write action to stdout" \
    "-m test dm:1129,64" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Drag move to 1129,64"


# Assertions for wait / w command
assertStderrOutput \
    "When using “wait” (“w”) without argument, should write error to stderr" \
    "w" \
    "Invalid or missing argument to command “w”: Expected number of milliseconds. Example: “w:50”"

assertStderrOutput \
    "When using “wait” (“w”) with a non-numeric argument, should write error to stderr" \
    "w:abc" \
    "Invalid or missing argument to command “w”: Expected number of milliseconds. Example: “w:50”"

assertStdoutOutput \
    "When using “wait” (“w”) in test mode, should write the action to stdout" \
    "-m test w:150" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Wait 150 milliseconds"


# Assertions for key down / kd command
assertStderrOutput \
    "When using “key down” (“kd”) without argument, should write error to stderr" \
    "kd" \
    "Missing argument to command “kd”: Expected one or more keys (separated by a comma). Examples: “kd:ctrl” or “kd:cmd,alt”"

assertStderrOutput \
    "When using “key down” (“kd”) with an invalid key, should write error to stderr" \
    "kd:abc" \
    "Invalid key “abc” given as argument to command “kd”."$'\n'"The key name may only be one of:"

assertStdoutOutput \
    "When using “key down” (“kd”) in test mode, should write the action stdout" \
    "-m test kd:ctrl" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Hold ctrl key down"

assertStdoutOutput \
    "When using “key down” (“kd”) in test mode several valid keys, should write the action stdout" \
    "-m test kd:ctrl,cmd,alt" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Hold ctrl key down"$'\n'"Hold cmd key down"$'\n'"Hold alt key down"


# Assertions for key up / ku command
assertStderrOutput \
    "When using “key up” (“ku”) without argument, should write error to stderr" \
    "ku" \
    "Missing argument to command “ku”"

assertStderrOutput \
    "When using “key up” (“ku”) with an invalid key, should write error to stderr" \
    "ku:abc" \
    "Invalid key “abc” given as argument to command “ku”"

assertStdoutOutput \
    "When using “key up” (“ku”) in test mode, should write the action to stdout" \
    "-m test ku:ctrl" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Release ctrl key"

assertStdoutOutput \
    "When using “key up” (“ku”) in test mode with several valid keys, should write the action stdout" \
    "-m test ku:ctrl,cmd,alt" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Release ctrl key"$'\n'"Release cmd key"$'\n'"Release alt key"


# Assertions for key press / kp command
assertStderrOutput \
    "When using “key press” (“kp”) argument, should write error to stderr" \
    "kp" \
    "Missing argument to command “kp”"

assertStderrOutput \
    "When using “key press” (“kp”) with an invalid key, should write error to stderr" \
    "kp:abc" \
    "Invalid key “abc” given as argument to command “kp”"

assertStdoutOutput \
    "When using “key press” (“kp”) in test mode, should write the action to stdout" \
    "-m test kp:return" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Press + release return key"


# Assertions for print / p command
assertStdoutOutput \
    "When using “print” (“p”) in test mode without argument, should write action to stdout" \
    "-m test p" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Print the current mouse position"

assertStdoutOutput \
    "When using “print” (“p”) with a dot as argument, should write action to stdout" \
    "-m test p:." \
    "Running in test mode. These command(s) would be executed:"$'\n'"Print the current mouse position" \

assertStdoutOutput \
    "When using “print” (“p”) with a string, should print the string" \
    "-m test p:Helloworld" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Print message “Helloworld”"

# Assertions for type / t command
assertStderrOutput \
    "When using “type” (“t”) without argument, should write error to stderr" \
    "t" \
    "Missing argument to command “t”"

assertStdoutOutput \
    "When using “type” (“t”) in test mode with a string as argument, should write the action to stdout" \
    "-m test t:Unimaginatively" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Type: “Unimaginatively”"


# Assertions for color picker / cp command
assertStderrOutput \
    "When using “color picker (“cp”) without argument, should write error to stderr" \
    "cp" \
    "Missing argument to command “cp”"

assertStderrOutput \
    "When using “color picker (“cp”) with invalid coordinates, should write error to stderr" \
    "cp:123" \
    "Invalid argument “123” to command “cp”"

assertStdoutOutput \
    "When using color” (“cp”) in test mode with a dot as argument, should write the action to stdout" \
    "-m test cp:." \
    "Running in test mode. These command(s) would be executed:"$'\n'"Print color at current mouse position"

assertStdoutOutput \
    "When using color” (“cp”) in test mode with coordinates as argument, should write the action to stdout" \
    "-m test cp:123,456" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Print color at location 123,456"

assertStderrOutput \
    "When setting the output destination for test mode to stderr, should write the action to stderr" \
    "-m test:stderr c:. m:123,456" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at current location"$'\n'"Move to 123,456"


# Test writing verbose messages to a file
assertStderrOutput \
    "When setting the output destination for test mode to an invalid path, should write the error to stderr" \
    "-m test:/no/such/path.txt c:. m:123,456" \
    "Cannot create file “/no/such/path.txt” specified as output destination"


tempfilePath=$(mktemp)

assertStdoutOutput \
    "When setting output destination for test mode to a file, should write nothing to stdout" \
    "-m test:$tempfilePath c:. m:123,456" \
    ""

assertFileContains \
    "When setting output destination for test mode to a file, the file should contain the commands" \
    "$tempfilePath" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at current location"$'\n'"Move to 123,456"

# Test writing verbose messages to the clipboard
assertStdoutOutput \
    "When setting output destination for test mode to the clipboard, should write nothing to stdout" \
    "-m test:clipboard c:. m:123,456" \
    ""

assertClipboardContains \
    "When setting output destination for test mode to the clipboard, the clipboard should contain the commands" \
    "Running in test mode. These command(s) would be executed:"$'\n'"Click at current location"$'\n'"Move to 123,456"


# Test setting command output destination using -d
assertStderrOutput \
    "When setting destination for command output to stderr, should write action to stderr" \
    "-d stderr p:OK" \
    "OK"

# Test setting command output destination using -d
assertStdoutOutput \
    "When setting destination for command output to stdout, should write the action to stdout" \
    "-d stdout p:OK" \
    "OK"
