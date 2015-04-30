//
//  SDJSONPrettyPrint.m
//  SDJSONPrettyPrint
//
//  Created by Tyrone Trevorrow on 3-06-13.
//  Copyright (c) 2013 Sudeium. All rights reserved.
//

#import "SDJSONPrettyPrint.h"

@implementation SDJSONPrettyPrint {
    NSString *_lastKey;
}

static NSString* SDJSONBasicObjectTranslation(NSObject *object)
{
    if (object == [NSNull null]) {
        return @"null";
    } else if (object == (id)kCFBooleanTrue) {
        return @"true";
    } else if (object == (id)kCFBooleanFalse) {
        return @"false";
    } else if (object == [NSNumber numberWithBool: YES]) {
        return @"true";
    } else if (object == [NSNumber numberWithBool: NO]) {
        return @"false";
    } else if ([object isEqual: @[]]) {
        return @"[]";
    } else if ([object isEqual: @{}]) {
        return @"{}";
    } else if ([object isKindOfClass: [NSString class]]) {
        return SDJSONStringTranslation((NSString*)object);
    } else if ([object isKindOfClass: [NSNumber class]]) {
        return SDJSONNumberTranslation((NSNumber*)object);
    } else {
        return nil;
    }
}

static NSString* SDJSONNumberTranslation(NSNumber* number)
{
    __strong static NSNumber *infinity = nil;
    __strong static NSNumber *negInfinity = nil;
    __strong static NSNumber *nan = nil;
    if (infinity == nil) {
        infinity = [NSNumber numberWithDouble: HUGE_VAL];
        negInfinity = [NSNumber numberWithDouble: -HUGE_VAL];
        nan = [NSDecimalNumber notANumber];
    }
    
    if ([number isEqualToNumber: infinity]) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Invalid object graph provided to stringFromJSONObject.  Error: Infinity is not valid in JSON."];
        return nil;
    } else if ([number isEqualToNumber: negInfinity]) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Invalid object graph provided to stringFromJSONObject.  Error: Negative infinity is not valid in JSON."];
        return nil;
    } else if ([number isEqualToNumber: nan]) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Invalid object graph provided to stringFromJSONObject.  Error: NaN is not valid in JSON."];
        return nil;
    }
    const char *objcType = [number objCType];
    switch (objcType[0]) {
        case 'c': case 'i': case 's': case 'l': case 'q': case 'C': case 'I':
        case 'S': case 'L': case 'Q':
            return [NSString stringWithFormat: @"%@", number];
        case 'f': case 'd': default:
            return [NSString stringWithFormat: @"%.17g", number.doubleValue];
    }
    
    return nil;
}

static NSString* SDJSONStringTranslation(NSString* string)
{
    NSMutableData *outData = [NSMutableData dataWithCapacity: string.length+2];
    [outData appendBytes: "\"" length: 1];
    const uint8_t *stringData = (const uint8_t*) [string UTF8String];
    for (int i = 0; i < [string lengthOfBytesUsingEncoding: NSUTF8StringEncoding]; i++) {
        uint8_t c = stringData[i];
        char hexCode[7];
        const char* escaped = nil;
        switch (c) {
            case '\t': escaped = "\\t"; break;
            case '\n': escaped = "\\n"; break;
            case '\\': escaped = "\\\\"; break;
            case '\r': escaped = "\\r"; break;
            case '"': escaped = "\\\""; break;
            case '\b': escaped = "\\b"; break;
            case '\f': escaped = "\\f"; break;
            default:
                if (c < 32 || c == 127) {
                    snprintf(hexCode, 7, "\\u%04x", c);
                    escaped = hexCode;
                }
                break;
        }
        if (escaped != nil) {
            [outData appendBytes: escaped length: strlen(escaped)];
        } else {
            [outData appendBytes: &c length: 1];
        }
    }
    [outData appendBytes: "\"" length: 1];
    return [[NSString alloc] initWithData: outData encoding: NSUTF8StringEncoding];
}

NS_INLINE void SDJSONAppendToDepth(NSUInteger depth, NSMutableString *output)
{
    for (int i = 0; i < depth; i++) {
        [output appendString: @"  "];
    }
}

+ (NSString*) stringFromJSONObject:(NSObject *)jsonObject
{
    return [[[self alloc] init] stringFromJSONObject: jsonObject];
}

- (NSString*) stringFromJSONObject:(NSObject *)jsonObject
{
    // Why do this?  NSJSONSerialization can write JSON very fast.  Way faster than I
    // can.  It can do it so fast, I can delegate responsibility of ensuring the
    // incoming JSON is valid to it, and it'll do the job at least 20x quicker than
    // I will.  This means compared to the cost of including validation code in this
    // project, and compared to the performance cost of including validation *logic*
    // in this project, it's significantly cheaper to just use the 20x faster
    // NSJSONSerialization serializer as a first-pass validation check to make sure
    // the incoming JSON is sane.
    
    NSError *error = nil;
    NSData *sanityCheck = [NSJSONSerialization dataWithJSONObject: jsonObject options: 0 error: &error];
    if (sanityCheck == nil || error != nil) {
        return nil;
    }
    return [self objectTranslation: jsonObject depth: 0];
}

