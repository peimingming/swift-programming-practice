//  Copyright © 2020 Eric M M PEI. All rights reserved.

#import "OCVendor.h"
#import "EtiquetteHost-Swift.h"

@implementation OCVendor

- (void)sayHello {
    NSLog(@"Hello from OCVendor");
}

- (void)sayHowdy {
    NSLog(@"Howdy from OCVendor");
}

- (void)sayMorning {
    NSLog(@"Morning from OCVendor");
}

- (void)saySwiftVendorWords {
    NSLog(@"\n--- [Host] Import Swift into Objective-C ---");
    SwiftVendor *vendor = [[SwiftVendor alloc] init];
    [vendor sayHello];
    [vendor sayHowdy];
    [vendor sayMorning];
}

@end
