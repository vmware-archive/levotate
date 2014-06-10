//
//  JSONTextViewController.m
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "JSONTextViewController.h"
#import "JSONManipulationViewController.h"
#import "ObjectBrowserViewController.h"
#import "LevotateParsedObject.h"

@interface JSONTextViewController () <NSTextViewDelegate>

@property (nonatomic, strong) IBOutlet LevotateParsedObject *topLevelObject;
@property (nonatomic, weak) IBOutlet JSONManipulationViewController *jsonEditorController;
@property (nonatomic, assign) BOOL textUpdateInitiatedByFormatter;
@property (nonatomic, assign) NSUInteger postReplacementCursorPosition;

@end

@implementation JSONTextViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.view.automaticQuoteSubstitutionEnabled = NO;

}

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    if (self.postReplacementCursorPosition) {
        NSLog(@"setting caret to location %lu", self.postReplacementCursorPosition);
        
        [self.view setSelectedRange:NSMakeRange(self.postReplacementCursorPosition, 0)];
        self.postReplacementCursorPosition = 0;
    }
}


- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if (!replacementString) {
        return YES;
    } else if (self.textUpdateInitiatedByFormatter) {
        self.textUpdateInitiatedByFormatter = NO;
        //Now it's all well and good to update the text so that it's nicely formatted...
        //but losing their current position would be kind of a crappy thing to do.
        NSInteger currentInsertionPoint = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        
        NSError *regexError;
        NSRange inserttionRange = NSMakeRange(currentInsertionPoint, 1);
        NSString *regexString = [textView.string substringWithRange:inserttionRange];
        NSLog(@"regex: %@", regexString);
        NSRegularExpression *caretPlacementRegex = [[NSRegularExpression alloc] initWithPattern:regexString options:0 error:&regexError];
        
        if (regexError) {
            NSLog(@"got error when attempting to locate caret position: %@", regexError.localizedFailureReason);
            return YES;
        }
        
        NSArray *currentMatches = [caretPlacementRegex matchesInString:textView.string options:0 range:affectedCharRange];
        NSArray *replacementMatches = [caretPlacementRegex matchesInString:replacementString options:0 range:NSMakeRange(0, replacementString.length)];
        
        for (NSUInteger matchIndex = 0; matchIndex < currentMatches.count; matchIndex++) {
            NSTextCheckingResult *match = currentMatches[matchIndex];
            if (match.range.location == currentInsertionPoint) {
                self.postReplacementCursorPosition = ((NSTextCheckingResult*)replacementMatches[matchIndex]).range.location;
            }
        }
        NSLog(@"going to set the caret positon to %d", self.postReplacementCursorPosition);

        return YES;
    }
    
    NSString *replacedString = [textView.textStorage.string stringByReplacingCharactersInRange:affectedCharRange withString:replacementString];
    
    NSError *jsonParsingError;
    id parsedObject = [NSJSONSerialization JSONObjectWithData:[replacedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonParsingError];
    
    [self.jsonEditorController setJSONError:jsonParsingError];
    
    if (!jsonParsingError) {
        self.textUpdateInitiatedByFormatter = YES;
        
        NSString *formattedText = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parsedObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        
        [textView setString:formattedText];
        
        [self.topLevelObject removeAllChildren];
        [self processJSONObject:parsedObject withRootObject:self.topLevelObject];
        return NO;
    }
    
    return YES;
}

- (void)processJSONObject:(id)parsedObject withRootObject:(LevotateParsedObject *)rootObject {
    if ([parsedObject isKindOfClass:[NSDictionary class]]) {
        for (NSString *elementName in ((NSDictionary *)parsedObject)) {
            LevotateParsedObject *childObject = [[LevotateParsedObject alloc] initWithName:elementName assumedClass:[LevotateParsedObject levoClassForObject:parsedObject[elementName]]];
            [rootObject addChildObject:childObject];
            [self processJSONObject:parsedObject[elementName] withRootObject:childObject];
        }
    } else if ([parsedObject isKindOfClass:[NSArray class]]) {
        for (id arrayElement in ((NSArray *)parsedObject)) {
            [self processJSONObject:arrayElement withRootObject:rootObject];
        }
    }
}

@end
