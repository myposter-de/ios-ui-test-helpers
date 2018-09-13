//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

public extension XCUIApplication {
    /**
     Presents the keyboard
     - note: If keyboard is not showing up, disable HW-Keyboard in `Terminal` or `Build Phases` (for reliability):


         defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool NO

     - parameter testCase: The current `XCTestCase` instance aka `self`, in order to be able to wait for the keyboard to actually show up.
    */
    func showKeyboard(for testCase: XCTestCase) {
        self.keyboards.element.wait()
    }

    /// Dismisses the keyboard
    /// - todo: Does this also work for multiline input fields? 0_o
    func hideKeyboard() {
        self.typeText("\n")
    }

    /// Types the provided `String`, `Character` by `Character` on the current keyboard.
    /// In contrast to `XCUIElement.typeText` this doesn't just fill the text (e.g. into a `UITextField`), but actually presses the keyboards buttons.
    /// - parameter text: Text to be typed on the keyboard
    func typeOnKeyboard(text: String) {
        text.forEach { char in
            self.keyboards.keys[String(char)].tap()
        }
    }
}