- (NSString*) objectTranslation: (NSObject*) object depth: (NSUInteger) depth
{
    NSString *basicDescription = SDJSONBasicObjectTranslation(object);
    if (basicDescription != nil) {
        return basicDescription;
    }
    
    if ([object isKindOfClass: [NSArray class]]) {
        NSArray *arrayObject = (NSArray*) object;
        NSUInteger positionOnLine = 2 * depth;
        if (_lastKey != nil) {
            positionOnLine += _lastKey.length + 4;
        }
        
        NSString *oneLiner = [[self class] oneLineArrayTranslation: arrayObject positionOnLine:positionOnLine];
        if (oneLiner != nil) {
            return oneLiner;
        }
        
        return [self multiLineArrayTranslation: arrayObject depth: depth+1];
    } else if ([object isKindOfClass: [NSDictionary class]]) {
        NSDictionary *dictObject = (NSDictionary*) object;
        return [self multiLineDictTranslation: dictObject depth: depth+1];
    } else {
        // Unknown type!
        [NSException raise: NSInternalInconsistencyException format: @"Unknown object type in object graph provided to stringFromJSONObject.  Error: '%@' is not a JSON type.", object.class];
        return nil;
    }
}

- (NSString*) multiLineDictTranslation: (NSDictionary*) dict depth: (NSUInteger) depth
{
    NSMutableString *output = [NSMutableString stringWithCapacity: dict.count*(depth+1)*2];
    NSArray *keyValuePairs = [self keyValuePairsFromDictionary: dict depth: depth];
    BOOL first = YES;
    for (SDJSONKeyValuePair *kvp in keyValuePairs) {
        _lastKey = kvp.key;
        NSString *valueTranslation = [self objectTranslation: kvp.value depth: depth];
        if (!first) {
            [output appendString: @",\n"];
        } else {
            [output appendString: @"{\n"];
        }
        SDJSONAppendToDepth(depth, output);
        first = NO;
        [output appendFormat: @"%@: %@", kvp.key, valueTranslation];
    }
    [output appendString: @"\n"];
    SDJSONAppendToDepth(depth-1, output);
    [output appendString: @"}"];
    
    return output;
}

- (NSString*) multiLineArrayTranslation: (NSArray*) array depth: (NSUInteger) depth
{
    NSMutableString *output = [NSMutableString stringWithCapacity: array.count*(depth+1)*2];
    BOOL first = YES;
    for (id obj in array) {
        NSString *translation = [self objectTranslation: obj depth: depth];
        if (!first) {
            [output appendString: @",\n"];
        } else {
            [output appendString: @"[\n"];
        }
        SDJSONAppendToDepth(depth, output);
        first = NO;
        [output appendString: translation];
    }
    [output appendString: @"\n"];
    SDJSONAppendToDepth(depth-1, output);
    [output appendString: @"]"];
    
    return output;
}

+ (NSString*) oneLineArrayTranslation: (NSArray*) array positionOnLine: (NSUInteger) positionOnLine
{
    // First check that there aren't any objects
    for (id obj in array) {
        if ([obj isKindOfClass: [NSDictionary class]] && ![obj isEqual: @{}]) {
            return nil;
        }
    }
    
    // Next check that there's enough space.
    NSMutableString *output = [NSMutableString stringWithCapacity: 80];
    [output appendString: @"["];
    BOOL first = YES;
    for (id obj in array) {
        NSString *basicDescription = SDJSONBasicObjectTranslation(obj);
        if (basicDescription == nil && [obj isKindOfClass: [NSArray class]]) {
            basicDescription = [self oneLineArrayTranslation: obj positionOnLine: positionOnLine + [output length]];
        }
        if (basicDescription == nil) {
            // Unsupported object or too long.
            return nil;
        }
        
        if (!first) {
            [output appendString: @", "];
        }
        first = NO;
        
        [output appendString: basicDescription];
        if (positionOnLine + [output length] > 80) {
            return nil;
        }
    }
    [output appendString: @"]"];
    return output;
}

- (NSArray*) keyValuePairsFromDictionary: (NSDictionary*) dictionary depth: (NSUInteger) depth
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in dictionary) {
        SDJSONKeyValuePair *kvp = [SDJSONKeyValuePair new];
        kvp.key = SDJSONStringTranslation(key);
        kvp.value = dictionary[key];
        kvp.depth = depth;
        [array addObject: kvp];
    }
    if (self.objectSortingComparator != NULL) {
        [array sortUsingComparator: self.objectSortingComparator];
    } else {
        [array sortUsingSelector: @selector(compare:)];
    }
    return array;
}

+ (BOOL) checkTraversedObjects: (NSMutableSet*) traversedObjects forObject: (id) object
{
    if ([traversedObjects containsObject: object]) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Invalid object graph provided to stringFromJSONObject.  Error: Cyclical references detected."];
        return NO;
    } else {
        [traversedObjects addObject: object];
    }
    return YES;
}

@end

@implementation SDJSONKeyValuePair

- (NSComparisonResult) compare: (SDJSONKeyValuePair*) right
{
    SDJSONKeyValuePair *left = self;
    NSUInteger leftMask = left.sortMask;
    NSUInteger rightMask = right.sortMask;
    if (leftMask > rightMask) {
        return NSOrderedDescending;
    } else if (leftMask < rightMask) {
        return NSOrderedAscending;
    } else {
        return [left.key compare: right.key];
    }
}

- (NSUInteger) sortMask
{
    NSUInteger mask = 0;
    if ([self.value isKindOfClass: [NSArray class]]) {
        NSUInteger positionOnLine = 2 * self.depth;
        positionOnLine += self.key.length + 4;
        
        NSString *oneLiner = [SDJSONPrettyPrint oneLineArrayTranslation: (NSArray*) self.value positionOnLine:positionOnLine];
        if (oneLiner != nil) {
            mask |= 1;
        } else {
            mask |= 1 << 3;
        }
    }
    if ([self.value isKindOfClass: [NSDictionary class]]) {
        mask |= 1 << 2;
    }
    if (self.value == [NSNull null]) {
        mask |= 1 << 1;
    }
    
    return mask;
}

@end
