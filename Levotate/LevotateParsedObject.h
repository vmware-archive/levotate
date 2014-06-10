//
//  LevotateParsedObject.h
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-22.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const LevotateParsedObjectChildrenDidChangeNotification;

@interface LevotateParsedObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *assumedClass;
@property (nonatomic, strong) NSString *userProvidedClass;
@property (nonatomic, strong, readonly) NSArray *childObjects;
@property (nonatomic, weak) NSString *resolvedClass;

+ (NSString *)levoClassForObject:(NSObject *)object;
- (instancetype)initWithName:(NSString *)name assumedClass:(NSString *)assumedClass;
- (void)addChildObject:(LevotateParsedObject *)childObject;
- (void)removeAllChildren;

@end
