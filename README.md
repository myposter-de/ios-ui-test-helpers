# UITestHelpers
![pod](https://img.shields.io/cocoapods/v/UITestHelpers.svg) ![platforms](https://img.shields.io/badge/platforms-iOS-00AFF0.svg) [![License](https://img.shields.io/badge/License-Apache%202.0-00AFF0.svg)](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/LICENSE)

A collection of useful helper functions to make writing UI tests at least a little bit less painful.

## Installation

### CocoaPods

You can install UITestHelpers by adding them to your UI tests section in your Podfile:
```ruby
platform :ios, '10.0'
use_frameworks!

target '<name-of-your-UI-tests-target>' do
  pod 'UITestHelpers'
end
```

Then run `pod install`.

### Manually

Of course you can just drag the source files into your project, but using CocoaPods is really the recommended way of using UITestHelpers.

## Usage

TODO

## Reliability / Improvements / Trouble shooting

### Ensure a clean app state for each test

As Apple doesn't provide a way to really clean the app state for each test, we'll have to do it manually by providing our own "main function".
For that we'll use a launch argument like `--Reset` that we'll pass to our `XCUIApplication` in our tests setup (see below).

- Remove the `@UIApplicationMain` annotation from your AppDelegate.
- Create a `main.swift` file in your project with following content:
```swift
_ = autoreleasepool {
    if ProcessInfo().arguments.contains("--Reset") {
        // Delete files, whatever...
    }

    UIApplicationMain(
        CommandLine.argc,
        UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to:
            UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)),
        nil,
        NSStringFromClass(AppDelegate.self)
    )
}
```

See also [Resetting iOS Simulator for UI tests][1].

### The software keyboard is not showing up

Make sure the hardware keyboard is disconnected.
- Pressing `cmd` + `shift` + `k` in the simulator will toggle the hardware keyboard
- Even better: Disable it in a `Build Phase` script, **in your UI tests target**, like follows, to ensure this for each test run:
```shell
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool NO
```

## Credits

- [Resetting iOS Simulator for UI tests][1]
- [Scroll until element is visible iOS UI Automation with xcode7][2]


[1]: https://m.pardel.net/resetting-ios-simulator-for-ui-tests-cd7fff57788e
[2]: https://stackoverflow.com/questions/32646539/scroll-until-element-is-visible-ios-ui-automation-with-xcode7
