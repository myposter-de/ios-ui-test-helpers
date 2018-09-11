//
//  Copyright © 2017 myposter GmbH. All rights reserved.
//

import XCTest

public extension XCUIApplication {
    func typeOnKeyboard(text: String) {
        text.forEach { char in
            self.keyboards.keys[String(char)].tap()
        }
    }
}
