//  Copyright © 2020 Eric M M PEI. All rights reserved.

import Foundation

@objcMembers
public class SwiftVendorInFramework: NSObject {
    public func sayHello() {
        printLog("Hello from SwiftVendorInFramework")
    }
    
    public func sayHowdy() {
        printLog("Howdy from SwiftVendorInFramework")
    }
    
    public func sayMorning() {
        printLog("Good morning from SwiftVendorInFramework")
    }
}
