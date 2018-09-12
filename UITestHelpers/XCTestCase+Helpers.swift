//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

public extension XCTestCase {
    /**
     Waits for an `XCUIElement` to be existent. It often is necessary to wait for an element in order to be able to (reliably) interact with it.

     - parameter element: the element to wait for
     - parameter timeInterval: how long to wait for the element to become existent/hittable
     - parameter hitTest: whether the element requires to be hittable
     */
    func wait(for element: XCUIElement, for timeInterval: TimeInterval = 15, hitTest: Bool = false) {
        let predicate = hitTest ? NSPredicate(format: "exists == true && isHittable == true") : NSPredicate(format: "exists == true")
        self.expectation(for: predicate, evaluatedWith: element, handler: nil)
        self.waitForExpectations(timeout: timeInterval, handler: nil)
    }
}
