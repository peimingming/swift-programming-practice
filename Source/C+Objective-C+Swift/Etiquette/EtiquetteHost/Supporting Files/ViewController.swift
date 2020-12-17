//  Copyright © 2020 Eric M M PEI. All rights reserved.

import UIKit
import Etiquette

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let greeter = GreetingFactory.makeGreeter()
        greeter.sayHello()
        greeter.sayHowdy()
        greeter.sayMorning()
        greeter.sayOCVendorWords()
        
        printLog("\n--- [Host] Import Objective-C into Swift ---")
        let ocVendor = OCVendor()
        ocVendor.sayHello()
        ocVendor.sayHowdy()
        ocVendor.sayMorning()
        ocVendor.saySwiftVendorWords()
        
        printLog("\n--- [Host] Import C into Swift ---")
        let a: Int32 = 10
        let b: Int32 = 20
        let result = swiftSum(a, b)
        printLog(result)
    }
}

// Rename the C function "sum" defined in the file CVendor.c as "swiftSum".
@_silgen_name("sum") func swiftSum(_ v1: Int32, _ v2: Int32) -> Int32

func sum(_ v1: Int32, _ v2: Int32) -> Int32 {
    printLog("sum defined in Swift.")
    return v1 + v2
}
