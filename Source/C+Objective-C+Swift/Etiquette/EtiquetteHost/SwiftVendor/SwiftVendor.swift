//  Copyright © 2020 Eric M M PEI. All rights reserved.

import Foundation

class SwiftVendor: NSObject {
    @objc func sayHello() {
        printLog("Hello from SwiftVendor")
    }
    
    @objc func sayHowdy() {
        printLog("Howdy from SwiftVendor")
    }
    
    @objc func sayMorning() {
        printLog("Good morning from SwiftVendor")
    }
}
