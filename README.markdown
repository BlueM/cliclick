cliclick Overview
=========================
Just bumped version to 10.7 sdk so it works on a recent xcode version (otherwise you need to download the 10.5.sdk).
xcodebuild now also works from command line with xcode 4.6.3 and puts the binary somewhere in build/Release directory.

cliclick (short for “Command Line Interface Click”) is a tool for executing mouse- and keyboard-related actions from the shell/Terminal. It is written in Objective-C and runs on Mac OS X 10.5 or later, including OS X 10.8.

For more information, please take a look at [cliclick’s homepage](http://www.bluem.net/jump/cliclick/)

Added makefile. Just clone this repo and do:
make -> builds cliclick
make install -> builds + installs cliclick in /usr/local/bin
make clean -> cleans up removes all binary files

Author: Carsten Blüm, Website: www.bluem.net 
Contributer: Walter Schreppers.

Added Makefile and extended the KeyBaseAction class. It used to only support cmd, enter, esc but in this version we basically added most
known keycodes (space, arrows up down left right, function keys etc.). Here's the full list of supported keys now:
``` 
ctrl,cmd,alt,return,esc,tab,space,a,s,d,f,h,g,z,x,c,v,b ,q ,w ,e ,r ,y ,t ,1 ,2 ,3 ,4 ,6 ,5 ,= ,9 ,7 ,- ,8 ,0 ,] ,o ,u ,[ ,i ,p ,l 
,j ,' ,k ,; ,\,,/ ,n ,m ,. ,\\`,delete,.,*,+,CLEAR, /,-,=, 0,1,2,3,4,5,6,7,8,9,
F5,F6,F7,F3,F8,F9,F11,F13,F14,F10,F12,F15,help,home,pgup,delete,F4,end,F2,pgdown,F1,left,right,down
```

You now have make, make install and make clean available:
```
Walters-MacBook-Pro:cliclick wschrep$ make install
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/ClickAction.o Actions/ClickAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/DoubleclickAction.o Actions/DoubleclickAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/KeyBaseAction.o Actions/KeyBaseAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/KeyDownAction.o Actions/KeyDownAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/KeyPressAction.o Actions/KeyPressAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/KeyUpAction.o Actions/KeyUpAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/MouseBaseAction.o Actions/MouseBaseAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/MoveAction.o Actions/MoveAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/PrintAction.o Actions/PrintAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/TripleclickAction.o Actions/TripleclickAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o Actions/WaitAction.o Actions/WaitAction.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o ActionExecutor.o ActionExecutor.m
cc  -include cliclick_Prefix.pch -I Actions   -c -o cliclick.o cliclick.m

gcc -o cliclick Actions/ClickAction.o Actions/DoubleclickAction.o Actions/KeyBaseAction.o Actions/KeyDownAction.o Actions/KeyPressAction.o Actions/KeyUpAction.o Actions/MouseBaseAction.o Actions/MoveAction.o Actions/PrintAction.o Actions/TripleclickAction.o Actions/WaitAction.o ActionExecutor.o cliclick.o -framework Cocoa
cp cliclick /usr/local/bin/
Walters-MacBook-Pro:cliclick wschrep$ 
```
