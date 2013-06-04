//
//  SDJSONPrettyPrint.h
//  SDJSONPrettyPrint
//
//  Created by Tyrone Trevorrow on 3-06-13.
//  Copyright (c) 2013 Sudeium. All rights reserved.
//

/*  This software is licensed under The MIT License (MIT).

    Copyright (c) 2013, Tyrone Trevorrow

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

#import <Foundation/Foundation.h>

@interface SDJSONKeyValuePair : NSObject
/** JSON object's key.*/
@property (nonatomic, strong) NSString *key;
/** JSON object's value for the corresponding key.*/
@property (nonatomic, strong) NSObject *value;
/** Depth this key-value pair is in the object tree.*/
@property (nonatomic, assign) NSUInteger depth;
@end

@interface SDJSONPrettyPrint : NSObject
/** Called to determine the sort order of a JSON object.  Passes in two
 * SDJSONKeyValuePair objects, where the key is the current key being sorted
 * and the value is that key's corresponding value in the JSON object.  By
 * default, a JSON object's contents will be sorted thusly:
 * 1st: Array values go last, unless they are one-liners.
 * 2nd: Object values go before Array values.
 * 3rd: Null values go before Object values.
 * 4th: One-liner Array values go before null values.
 * 5th: Alphabetically, by key.
 */
@property (nonatomic, copy) NSComparator objectSortingComparator;

/** Transforms jsonObject into a JSON-compliant string representation.
 *
 * Calls the instance method -stringFromJSONObject: with a
 * SDJSONPrettyPrint object setup with default configuration.
 * @param jsonObject The source JSON-compatible Foundation objects.
 * @return A pretty-printed JSON-compliant string representation.
 */
+ (NSString*) stringFromJSONObject: (NSObject*) jsonObject;

/** Transforms jsonObject into a JSON-compliant string representation.
 *
 * SDJSONPrettyPrint is not designed to be a fast, production-ready JSON
 * serializer, for that you probably want JSONKit.  Instead, it focuses
 * on producing the most human-friendly JSON possible, which you can use
 * for logging or debugging purposes.
 * @param jsonObject The source JSON-compatible Foundation objects.
 * @return A pretty-printed JSON-compliant string representation.
 */
- (NSString*) stringFromJSONObject: (NSObject*) jsonObject;

@end
