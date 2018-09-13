//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

open class XCUITestCase: XCTestCase {
    /// `XCUIApplication` instance to be used in the tests, ensures `--Reset` flag
    lazy open var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments += ["--Reset"]
        return app
    }()

    // MARK: - Alert handling

    /// Registers a handler for general alerts (like permissions)
    /// - parameter names: Names/captions of the buttons to press, when alerts pop up
    open func addAlertsHandler(for names: [String]) {
        self.addUIInterruptionMonitor(withDescription: "handle general alerts") { (alerts) -> Bool in
            for name in names {
                let button = alerts.buttons[name]
                if button.exists {
                    button.tap()
                    return true
                }
            }
            return false
        }
    }

    /// Waits for an alert to appear, then presses the desired button
    /// - parameter name: Name/caption of the button to press, once the alert appeared
    /// - parameter timeout: How long to wait for the alert to appear
    open func tapAlertButton(name: String, timeout: TimeInterval = 15) {
        var retryCount = timeout

        let monitor = self.addUIInterruptionMonitor(withDescription: "handle specific alert") { (alerts) -> Bool in
            retryCount = 0

            let button = alerts.buttons[name]
            if button.exists {
                button.tap()
                return true
            }

            return false
        }

        // Note the handler above only gets called, once there was a user interaction in the app
        // -> so we need to tap around, until the alert is present, to trigger the handler 0_o
        while retryCount > 0 {
            sleep(1)
            self.app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 60)).tap()
            retryCount -= 1
        }

        self.removeUIInterruptionMonitor(monitor)
    }

    // MARK: - Helpers

    /// Convenience method to tap a button
    /// - parameter identifier: The AccessibilityIdentifier of the button
    open func tapButton(_ identifier: String) {
        let button = self.app.buttons[identifier]
        button.waitAndTap()
    }

    /// Convenience method to tap on a `UIImageView`
    /// - parameter identifier: The AccessibilityIdentifier of the image
    open func tapImage(_ identifier: String) {
        let image = self.app.images[identifier]
        image.waitAndTap()
    }

    open func tapPickerSubmitButton() {
        let pickerSubmitButton = self.app.toolbars.buttons.element(boundBy: 0)
        pickerSubmitButton.tap()
    }

    open func tapCollectionViewCell(_ cellIdentifier: String, in collectionViewIdentifier: String, scrollDirection: XCUIElement.ScrollDirection = .down(250)) {
        let collectionView = self.app.collectionViews[collectionViewIdentifier]
        let cell = collectionView.cells.matching(identifier: cellIdentifier).element(boundBy: 0)
        collectionView.scrollToElement(element: cell, scrollDirection: scrollDirection)
        cell.tap()
    }
}
