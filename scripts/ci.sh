#!/usr/bin/env bash

set -e

xcodebuild -project CheatyXML.xcodeproj -scheme "CheatyXML" -destination "platform=iOS Simulator,name=iPhone 6" test