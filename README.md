# UITestHelpers
[![CocoaPods](https://img.shields.io/cocoapods/v/UITestHelpers.svg?colorB=00aff0)](https://cocoapods.org/pods/UITestHelpers)
[![Platforms](https://img.shields.io/badge/platforms-iOS-00aff0.svg)](https://www.apple.com/lae/ios)
[![License](https://img.shields.io/badge/License-Apache%202.0-00AFF0.svg)](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/LICENSE)

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

## Usage / Examples

```swift
class MyUITests: XCUITestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        self.addAlertsHandler(for: ["Allow", "OK"])
        self.app.launchEnvironment = ["AutoCorrection": "Disabled"]
        self.app.launch()
    }

    func testSomething() {
        // tap an element (it's important to wait for an element to exist, before tapping it)
        element.waitAndTap()

        // tap a button
        self.tapButton("buttonAccessibilityIdentifier")

        // tap a cell in a collectionView (scroll to the right, if needed)
        self.tapCollectionViewCell("collectionViewCellAccessibilityIdentifier", in: "collectionViewAccessibilityIdentifier", scrollDirection: .right(100))

        // handle (dismiss) permission alerts
        self.addAlertsHandler(for: ["Allow", "OK"])

        // tap the "Continue" button on the next alert dialog
        self.tapAlertButton(name: "Continue")

        // show keyboard
        self.app.showKeyboard(for: self)

        // really type on the keyboard (sometimes this is needed in contrast to `XCUIElement.typeText`)
        self.app.typeOnKeyboard(text: "1337")

        // hide keyboard
        self.app.hideKeyboard()
    }
}
```

## Reliability

### Using `accessibilityIdentifier`s

To get reliable results from your tests, it's recommended, to use `accessibilityIdentifier`s, wherever possible.
For static stuff you can just set them right in Interface Builder:

![](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/Docs/IBAccessibilityIdentifier.png)

Or if the element does not have an `Accessibility` section, using `User Defined Runtime Attributes`:

![](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/Docs/IBAccessibilityIdentifierAlternative.png)

For dynamic stuff however, you'll have to set it in code. Some may consider this a kind of clutter to have test-only stuff in the code base, but as it's really just a one-liner in e.g. a `UITableViewCell`. And I would really take "this clutter" anytime over less reliable UI tests (e.g. when using indices instead). 
E.g.:
```swift
let dynamic = "somethingSpecificToThisCell"
self.accessibilityIdentifier = "your\(dynamic)IdentifierHere"
```

### How to ensure a clean app state for each test

As Apple doesn't provide a way to really clean the app state for each test, we'll have to do it manually by providing our own "main function".
For that we'll use a launch argument like `--Reset` that we'll pass to our `XCUIApplication` in our tests setup (see `XCUITestCase` base class).

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

## Trouble shooting

### The software keyboard is not showing up

#### Xcode 10+

```swift
func disableHardwareKeyboard() {
    let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
    UITextInputMode.activeInputModes
        .filter({ $0.responds(to: setHardwareLayout) })
        .forEach { $0.perform(setHardwareLayout, with: nil) }
}
```

#### Xcode 9-

Make sure the hardware keyboard is disconnected.
- Pressing `cmd` + `shift` + `k` in the simulator will toggle the hardware keyboard
- Even better: Disable it in a `Build Phase` script, **in your UI tests target**, like follows, to ensure this for each test run:
```shell
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool NO
```

![](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/Docs/BuildPhase.png)

### Debugging

#### Xcode's `Debug View Hierarchy` feature

Here you can see all the accessibility information for an element.

![](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/Docs/XcodeDebugViewHierarchy.png)

#### Accessibility Inspector

Use this nice app (inclued in Xcode's Developer Tools) to inspect the app in a simulator, and get accessibility information as well as the hierarchy of the element.

![](https://github.com/myposter-de/ios-ui-test-helpers/blob/master/Docs/AccessibilityInspector.png)

## Credits

- [Resetting iOS Simulator for UI tests][1]
- [Scroll until element is visible iOS UI Automation with xcode7][2]
- [Is it possible to “toggle software keyboard” via the code in UI test?][3]


[1]: https://m.pardel.net/resetting-ios-simulator-for-ui-tests-cd7fff57788e
[2]: https://stackoverflow.com/questions/32646539/scroll-until-element-is-visible-ios-ui-automation-with-xcode7
[3]: https://stackoverflow.com/a/57618331/2019384
