PROJECT := Filebox.xcodeproj
SCHEME := Filebox
DERIVED_DATA := .build
APP := $(DERIVED_DATA)/Build/Products/Debug/Filebox.app
XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -derivedDataPath $(DERIVED_DATA)

.PHONY: generate build test run clean

build: generate
	$(XCODEBUILD) -configuration Debug build

generate:
	xcodegen generate

test: generate
	$(XCODEBUILD) test

run: build
	pkill -x Filebox || true
	while pgrep -x Filebox > /dev/null; do sleep 0.1; done
	open $(APP)

clean:
	rm -rf $(DERIVED_DATA) $(PROJECT)
