//  Copyright © 2020 Eric M M PEI. All rights reserved.

public protocol Greeting {
    func sayHello()
    func sayHowdy()
    func sayMorning()
    func sayOCVendorWords()
}

public struct GreetingFactory {
    public static func makeGreeter() -> Greeting { Greeter() }
}

struct Greeter {
    init() {}
}

extension Greeter: Greeting {
    func sayHello() {
        printLog("Hello")
    }
    
    func sayHowdy() {
        printLog("Howdy")
    }
    
    func sayMorning() {
        printLog("Good morning")
    }
    
    func sayOCVendorWords() {
        printLog("\n--- [Framework] Import Objective-C into Swift ---")
        let ocVendor = OCVendorInFramework()
        ocVendor.sayHello()
        ocVendor.sayHowdy()
        ocVendor.sayMorning()
        ocVendor.saySwiftVendorWords()
    }
}
