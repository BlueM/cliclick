# Makefile for cliclick by Walter Schreppers
# Just run 
# make -> to create cliclick executable no x-code needed only the command line tools!
# make clean -> clean everything
# sudo make install -> build + install in /usr/local/bin

CC = cc 
CFLAGS = -include cliclick_Prefix.pch -I Actions

cliclick: Actions/ClickAction.o Actions/DoubleclickAction.o Actions/KeyBaseAction.o Actions/KeyDownAction.o Actions/KeyPressAction.o Actions/KeyUpAction.o Actions/MouseBaseAction.o Actions/MoveAction.o Actions/PrintAction.o Actions/TripleclickAction.o Actions/WaitAction.o ActionExecutor.o cliclick.o
	gcc -o cliclick $^ -framework Cocoa

install: cliclick
	cp cliclick /usr/local/bin/

clean:
	@rm -vf *.o Actions/*.o *~
	@rm -vf cliclick
