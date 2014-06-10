//
//  ObjectBrowserViewController.m
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-22.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "ObjectBrowserViewController.h"
#import "LevotateParsedObject.h"

@interface ObjectBrowserViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) IBOutlet LevotateParsedObject *topLevelObject;

@end

@implementation ObjectBrowserViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topLevelObjectDidChange:) name:LevotateParsedObjectChildrenDidChangeNotification object:self.topLevelObject];
}

- (void)topLevelObjectDidChange:(NSNotification *)parsedObjectChangeNotification {
    [self.view reloadData];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    LevotateParsedObject *parsedObject = item;
    if (!parsedObject) {
        return 1;
    } else {
        return parsedObject.childObjects.count;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    LevotateParsedObject *parsedObject = item;
    if (parsedObject.childObjects.count) {
        return YES;
    } else {
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    LevotateParsedObject *parsedObject = item;
    if (!parsedObject) {
        return self.topLevelObject;
    } else {
        return parsedObject.childObjects[index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    //want to send object and key names to tableColumn 0 and the classes to tablecolumn 1
    LevotateParsedObject *parsedObject = item;
    if (outlineView.tableColumns[1] == tableColumn) {
        return parsedObject.resolvedClass;
    } else {
        return parsedObject.name;
    }
}



@end
