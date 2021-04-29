cliclick Overview
=========================

cliclick (short for “Command Line Interface Click”) is a tool for executing mouse- and keyboard-related actions from the shell/Terminal. It is written in Objective-C and runs on OS X 10.15 or later.

For more information or for downloading a compiled binary, please take a look at [cliclick’s homepage](https://www.bluem.net/jump/cliclick/)

Author: Carsten Blüm, Website: [www.bluem.net](https://www.bluem.net/)

Usage
---------
To get a quick first impression, this is what you will get when you invoke `cliclick -h`:

    USAGE
      cliclick [-r] [-m <mode>] [-d <target>] [-e <num>] [-f <file>] [-w <num>] command1 [command2]
    
    OPTIONS
      -r          Restore initial mouse location when finished
      -m <mode>   The mode can be either “verbose” (cliclick will print a
                  description of each action to stdout just before it is
                  performed) or “test” (cliclick will only print the
                  description, but not perform the action)
      -d <target> Specify the target when using the “p” (“print”) command.
                  Possible values are: stdout, stderr, clipboard or the path 
                  to a file (which will be overwritten if it exists).
                  By default (if option not given), stdout is used for printing
      -e <easing> Set an easing factor for mouse movements. The higher this
                  value is (default: 0), the more will mouse movements seem
                  “natural” or “human-like”, which also implies: will be slower.
                  If this option is used, the actual speed will also depend
                  on the distance between the start and the end position, i.e.
                  the time needed for moving will be higher if the distance
                  is larger.
      -f <file>   Instead of passing commands as arguments, you may instead
                  specify a file from which cliclick will read the commands
                  (or stdin, when - is given as filename).
                  Each line in the file is expected to contain a command
                  in the same format/syntax as commands given as arguments
                  at the shell. Additionally, lines starting with the hash
                  character # are regarded as comments, i.e.: ignored. Leading
                  and trailing whitespace is ignored, too.
      -w <num>    Wait the given number of milliseconds after each event.
                  If you find that you use the “wait” command too often,
                  using -w could make things easier. Please note that “wait”
                  is not affected by -w. This means that invoking
                  “cliclick -w 200 wait:500” will wait for 700 milliseconds.
                  The default (and minimum) value for -w is 20.
      -V          Show cliclick version number and release date
      -o          Open version history in a browser
      -n          Send a donation
    
    COMMANDS
    To use cliclick, you pass an arbitrary number of commands as arguments. A command consists of a command identifier (a string that tells cliclick what kind of action to perform) and usually one or more arguments to the command, which are separated from the command identifier with a colon. Example: “c:123,456” is the command for clicking (the “c” is the command identifier for clicking) at the position with x coordinate 123 and y coordinate 456. See below for a list of all commands and the arguments they expect.
    Whenever a command expects a pair of coordinates, you may provide relative values by prefixing the number with “+” or “-”. For example, “m:+50,+0” will move the mouse 50 pixels to the right. Of course, relative and absolute values can be mixed, and negative values are possible, so “c:100,-20” would be perfectly valid. (If you need to specify absolute negative values in case you have a setup with a second display arranged to the left of your main display, prefix the number with “=”, for instance “c:100,=-200”.)
    
    LIST OF COMMANDS
    
      rc:x,y  Will RIGHT-CLICK at the point with the given coordinates.
              Example: “rc:12,34” will right-click at the point with x coordinate
              12 and y coordinate 34. Instead of x and y values, you may
              also use “.”, which means: the current position. Using “.” is
              equivalent to using relative zero values “c:+0,+0”.
    
      m:x,y   Will MOVE the mouse to the point with the given coordinates.
              Example: “m:12,34” will move the mouse to the point with
              x coordinate 12 and y coordinate 34.
    
      kd:keys Will trigger a KEY DOWN event for a comma-separated list of
              modifier keys. Possible keys are:
                - alt
                - cmd
                - ctrl
                - fn
                - shift
              Example: “kd:cmd,alt” will press the command key and the
              option key (and will keep them down until you release them
              with another command)
    
      kp:key  Will emulate PRESSING A KEY (key down + key up). Possible keys are:
                - arrow-down
                - arrow-left
                - arrow-right
                - arrow-up
                - brightness-down
                - brightness-up
                - delete
                - end
                - enter
                - esc
                - f1
                - f2
                - f3
                - f4
                - f5
                - f6
                - f7
                - f8
                - f9
                - f10
                - f11
                - f12
                - f13
                - f14
                - f15
                - f16
                - fwd-delete
                - home
                - keys-light-down
                - keys-light-toggle
                - keys-light-up
                - mute
                - num-0
                - num-1
                - num-2
                - num-3
                - num-4
                - num-5
                - num-6
                - num-7
                - num-8
                - num-9
                - num-clear
                - num-divide
                - num-enter
                - num-equals
                - num-minus
                - num-multiply
                - num-plus
                - page-down
                - page-up
                - play-next
                - play-pause
                - play-previous
                - return
                - space
                - tab
                - volume-down
                - volume-up
              Example: “kp:return” will hit the return key.
    
      tc:x,y  Will TRIPLE-CLICK at the point with the given coordinates.
              Example: “tc:12,34” will triple-click at the point with x
              coordinate 12 and y coordinate 34. Instead of x and y values,
              you may also use “.”, which means: the current position.
              Note: If you find that this does not work in a target application,
              please try if double-clicking plus single-clicking does.
    
      ku:keys Will trigger a KEY UP event for a comma-separated list of
              modifier keys. Possible keys are:
                - alt
                - cmd
                - ctrl
                - fn
                - shift
              Example: “ku:cmd,ctrl” will release the command key and the
              control key (which will only have an effect if you performed
              a “key down” before)
    
      dm:x,y  Will continue the DRAG event to the given coordinates.
              Example: “dm:112,134” will drag and continue to the point with x
              coordinate 112 and y coordinate 134.
    
      c:x,y   Will CLICK at the point with the given coordinates.
              Example: “c:12,34” will click at the point with x coordinate
              12 and y coordinate 34. Instead of x and y values, you may
              also use “.”, which means: the current position. Using “.” is
              equivalent to using relative zero values “c:+0,+0”.
    
      dd:x,y  Will press down to START A DRAG at the given coordinates.
              Example: “dd:12,34” will press down at the point with x
              coordinate 12 and y coordinate 34. Instead of x and y values,
              you may also use “.”, which means: the current position.
    
      w:ms    Will WAIT/PAUSE for the given number of milliseconds.
              Example: “w:500” will pause command execution for half a second
    
      p[:str] Will PRINT the given string. If the string is “.”, the current
              MOUSE POSITION is printed. As a convenience, you can skip the
              string completely and just write “p” to get the current position.
              Example: “p:.” or “p” will print the current mouse position
              Example: “p:'Hello world'” will print “Hello world”
    
      du:x,y  Will release to END A DRAG at the given coordinates.
              Example: “du:112,134” will release at the point with x
              coordinate 112 and y coordinate 134.
    
      cp:str  Will PRINT THE COLOR value at the given screen location.
              The color value is printed as three decimal 8-bit values,
              representing, in order, red, green, and blue.
              Example: “cp:123,456” might print “127 63 0”
    
      dc:x,y  Will DOUBLE-CLICK at the point with the given coordinates.
              Example: “dc:12,34” will double-click at the point with x
              coordinate 12 and y coordinate 34. Instead of x and y values,
              you may also use “.”, which means: the current position.
    
      t:text  Will TYPE the given TEXT into the frontmost application.
              If the text includes space(s), it must be enclosed in quotes.
              Example: “type:Test” will type “Test” 
              Example: “type:'Viele Grüße'” will type “Viele Grüße”

Limitations
-----------
It is not possible to use cliclick before a user logs in, i.e.: to control the login window.


Building cliclick
-----------------
Either build in Xcode, as usual, or build from the shell by `cd`ing into the project directory and then invoking either `xcodebuild` or `make` (whatever you prefer). In either case, cliclick will not be installed, but you will simply get an executable called “cliclick” in the project directory which you can then move wherever you want to have it. (You can put it anywhere you like.) To install it to `/usr/local/bin`, you can also simply invoke `sudo make install`, which will do this for you.

Please note that while the code will run on OS X 10.9 and later, Base SDK and architectures selected in the Xcode project are set to the current SDK. Therefore, if you want to build for an older system, be sure to change these settings accordingly. If you have problems when building and get a message complaining about undefined symbols, chances are that this can be fixed by disabling “Implicitly link Objective-C Runtime Support” in the build settings.

Contributing
------------
If you would like to contribute a new feature, a bugfix or other improvement, please do so using a pull request. However, please take care that:

* There is one pull request per topic. I.e.: if you would like to contribute a new feature and two bugfixes, open three pull requests.
* All commit messages are in English.
* Ideally, all non-obvious features or changes should be shortly explained. This might not only include *what* you committed, but also *why* you did it (motivation, usage scenario, …). 
