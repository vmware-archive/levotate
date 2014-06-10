//
//  JSONManipulationViewController.m
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "JSONManipulationViewController.h"

@interface JSONManipulationViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *errorsLabel;

@end

@implementation JSONManipulationViewController

- (void)setJSONError:(NSError *)error {
    if (error) {
        self.errorsLabel.stringValue = error.localizedFailureReason;
    } else {
        self.errorsLabel.stringValue = @"No Errors";
    }
}

@end
