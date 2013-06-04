SDJSONPrettyPrint - The Slow JSON Serializer
============================================

`SDJSONPrettyPrint` transforms a compatible Foundation-based object tree into
a JSON string.  It is not designed to be a fast, production-ready JSON
serializer, for that you probably want [JSONKit](https://github.com/johnezang/JSONKit).
`SDJSONPrettyPrint` focuses on producing the most human-friendly JSON possible, 
which you can use for logging or debugging purposes.

## Purpose
There exist multitudes of JSON serializers for Objective-C which - including a very good
_built-in_ one that produces perfectly valid JSON strings, primarily for the consumption
of machines.  Most of these solutions ignore - or have otherwise limited solutions for -
producing output designed to be read by _humans_.  This is an important feature for
logging since in the production of a large scale system with a complex API, during the
course of development many thousands of API requests and responses will be made.  Many 
of these will be checked by hand by the programmer to ensure the application is
interacting with the API correctly.  This project aims to produce JSON output that's
considerably easier to read, is formatted in a pleasing way and presents the data in a
way that's least likely to frustrate.

## Example
Consider the following JSON sample, formatted for machines:
```json
{"function":null,"numbers":[4,8,15,16,23,42],"y_index":2,"x_index":12,"z_index":5,"arcs":[{"p2":[22.1,50],"p1":[10.5,15.5],"radius":5},{"p2":[23.1,40],"p1":[11.5,15.5],"radius":10},{"p2":[23.1,30],"p1":[12.5,15.5],"radius":3},{"p2":[24.1,20],"p1":[13.5,15.5],"radius":2},{"p2":[25.1,10],"p1":[14.5,15.5],"radius":8},{"p2":[26.1,0],"p1":[15.5,15.5],"radius":2}],"label":"my label"}
```
If you run this through `NSJSONSerialization` with `NSJSONWritingPrettyPrinted` enabled,
it produces:
```json
{
  "function" : null,
  "numbers" : [
    4,
    8,
    15,
    16,
    23,
    42
  ],
  "y_index" : 2,
  "x_index" : 12,
  "z_index" : 5,
  "arcs" : [
    {
      "p2" : [
        22.1,
        50
      ],
      "p1" : [
        10.5,
        15.5
      ],
      "radius" : 5
    },
    {
      "p2" : [
        23.1,
        40
      ],
      "p1" : [
        11.5,
        15.5
      ],
      "radius" : 10
    },
    {
      "p2" : [
        23.1,
        30
      ],
      "p1" : [
        12.5,
        15.5
      ],
      "radius" : 3
    },
    {
      "p2" : [
        24.1,
        20
      ],
      "p1" : [
        13.5,
        15.5
      ],
      "radius" : 2
    },
    {
      "p2" : [
        25.1,
        10
      ],
      "p1" : [
        14.5,
        15.5
      ],
      "radius" : 8
    },
    {
      "p2" : [
        26.1,
        0
      ],
      "p1" : [
        15.5,
        15.5
      ],
      "radius" : 2
    }
  ],
  "label" : "my label"
}
```
This is slightly better, but really all it did was add a heap of whitespace to fill up
vertical space.  It indisciminately adds newlines for every element in an array, and the
order in which it prints out keys in JSON objects seems fairly arbitrary.  The `label`
key is - surprisingly - _underneath_ the giant array of objects `arcs` which means it
could very easily be missed.

`JSONKit` is a highly respected JSON parsing and serializing library and is used in
production by many apps.  Similarly to `NSJSONSerialization`, it has a pretty printing
mode.  When this example JSON is run through it, it produces:
```json
{
  "arcs": [
    {
      "p1": [
        10.5,
        15.5
      ],
      "p2": [
        22.100000000000001,
        50
      ],
      "radius": 5
    },
    {
      "p1": [
        11.5,
        15.5
      ],
      "p2": [
        23.100000000000001,
        40
      ],
      "radius": 10
    },
    {
      "p1": [
        12.5,
        15.5
      ],
      "p2": [
        23.100000000000001,
        30
      ],
      "radius": 3
    },
    {
      "p1": [
        13.5,
        15.5
      ],
      "p2": [
        24.100000000000001,
        20
      ],
      "radius": 2
    },
    {
      "p1": [
        14.5,
        15.5
      ],
      "p2": [
        25.100000000000001,
        10
      ],
      "radius": 8
    },
    {
      "p1": [
        15.5,
        15.5
      ],
      "p2": [
        26.100000000000001,
        0
      ],
      "radius": 2
    }
  ],
  "function": null,
  "label": "my label",
  "numbers": [
    4,
    8,
    15,
    16,
    23,
    42
  ],
  "x_index": 12,
  "y_index": 2,
  "z_index": 5
}
```
This is slightly better since it at least orders the keys in a predictable - if slightly
useless - way: alphabetically.  It still has the problem of indiscriminate newlines and
placing large values which have large JSON structures before simple values, making it easy
to overlook data.

The following is the output from `SDJSONPrettyPrint`.
```json
{
  "label": "my label",
  "x_index": 12,
  "y_index": 2,
  "z_index": 5,
  "numbers": [4, 8, 15, 16, 23, 42],
  "function": null,
  "arcs": [
    {
      "radius": 5,
      "p1": [10.5, 15.5],
      "p2": [22.1, 50]
    },
    {
      "radius": 10,
      "p1": [11.5, 15.5],
      "p2": [23.1, 40]
    },
    {
      "radius": 3,
      "p1": [12.5, 15.5],
      "p2": [23.1, 30]
    },
    {
      "radius": 2,
      "p1": [13.5, 15.5],
      "p2": [24.1, 20]
    },
    {
      "radius": 8,
      "p1": [14.5, 15.5],
      "p2": [25.1, 10]
    },
    {
      "radius": 2,
      "p1": [15.5, 15.5],
      "p2": [26.1, 0]
    }
  ]
}
```

## Performance
### _"The Slow JSON Serializer"_, just how slow is it anyway?
Very slow.

![Benchmarks](https://raw.github.com/tyrone-sudeium/SDJSONPrettyPrint/master/Resources/Performance.png)

### What `SDJSONPrettyPrint` is
* A JSON string serializer that focuses on human-readable output.
* Good for debugging and logging.
* A JSON visualisation mechanism.

### What `SDJSONPrettyPrint` is _not_
* A production-ready JSON serializer.  It should probably be _disabled_ in your production
builds, but since it contains _no_ private APIs, it's perfectly App-Store safe.
* Fast, reliable or strict.
* A JSON validator.  You're much better off using `NSJSONSerialization` for this.  In fact,
`SDJSONPrettyPrint` even uses `NSJSONSerialization` internally to sanity check the JSON object,
so you're absolutely _no_ better off using this class for that purpose.
* A JSON parser.  Again, there are plenty of fantastic JSON parsers out there, and I certainly
couldn't do a better job than they already do.

## Requirements
* Automatic Reference Counting.
* Mac OS X >= 10.7 or iOS >= 5.0.  It will _probably_ run under older versions if you
install [AnyJSON](https://github.com/mattt/AnyJSON), but I haven't tested this.
* _Optional_: CocoaPods.

## Installation
1.  Recommended: CocoaPods.

        pod 'SDJSONPrettyPrint'

2.  Manually.  Copy `SDJSONPrettyPrint.h` and `SDJSONPrettyPrint.m` files into your
project.  It is unintrusive, requires no frameworks other than `Foundation` and it 
implements _no_ categories.

## License
`SDJSONPrettyPrint` is licensed under the permissive MIT License.

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
