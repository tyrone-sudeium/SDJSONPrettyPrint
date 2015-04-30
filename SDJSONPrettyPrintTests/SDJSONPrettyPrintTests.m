//
//  SDJSONPrettyPrintTests.m
//  SDJSONPrettyPrintTests
//
//  Created by Tyrone Trevorrow on 4-06-13.
//  Copyright (c) 2013 Sudeium. All rights reserved.
//

#import "SDJSONPrettyPrintTests.h"
#import "SDJSONPrettyPrint.h"

@implementation SDJSONPrettyPrintTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testBasicNumbers
{
    NSString *expected = @"[1, 5, 4, 2]";
    NSArray *object = @[@1, @5, @4, @2];
    
    NSString *output = [SDJSONPrettyPrint stringFromJSONObject: object];
    XCTAssertEqualObjects(expected, output);
}

- (void) testBasicObject
{
    NSString *expected = @"{\n  \"a\": 1,\n  \"b\": true\n}";
    NSDictionary *object = @{ @"a": @1, @"b": @YES };
    
    NSString *output = [SDJSONPrettyPrint stringFromJSONObject: object];
    XCTAssertEqualObjects(expected, output);
}

- (void) testNested
{
    NSString *fileName = @"NestedTest";
    [self runFileTest: fileName];
}

- (void) testUnicode
{
    NSString *fileName = @"UnicodeTest";
    [self runFileTest: fileName];
    
    NSString *expected = @"[\"Привет\"]";
    NSArray *object = @[@"Привет"];
    NSString *output = [SDJSONPrettyPrint stringFromJSONObject: object];
    XCTAssertEqualObjects(expected, output);
}

- (void) testSorting
{
    NSString *fileName = @"SortingTest";
    [self runFileTest: fileName];
}

- (void) runFileTest: (NSString*) fileName
{
    NSString *filePath = [[NSBundle bundleForClass: [self class]] pathForResource: fileName ofType: @"json"];
    NSString *expected = [NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: NULL];
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData: [expected dataUsingEncoding: NSUTF8StringEncoding] options: 0 error: NULL];
    
    NSString *output = [SDJSONPrettyPrint stringFromJSONObject: object];
    XCTAssertEqualObjects(expected, output);
}

@end
