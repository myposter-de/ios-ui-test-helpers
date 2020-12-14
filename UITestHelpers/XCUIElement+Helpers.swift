//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

public extension XCUIElement {
    /**
     Tries to iterativley scroll to the provided element. Must be used on a `UIScrollView` ;-)

         // Example:
         let collectionView = self.app.collectionViews.element(boundBy: 0)
         self.wait(for: collectionView)
         let cell = collectionView.cells.element(boundBy: 42)
         collectionView.scrollToElement(element: cell)

     - parameter element: The element to look for.
     - parameter scrollDirection: Which direction to scroll and how large each "scroll step" should be.
     */
    func scrollToElement(element: XCUIElement, scrollDirection: ScrollDirection = .down(250.0)) {
        while !(element.waitForExistence(timeout: 1) && element.isHittable) {
            let startCoord = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(scrollDirection.vector)
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }

    /// Returns the center coordinate of the element.
    var center: XCUICoordinate {
        let frame = self.frame.size
        let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let centerOfElement = coordinate.withOffset(CGVector(dx: frame.width / 2, dy: frame.height / 2))
        return centerOfElement
    }

    /// Waits for the element to be existent
    /// - parameter timeout: Maximum time to wait for the element
    func wait(for timeout: TimeInterval = 15) {
        guard self.waitForExistence(timeout: timeout) else {
            XCTFail("Timeout: Element `\(self)` did come into existence after waiting for \(timeout) seconds.")
            return
        }
    }

    /// Waits for the element to be existent and then taps it
    /// - parameter timeout: Maximum time to wait for the element
    func waitAndTap(for timeout: TimeInterval = 15) {
        self.wait(for: timeout)
        self.tap()
    }

    /// Clears the text on any element that can `typeText` like text fields.
    /// Credits: https://exceptionshub.com/ui-test-deleting-text-in-text-field.html
    func clearText() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        let deleteString = stringValue.map { _ in XCUIKeyboardKey.delete.rawValue }.joined(separator: "")
        self.typeText(deleteString)
    }
}

public extension XCUIElement {
    enum ScrollDirection {
        case up(CGFloat)
        case down(CGFloat)
        case left(CGFloat)
        case right(CGFloat)

        var vector: CGVector {
            switch self {
            case .down(let offset): return CGVector(dx: 0.0, dy: -offset)
            case .up(let offset): return CGVector(dx: 0.0, dy: offset)
            case .left(let offset): return CGVector(dx: offset, dy: 0.0)
            case .right(let offset): return CGVector(dx: -offset, dy: 0.0)
            }
        }
    }
}
