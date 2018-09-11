//
//  Copyright © 2018 myposter GmbH. All rights reserved.
//

import XCTest

// https://stackoverflow.com/questions/32646539/scroll-until-element-is-visible-ios-ui-automation-with-xcode7
public extension XCUIElement {
    func scrollToElement(element: XCUIElement, scrollDirection: ScrollDirection = .down) {
        while !(element.exists && element.isHittable) {
            let startCoord = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(scrollDirection.vector)
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }

    var center: XCUICoordinate {
        let frame = self.frame.size
        let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let centerOfElement = coordinate.withOffset(CGVector(dx: frame.width / 2, dy: frame.height / 2))
        return centerOfElement
    }
}

public extension XCUIElement {
    enum ScrollDirection {
        case up
        case down
        case left
        case right

        var vector: CGVector {
            switch self {
            case .down: return CGVector(dx: 0.0, dy: -262.0)
            case .up: return CGVector(dx: 0.0, dy: 262.0)
            case .left: return CGVector(dx: 262.0, dy: 0.0)
            case .right: return CGVector(dx: -262.0, dy: 0.0)
            }
        }
    }
}
