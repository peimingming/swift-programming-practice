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
    }
}
