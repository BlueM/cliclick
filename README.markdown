cliclick Overview
=========================

cliclick (short for “Command Line Interface Click”) is a tool for executing mouse- and keyboard-related actions from the shell/Terminal. It is written in Objective-C and runs on Mac OS X 10.5 or later, including OS X 10.8.

For more information, please take a look at [cliclick’s homepage](http://www.bluem.net/jump/cliclick/)

Author: Carsten Blüm, Website: [www.bluem.net](http://www.bluem.net/)

Usage
---------
To get a quick first impression, this is what you will get when you invoke `cliclick -h`:

    USAGE
      cliclick [-m <mode>] [-f <file>] [-w <num>] [-r] command1 [command2] [...]
    
    OPTIONS
      -r        Restore initial mouse location when finished
      -m <mode> The mode can be either “verbose” (cliclick will print a
                description of each action to stdout just before it is
                performed) or “test” (cliclick will only print the
                description, but not perform the action)
      -f <file> Instead of passing commands as arguments, you may instead
                specify a file from which cliclick will read the commands.
                Each line in the file is expected to contain a command
                in the same format/syntax as commands given as arguments
                at the shell. Additionally, lines starting with the hash
                character # are regarded as comments, i.e.: ignored. Leading
                and trailing whitespace is ignored, too.
      -w <num>  Wait the given number of milliseconds after each event.
                If you find that you use the “wait” command too often,
                using -w could make things easer. Please note that “wait”
                is not affected by -w. This means that invoking
                “cliclick -w 200 wait:500” will wait for 700 milliseconds.
                The default (and minimum) value for -w is 20.
      -d        Send a donation
    
    COMMANDS
    To use cliclick, you pass an arbitrary number of commands as arguments.
    A command consists of a command identifier (a string that tells cliclick
    what kind of action to perform) and usually one or more arguments to the
    command, which are separated from the command identifier with a colon.
    Example: “c:123,456” is the command for clicking (the “c” is the command
    identifier for clicking) at the position with x coordinate 123 and y
    coordinate 456. See below for a list of all commands and the arguments they
    expect.
    Whenever a command expects a pair of coordinates, you may provide
    relative values by prefixing the number with “+” or “-”. For example,
    “m:+50,+0” will move the mouse 50 pixels to the right. Of course, relative
    and absolute values can be mixed, and negative values are possible, so
    “c:100,-20” would be perfectly valid. (If you need to specify absolute
    negative values in case you have a setup with a second display arranged to
    the left of your main display, prefix the number with “=”, for instance
    “c:100,=-200”.)
    
    LIST OF COMMANDS
    
      c:x,y   Will CLICK at the point with the given coordinates.
              Example: “c:12,34” will click at the point with x coordinate
              12 and y coordinate 34. Instead of x and y values, you may
              also use “.”, which means: the current position. Using “.” is
              equivalent to using relative zero values “c:+0,+0”.
    
      m:x,y   MOVE the mouse to the point with the given coordinates.
              Example: “m:12,34” will move the mouse to the point with
              x coordinate 12 and y coordinate 34.
    
      dc:x,y  Will DOUBLE-CLICK at the point with the given coordinates.
              Example: “dc:12,34” will double-click at the point with x
              coordinate 12 and y coordinate 34. Instead of x and y values,
              you may also use “.”, which means: the current position.
    
      tc:x,y  Will TRIPLE-CLICK at the point with the given coordinates.
              Example: “tc:12,34” will triple-click at the point with x
              coordinate 12 and y coordinate 34. Instead of x and y values,
              you may also use “.”, which means: the current position.
    
      kd:keys Will trigger a KEY DOWN event for a comma-separated list of
              modifier keys (“cmd”, “alt” or “ctrl”).
              Example: “kd:cmd,alt” will press the command key and the
              option key (and will keep them down until you release them
              with another command)
    
      ku:keys Will trigger a KEY UP event for a comma-separated list of
              modifier keys (“cmd”, “alt” or “ctrl”).
              Example: “ku:cmd,ctrl” will release the command key and the
              control key (which will only have an effect if you performed
              a “key down” before)
    
      p[:str] Will PRINT the given string. If the string is “.”, the
              current MOUSE POSITION is printed. As a convenience, you can skip
              the string completely and just write “p” to get the current position.
              Example: “p:.” or “p” will print the current mouse position
              Example: “p:'Hello world'” will print “Hello world”
    
      w:ms    Will WAIT/PAUSE for the given number of milliseconds.
              Example: “w:500” will pause command execution for half a second
    
      kp:key  Will emulate PRESSING A KEY (key down + key up). For the moment,
              only “return” or “esc” can be used as key.
              Example: “kp:return” will hit the return key.


Building cliclick
-----------------
Either build in Xcode, as usual, or build from the shell by `cd`ing into the project directory and then invoking `xcodebuild`.

Please keep in mind that while the code will run on 10.5 (Intel or PPC) and later, Base SDK and architectures selected in the Xcode project are set to the 10.7 SDK and Intel32/64. Therefore, if you want to build for an older system, be sure to change these settings accordingly.
