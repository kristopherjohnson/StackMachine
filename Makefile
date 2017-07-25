all:
	xcodebuild -alltargets

test:
	xcodebuild test -scheme StackMachine

clean:
	$(RM) -rf build

.PHONY: all test clean

