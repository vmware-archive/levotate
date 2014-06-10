//
//  LevoDocumentWriter.m
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-23.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "LevoDocumentWriter.h"
#import "LevotateParsedObject.h"

@interface LevoDocumentWriter () <NSMenuDelegate>

@property (nonatomic, strong) IBOutlet LevotateParsedObject *topLevelObject;

@end

@implementation LevoDocumentWriter

static NSURL *currentDocumentLocation;
+ (void)setCurrentDocumentLocation:(NSURL *)documentLocation {
    currentDocumentLocation = documentLocation;
}

+ (NSURL *)currentDocumentLocation {
    return currentDocumentLocation;
}

- (IBAction)saveAsMenuOptionSelected:(NSMenuItem *)saveAsMenuItem {
    NSURL *saveLocation = [self requestSaveLocationFromUser];
//    [self saveLevoDocumentAtLocation:saveLocation];
}

- (IBAction)saveMenuOptionSelected:(NSMenuItem *)saveMenuItem {
    NSURL *saveLocation = [self.class currentDocumentLocation];
    if (!saveLocation) {
        saveLocation = [self requestSaveLocationFromUser];
    } else {
        [self saveLevoDocumentAtLocation:saveLocation];
    }
}

- (NSURL *)requestSaveLocationFromUser {
    __block NSURL *saveLocation;
    //kick off a system save dialog
    
    NSSavePanel *systemSavePanel = [NSSavePanel savePanel];
    systemSavePanel.canSelectHiddenExtension = YES;
    __weak NSSavePanel *weakSavePanel = systemSavePanel;
    [systemSavePanel beginSheetModalForWindow:[NSApp keyWindow] completionHandler:^(NSInteger result) {
        saveLocation = weakSavePanel.URL;
        [self.class setCurrentDocumentLocation:saveLocation];
        [self saveLevoDocumentAtLocation:saveLocation];

    }];
    return saveLocation;
}

- (void)saveLevoDocumentAtLocation:(NSURL *)documentLocation {
    NSMutableDictionary *levoSchemaMap = [NSMutableDictionary new];
    levoSchemaMap[@"Project"] = @"ProjectName";
    levoSchemaMap[@"Models"] = [NSMutableArray new];
    [self addLevoModelFromParsedObject:self.topLevelObject toModelsArray:levoSchemaMap[@"Models"]];
    
    NSError *jsonDataError;
    NSData *levoDocumentData = [NSJSONSerialization dataWithJSONObject:levoSchemaMap options:NSJSONWritingPrettyPrinted error:&jsonDataError];
    if (jsonDataError) {
        NSLog(@"Could not write file due to error creating JSON");
    }
    
    NSLog(@"attemping write to file: %@", documentLocation.absoluteString);

    //This should absolutely not be required -- I mean why would the NSSavePanel give me a URL that can't actually be used
    NSURL *fileLocationWithoutScheme = [NSURL URLWithString:documentLocation.path];

    if (![[NSFileManager defaultManager] createFileAtPath:fileLocationWithoutScheme.absoluteString contents:levoDocumentData attributes:nil]) {
        NSLog(@"error writing file: %@", fileLocationWithoutScheme.absoluteString);
    }
}

- (void)addLevoModelFromParsedObject:(LevotateParsedObject *)parsedObject toModelsArray:(NSMutableArray *)modelsArray {
    NSMutableDictionary *modelMap = [NSMutableDictionary new];
    modelMap[@"Name"] = parsedObject.name;
    modelMap[@"Parent"] = @"";
    modelMap[@"Properties"] = [NSMutableArray new];
    [self addPropertiesToLevoModel:modelMap fromParsedObject:parsedObject inModelsArray:modelsArray];
    [modelsArray addObject:modelMap];
}

- (void)addPropertiesToLevoModel:(NSMutableDictionary *)levoModel fromParsedObject:(LevotateParsedObject *)parsedObject inModelsArray:(NSMutableArray *)modelsArray {
    for (LevotateParsedObject *childObject in parsedObject.childObjects) {
        NSMutableDictionary *propertyMap = [NSMutableDictionary new];
        propertyMap[@"RemoteIdentifier"] = childObject.name;
        propertyMap[@"LocalIdentifier"] = childObject.name;
        propertyMap[@"PropertyType"] = childObject.resolvedClass;

        if ([childObject.resolvedClass isEqualToString:@"Object"]) {
            [self addLevoModelFromParsedObject:childObject toModelsArray:modelsArray];
            propertyMap[@"PropertyType"] = childObject.name;
        }
        
        
        [levoModel[@"Properties"] addObject:propertyMap];
    }
}

@end
