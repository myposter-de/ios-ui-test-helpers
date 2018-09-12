//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

class XCUITestCase: XCTestCase {
    var app: XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["AutoCorrection": "Disabled"]
        app.launchArguments += ["--Reset"]
        return app
    }

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        self.addDefaultPopupHandler()
    }

    private func addDefaultPopupHandler() {
        addUIInterruptionMonitor(withDescription: "handle popups") { (alerts) -> Bool in
            // e.g. PN Permission
            let allowButton = alerts.buttons["Allow"]
            if allowButton.exists {
                allowButton.tap()
                return true
            }

            // e.g. Photos Permission
            let okButton = alerts.buttons["OK"]
            if okButton.exists {
                okButton.tap()
                return true
            }

            // e.g. Photobox Permission
            let doneButton = alerts.buttons["Fertig"]
            if doneButton.exists {
                doneButton.tap()
                return true
            }

            return false
        }
    }

    // MARK: - Helpers

    func tapCollectionViewCell(at index: Int, assertSelected: Bool) {
        let cell = self.app.collectionViews.cells.element(boundBy: index)
        self.tapElement(cell)

        if assertSelected {
            XCTAssertTrue(cell.isSelected)
        }
    }

    func tapDisclosureIndicatorOnCell(at index: Int) {
        let cell = self.app.cells.element(boundBy: index)
        let disclosureIndicator = cell.descendants(matching: .button).element(boundBy: 2)
        self.tapCenterOfElement(disclosureIndicator)
    }

    func tapButton(_ name: String) {
        let button = self.app.buttons[name]
        self.tapElement(button)
    }

    func tapImage(_ name: String) {
        let image = self.app.images[name]
        self.tapElement(image)
    }

    func tapElement(_ element: XCUIElement) {
        self.wait(for: element)
        element.tap()
    }

    func tapCoordinates(of element: XCUIElement) {
        self.wait(for: element)
        element.center.tap()
    }

    func tapCenterOfElement(_ element: XCUIElement) {
        self.wait(for: element)
        element.center.tap()
    }

    func picker_tapSubmitButton() {
        let pickerSubmitButton = self.app.toolbars.buttons.element(boundBy: 0)
        pickerSubmitButton.tap()
    }

    func selectCollectionViewCell(_ name: String, in collectionView: String) {
        let collectionView = self.app.collectionViews[collectionView]
        let cell = collectionView.cells.matching(identifier: name).element(boundBy: 0)
        collectionView.scrollToElement(element: cell)
        cell.tap()
    }

    /// Waits until `timeout`, for an alert to appear and presses the button titled `name`
    /// - parameter name:
    func alert_tapButton(name: String, timeout: TimeInterval = 15) {
        var retryCount = timeout

        self.addUIInterruptionMonitor(withDescription: "handle paypal popup") { (alerts) -> Bool in
            retryCount = 0

            let button = alerts.buttons[name]
            if button.exists {
                button.tap()
                return true
            }

            return false
        }

        // Note the handler above only gets called, once there was a user interaction in the app (so we need to tap around, until the popup is present, to trigger the handler 0_o)
        while retryCount > 0 {
            sleep(1)
            self.app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 60)).tap()
            retryCount -= 1
        }
    }
}
