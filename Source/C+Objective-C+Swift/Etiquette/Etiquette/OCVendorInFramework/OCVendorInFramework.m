//  Copyright © 2020 Eric M M PEI. All rights reserved.

#import "OCVendorInFramework.h"
#import <Etiquette/Etiquette-Swift.h>

@implementation OCVendorInFramework

- (void)sayHello {
    NSLog(@"Hello from OCVendorInFramework");
}

- (void)sayHowdy {
    NSLog(@"Howdy from OCVendorInFramework");
}

- (void)sayMorning {
    NSLog(@"Morning from OCVendorInFramework");
}

- (void)saySwiftVendorWords {
    NSLog(@"\n--- [Framework] Import Swift into Objective-C ---");
    SwiftVendorInFramework *vendor = [[SwiftVendorInFramework alloc] init];
    [vendor sayHello];
    [vendor sayHowdy];
    [vendor sayMorning];
}

@end
