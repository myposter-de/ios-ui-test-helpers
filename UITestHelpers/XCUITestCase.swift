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

    /// Convenience method to tap any kind of element
    ///
    /// Will go through any type available, and pick the first one matching the provided `identifier`.
    /// For performance reasons, the list is more or less sorted form more popular types to less ones.
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func tapAny(_ identifier: String) {
        let queries = [
            self.app.buttons,
            self.app.cells,
            self.app.images,
            self.app.otherElements,
            self.app.navigationBars,
            self.app.tabBars,
            self.app.collectionViews,
            self.app.tables,
            self.app.tableRows,
            self.app.tableColumns,
            self.app.sliders,
            self.app.pickers,
            self.app.pickerWheels,
            self.app.toolbarButtons,
            self.app.toolbars,
            self.app.touchBars,
            self.app.groups,
            self.app.windows,
            self.app.sheets,
            self.app.drawers,
            self.app.alerts,
            self.app.dialogs,
            self.app.radioButtons,
            self.app.radioGroups,
            self.app.checkBoxes,
            self.app.disclosureTriangles,
            self.app.popUpButtons,
            self.app.comboBoxes,
            self.app.menuButtons,
            self.app.popovers,
            self.app.keyboards,
            self.app.keys,
            self.app.tabGroups,
            self.app.statusBars,
            self.app.outlines,
            self.app.outlineRows,
            self.app.disclosedChildRows,
            self.app.browsers,
            self.app.pageIndicators,
            self.app.progressIndicators,
            self.app.activityIndicators,
            self.app.segmentedControls,
            self.app.switches,
            self.app.toggles,
            self.app.links,
            self.app.icons,
            self.app.searchFields,
            self.app.scrollViews,
            self.app.scrollBars,
            self.app.staticTexts,
            self.app.textFields,
            self.app.secureTextFields,
            self.app.datePickers,
            self.app.textViews,
            self.app.menus,
            self.app.menuItems,
            self.app.menuBars,
            self.app.menuBarItems,
            self.app.maps,
            self.app.webViews,
            self.app.steppers,
            self.app.incrementArrows,
            self.app.decrementArrows,
            self.app.tabs,
            self.app.timelines,
            self.app.ratingIndicators,
            self.app.valueIndicators,
            self.app.splitGroups,
            self.app.splitters,
            self.app.relevanceIndicators,
            self.app.colorWells,
            self.app.helpTags,
            self.app.mattes,
            self.app.dockItems,
            self.app.rulers,
            self.app.rulerMarkers,
            self.app.grids,
            self.app.levelIndicators,
            self.app.layoutAreas,
            self.app.layoutItems,
            self.app.handles,
            self.app.statusItems
        ]

        for query in queries {
            let element = query[identifier]
            if element.exists {
                element.tap()
                break
            }
        }
    }

    /// Convenience method to tap the navigation back button
    /// - warning: Actually it just taps the first button in the navigation bar ;-)
    open func tapBack() {
        self.app.navigationBars.buttons.element(boundBy: 0).tap()
    }

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

    /// Convenience method to tap on a cell
    /// - parameter identifier: The AccessibilityIdentifier of the cell
    open func tapCell(_ identifier: String) {
        let other = self.app.cells[identifier]
        other.waitAndTap()
    }

    /// Convenience method to tap on any (other) element
    /// - parameter identifier: The AccessibilityIdentifier of the element
    open func tapOther(_ identifier: String) {
        let other = self.app.otherElements[identifier]
        other.waitAndTap()
    }

    /// Convenience method to tap on a `UIBarButtonItem`
    /// - parameter identifier: The AccessibilityIdentifier of the button
    open func tapPickerSubmitButton() {
        let pickerSubmitButton = self.app.toolbars.buttons.element(boundBy: 0)
        pickerSubmitButton.tap()
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
