CC = cc
# Set deployment target for backwards compatibility and universal binary support
CFLAGS = -mmacosx-version-min=10.15 -arch x86_64 -arch arm64 \
         -include cliclick_Prefix.pch -I Actions -I . \
         -Wno-deprecated-declarations -Wno-unguarded-availability-new
# Linker flags for universal binary
LDFLAGS = -mmacosx-version-min=10.15 -arch x86_64 -arch arm64

all: macros cliclick

macros:
	./generate-action-classes-macro.sh

cliclick: Actions/ClickAction.o \
          Actions/ColorPickerAction.o \
          Actions/DoubleclickAction.o \
          Actions/DragDownAction.o \
          Actions/DragUpAction.o \
          Actions/DragMoveAction.o \
          Actions/KeyBaseAction.o \
          Actions/KeyDownAction.o \
          Actions/KeyDownUpBaseAction.o \
          Actions/KeyPressAction.o \
          Actions/KeyUpAction.o \
          Actions/MouseBaseAction.o \
          Actions/MoveAction.o \
          Actions/PrintAction.o \
          Actions/RightClickAction.o \
          Actions/TripleclickAction.o \
          Actions/TypeAction.o \
          Actions/WaitAction.o \
          Actions/ScreenCaptureCompat.o \
          ActionExecutor.o \
          KeycodeInformer.o \
          OutputHandler.o \
          cliclick.o
	$(CC) $(LDFLAGS) -o cliclick $^ -framework Cocoa -framework Carbon -framework ScreenCaptureKit

install: macros cliclick
	cp cliclick /usr/local/bin/

clean:
	$(RM) -v ActionClassesMacro.h
	$(RM) -v *.o Actions/*.o
	$(RM) -vr cliclick
