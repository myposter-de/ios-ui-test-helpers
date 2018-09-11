//
//  Copyright © 2017 myposter GmbH. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func wait(for element: XCUIElement, for timeInterval: TimeInterval = 15, hitTest: Bool = false) {
        let predicate = hitTest ? NSPredicate(format: "exists == true && isHittable == true") : NSPredicate(format: "exists == true")
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeInterval, handler: nil)
    }

    // If keyboard is not showing up, disable HW-Keyboard => `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool NO`
    func showKeyboard(for app: XCUIApplication) {
        wait(for: app.keyboards.element)
    }

    func hideKeyboard(for app: XCUIApplication) {
        app.typeText("\n")
    }
}
