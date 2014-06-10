//
//  LevotateParsedObject.m
//  Levotate
//
//  Created by Adrian Kemp on 2014-05-22.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "LevotateParsedObject.h"

NSString * const LevotateParsedObjectChildrenDidChangeNotification = @"LevotateParsedObjectChildrenDidChangeNotification";

static NSString * const RFC3339DateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
static NSString * const CommonPossiblyStandardDateFormat = @"'yyyy'-'MM'-'dd'T'HH':'mm':'ss'+00:00";

@interface LevotateParsedObject ()

@property (nonatomic, strong, readwrite) NSMutableArray *childObjects;

@end

@implementation LevotateParsedObject

static NSDateFormatter *CommonPossiblyStandardDateFormatter;
+ (NSDateFormatter *)CommonPossiblyStandardDateFormatter {
    if (!CommonPossiblyStandardDateFormatter) {
        CommonPossiblyStandardDateFormatter = [[NSDateFormatter alloc] initWithDateFormat:CommonPossiblyStandardDateFormat allowNaturalLanguage:NO];
    }
    return CommonPossiblyStandardDateFormatter;
}


static NSDateFormatter *RFC3339DateFormatter;
+ (NSDateFormatter *)RFC3339DateFormatter {
    if (!RFC3339DateFormatter) {
        RFC3339DateFormatter = [[NSDateFormatter alloc] initWithDateFormat:RFC3339DateFormat allowNaturalLanguage:NO];
    }
    return RFC3339DateFormatter;
}

+ (NSString *)levoClassForObject:(NSObject *)object {
    if ([object isKindOfClass:[NSString class]]) {
        //if it's a date
        if ([[self RFC3339DateFormatter] dateFromString:((NSString *)object)]) {
            return @"Date";
        } else if ([[self CommonPossiblyStandardDateFormatter] dateFromString:((NSString *)object)]) {
            return @"Date";
        } else {
            return @"String";
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *numberObject = (NSNumber *)object;
        if (((float)numberObject.integerValue) == numberObject.floatValue ) {
            return @"Integer";
        } else {
            return @"Float";
        }
    } else if ([object isKindOfClass:[NSNull class]]) {
        return @"String";
    } else {
        return @"Object";
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.childObjects = [NSMutableArray new];
}

- (instancetype)initWithName:(NSString *)name assumedClass:(NSString *)assumedClass {
    self = [super init];
    self.name = name;
    self.assumedClass = assumedClass;
    self.childObjects = [NSMutableArray new];
    return self;
}

- (id)init {
    self = [super init];
    self.childObjects = [NSMutableArray new];
    return self;
}

- (void)addChildObject:(LevotateParsedObject *)childObject {
    if (![self.childObjects containsObject:childObject]) {
        [((NSMutableArray *)self.childObjects) addObject:childObject];
    }
    //This is super not ideal from a performance standpoint. But the lower efficiency here is offset by much more efficient table reloads.
    [[NSNotificationCenter defaultCenter] postNotificationName:LevotateParsedObjectChildrenDidChangeNotification object:self];
}

- (void)removeAllChildren {
    self.childObjects = [NSMutableArray new];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    LevotateParsedObject *otherObject = object;
    if ([otherObject isKindOfClass:[LevotateParsedObject class]]) {
        if ([self.name isEqualToString:otherObject.name] && [self.assumedClass isEqualToString:otherObject.assumedClass] && [self.userProvidedClass isEqualToString:otherObject.userProvidedClass]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)resolvedClass {
    return (self.userProvidedClass ? self.userProvidedClass : self.assumedClass);
}

- (NSString *)description {
    NSString *childDescriptions = [NSString new];
    for (LevotateParsedObject *child in self.childObjects) {
        childDescriptions = [childDescriptions stringByAppendingString:[child description]];
    }
    return [NSString stringWithFormat:@"%@[%@]\n------------\n%@", self.name, self.resolvedClass, childDescriptions];
}

@end
