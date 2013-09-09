cliclick Overview
=========================

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
 
ctrl
cmd
alt
return
esc
tab
space
a
s
d
f
h
g
z
x
c
v
b 
q 
w 
e 
r 
y 
t 
1 
2 
3 
4 
6 
5 
= 
9 
7 
- 
8 
0 
] 
o 
u 
[ 
i 
p 
l 
j 
' 
k 
; 
\, 
, 
/ 
n 
m 
. 
\\`
delete
.
*
+
CLEAR
/
-
=
0
1
2
3", 
4", 
5", 
6", 
7", 
8", 
9", 
F5", 
F6", 
F7", 
F3", 
F8", 
F9", 
F11", 
F13", 
F14", 
F10", 
F12", 
F15", 
help", 
home", 
pgup", 
delete", 
F4", 
end", 
F2", 
pgdown", 
F1", 
left", 
right", 
down", 

