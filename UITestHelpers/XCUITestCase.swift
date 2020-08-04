//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

open class XCUITestCase: XCTestCase {
    /// `XCUIApplication` instance to be used in the tests, ensures `--UITests` flag
    lazy open var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments += ["--UITests"]
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
            self.app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0001)).tap()
            retryCount -= 1
            sleep(1)
        }

        self.removeUIInterruptionMonitor(monitor)
    }

    // MARK: - Helpers

    /// Convenience method to tap any element
    /// - parameter identifier: The AccessibilityIdentifier of the button
    open func tapAny(_ identifier: String) {
        let element = self.app.descendants(matching: .any)[identifier]
        element.waitAndTap()
    }

    /// Convenience method to query any type of element
    ///
    /// Returns the first element matching the provided `identifier`.
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func element(with identifier: String) -> XCUIElement {
        let element = self.app.descendants(matching: .any)[identifier]
        guard element.exists else {
            fatalError("Element with identifier \(identifier) not found!")
        }

        return element
    }

    /// Convenience method to type text into a text field
    ///
    /// - parameter text: The string to be typed into the text field
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func typeText(_ text: String, into idenfitifer: String) {
        let textField = self.app.textFields[idenfitifer]
        self.typeText(text, into: textField)
    }

    /// Convenience method to type text into a secure text field
    ///
    /// - parameter text: The string to be typed into the secure text field
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func typeSecureText(_ text: String, into idenfitifer: String) {
        let secureTextField = self.app.secureTextFields[idenfitifer]
        self.typeText(text, into: secureTextField)
    }

    private func typeText(_ text: String, into element: XCUIElement) {
        element.waitAndTap()
        element.clearText()
        element.typeText(text)
    }

    /// Convenience method to retrieve text from a label
    ///
    /// Returns the text of the label
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func textFromLabel(_ identifier: String) -> String {
        let label = self.app.staticTexts[identifier]
        label.wait()
        return label.label
    }

    /// Convenience method to retrieve text from a button
    ///
    /// Returns the text of the label
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func textFromButton(_ identifier: String) -> String {
        let label = self.app.buttons[identifier]
        label.wait()
        return label.label
    }

    /// Convenience method to retrieve text from a text field
    ///
    /// Returns the text of the text field
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func textFromTextField(_ identifier: String) -> String {
        let textField = self.app.textFields[identifier]
        textField.wait()

        guard let text = textField.value as? String else {
            fatalError("TextField's value with identifier `\(identifier)` does not contain a String!")
        }
        return text
    }

    /// Convenience method to retrieve text from a secure text field
    ///
    /// Returns the text of the secure text field
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func textFromSecureTextField(_ identifier: String) -> String {
        let secureTextField = self.app.secureTextFields[identifier]
        secureTextField.wait()

        guard let text = secureTextField.value as? String else {
            fatalError("SecureTextField's value with identifier `\(identifier)` does not contain a String!")
        }
        return text
    }

    /// Convenience method to tap the navigation back button
    /// - warning: Actually it just taps the first button in the navigation bar ;-)
    open func tapBack() {
        self.app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    /// Convenience method to tap a button
    /// - parameter identifier: The AccessibilityIdentifier of the button
    open func tapButton(_ identifier: String) {
        let button = self.app.buttons[identifier].firstMatch
        button.waitAndTap()
    }

    /// Convenience method to tap on a `UIImageView`
    /// - parameter identifier: The AccessibilityIdentifier of the image
    open func tapImage(_ identifier: String) {
        let image = self.app.images[identifier].firstMatch
        image.waitAndTap()
    }

    /// Convenience method to tap on a cell
    /// - parameter identifier: The AccessibilityIdentifier of the cell
    open func tapCell(_ identifier: String) {
        let other = self.app.cells[identifier].firstMatch
        other.waitAndTap()
    }

    /// Convenience method to tap on any (other) element
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func tapOther(_ identifier: String) {
        let other = self.app.otherElements[identifier].firstMatch
        other.waitAndTap()
    }

    /// Convenience method to select picker values
    /// - parameter values: The values to be selected for each wheel, from left to right
    open func pickerSelect(values: String...) {
        for (index, value) in values.enumerated() {
            self.app.pickerWheels.element(boundBy: index).adjust(toPickerWheelValue: value)
        }
    }

    /// Convenience method to select a date in a date picker
    /// - parameter day: The day to be selected in the date picker
    /// - parameter month: The month to be selected in the date picker
    /// - parameter year: The year to be selected in the date picker
    /// Credits: https://stackoverflow.com/a/47956278/2019384
    open func datePickerSelect(day: String, month: String, year: String) {
        let dateComponent = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthText = formatter.string(from: Date())

        self.app.pickerWheels[String(dateComponent.year!)].adjust(toPickerWheelValue: year)
        self.app.pickerWheels[monthText].adjust(toPickerWheelValue: month)
        self.app.pickerWheels[String(dateComponent.day!)].adjust(toPickerWheelValue: day)
    }

    /// Convenience method to tap on a `UIBarButtonItem`
    /// - parameter identifier: The AccessibilityIdentifier of the button
    open func tapPickerButton(index: Int = 0) {
        let pickerSubmitButton = self.app.toolbars.buttons.element(boundBy: index)
        pickerSubmitButton.waitAndTap()
    }

    /// Scroll to a `UITableViewCell`
    /// - parameter cellIdentifier: The AccessibilityIdentifier of the `UITableViewCell`
    /// - parameter tableViewIdentifier: The AccessibilityIdentifier of the `UITableView`
    /// - parameter scrollDirection: Which direction to scroll and how large each "scroll step" should be.
    open func scrollToTableViewCell(_ cellIdentifier: String, in tableViewIdentifier: String, scrollDirection: XCUIElement.ScrollDirection = .down(250)) {
        let tableView = self.app.tables[tableViewIdentifier]
        let cell = tableView.cells.matching(identifier: cellIdentifier).element(boundBy: 0)
        tableView.scrollToElement(element: cell, scrollDirection: scrollDirection)
    }

    /// Scroll to a `UITableViewCell` and tap it
    /// - parameter cellIdentifier: The AccessibilityIdentifier of the `UITableViewCell`
    /// - parameter tableViewIdentifier: The AccessibilityIdentifier of the `UITableView`
    /// - parameter scrollDirection: Which direction to scroll and how large each "scroll step" should be.
    open func tapTableViewCell(_ cellIdentifier: String, in tableViewIdentifier: String, scrollDirection: XCUIElement.ScrollDirection = .down(250)) {
        let tableView = self.app.tables[tableViewIdentifier]
        let cell = tableView.cells.matching(identifier: cellIdentifier).element(boundBy: 0)
        tableView.scrollToElement(element: cell, scrollDirection: scrollDirection)
        cell.tap()
    }

    /// Scroll to a `UICollectionViewCell`
    /// - parameter cellIdentifier: The AccessibilityIdentifier of the `UICollectionViewCell`
    /// - parameter collectionViewIdentifier: The AccessibilityIdentifier of the `UICollectionView`
    /// - parameter scrollDirection: Which direction to scroll and how large each "scroll step" should be.
    open func scrollToCollectionViewCell(_ cellIdentifier: String, in collectionViewIdentifier: String, scrollDirection: XCUIElement.ScrollDirection = .down(250)) {
        let collectionView = self.app.collectionViews[collectionViewIdentifier]
        let cell = collectionView.cells.matching(identifier: cellIdentifier).element(boundBy: 0)
        collectionView.scrollToElement(element: cell, scrollDirection: scrollDirection)
    }

    /// Scroll to a `UICollectionViewCell` and tap it
    /// - parameter cellIdentifier: The AccessibilityIdentifier of the `UICollectionViewCell`
    /// - parameter collectionViewIdentifier: The AccessibilityIdentifier of the `UICollectionView`
    /// - parameter scrollDirection: Which direction to scroll and how large each "scroll step" should be.
    open func tapCollectionViewCell(_ cellIdentifier: String, in collectionViewIdentifier: String, scrollDirection: XCUIElement.ScrollDirection = .down(250)) {
        let collectionView = self.app.collectionViews[collectionViewIdentifier]
        let cell = collectionView.cells.matching(identifier: cellIdentifier).element(boundBy: 0)
        collectionView.scrollToElement(element: cell, scrollDirection: scrollDirection)
        cell.tap()
    }
}
