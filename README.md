# CheatyXML

[![CocoaPods](https://img.shields.io/cocoapods/v/CheatyXML.svg)](https://cocoapods.org/pods/CheatyXML)
[![Build Status](https://travis-ci.org/lobodart/CheatyXML.svg?branch=master)](https://travis-ci.org/lobodart/CheatyXML)
[![codecov](https://codecov.io/gh/lobodart/CheatyXML/branch/master/graph/badge.svg)](https://codecov.io/gh/lobodart/CheatyXML)

**CheatyXML** is a Swift framework designed to make working with XML easy and intuitive.

## Requirements
- iOS 8.0 or later
- tvOS 9.0 or later

## Installation

### CocoaPods
If you're using **CocoaPods**, add the following to your `Podfile`:

```ruby
pod 'CheatyXML'
```

Then run:

```bash
pod install
```

### Manual Installation

To install manually:

1. Add the `CheatyXML.xcodeproj` to your project.
2. Link the `CheatyXML.framework` in your target’s **Linked Frameworks and Libraries** section.
3. Import CheatyXML in your Swift code:

```swift
import CheatyXML
```

## Usage

We'll use the following sample XML throughout our examples:

```xml
<blog version="1.0" creator="lobodart">
    <name>MyAwesomeBlog!</name>
    <users>
        <admin is_active="true">lobodart</admin>
        <moderator is_active="false">slash705</moderator>
        <moderator is_active="...">...</moderator>
    </users>
    <article>
        <title>My first article</title>
        <description>This is the first article</description>
        <infos>
            <date>2015-03-15 15:42:42</date>
            <rate>42</rate>
        </infos>
    </article>
    <article>
        ...
    </article>
</blog>
```

### Creating a Parser Instance

#### From a URL

```swift
let parser = CXMLParser(contentsOfURL: url)
```

#### From a String

```swift
let parser = CXMLParser(string: xmlString)
```

#### From Data

```swift
let parser = CXMLParser(data: xmlData)
```

### Accessing Elements

#### Simple Tag Access

```swift
let blogName = parser["name"].stringValue // Returns a non-optional String
let blogNameOptional = parser["name"].string // Returns an optional String
```

You can also use `rootElement` for clarity:

```swift
let element = parser.rootElement["name"]
```

#### Nested Tags

```swift
let blogAdmin = parser["users"]["admin"].stringValue
print(blogAdmin) // lobodart
```

### Working with Multiple Elements

#### Access by Index

```swift
let title1 = parser["article", 0]["title"].stringValue
let title2 = parser["article"][0]["title"].stringValue
```

Both notations are equivalent—choose whichever you prefer.

#### Iterating Over Children

```swift
for element in parser.rootElement {
    print(element.tagName)
}
```

Output:

```
name
users
article
article
```

#### Iterating Over Specific Children

```swift
for article in parser.rootElement.elementsNamed("article") {
    print(article.tagName)
}
```

#### Counting Children

```swift
let childCount = parser["users"].numberOfChildElements
print(childCount) // 4 (3 moderators + 1 admin)
```

##### Count Specific Tags

```swift
let moderatorCount1 = parser["users"]["moderator"].count
let moderatorCount2 = parser["users"].elementsNamed("moderator").count
```

### Type Casting

CheatyXML supports casting to common types:

```swift
let rate = parser["article", 0]["rate"]
rate.int         // Optional(42)
rate.intValue    // 42
rate.float       // Optional(42.0)
rate.floatValue  // 42.0
```

Always prefer optional casts when unsure about the value:

```swift
let title = parser["article", 0]["title"]
title.string        // Optional("My first article")
title.stringValue   // "My first article"
title.int           // nil
title.intValue      // ⚠️ CRASH!
```

### Missing Tags

```swift
let date = parser["article", 0]["infos"]["date"].stringValue
print(date) // "2015-03-15 15:42:42"

let missingDate = parser["articles", 0]["infos"]["date"].string
print(missingDate) // nil
```

> 💡 **Tip**: Use `.string` (optional) over `.stringValue` (non-optional) to safely avoid crashes on missing tags.

### Attributes

#### Single Attribute

```swift
let version = parser.rootElement.attribute("version")
let isActive = parser["users"]["admin"].attribute("is_active")
```

With type casting:

```swift
let version = parser.rootElement.attribute("version").floatValue // 1.0
let creator = parser.rootElement.attribute("creator").stringValue // "lobodart"
```

#### All Attributes

```swift
let attributes = parser.rootElement.attributes // [CXMLAttribute]
let dict = attributes.dictionary               // [String: String]
```

## TO-DO

* [ ] Add more unit tests
* [ ] Class mapping
* [ ] XML generator
