# CheatyXML

[![CocoaPods](https://img.shields.io/cocoapods/v/CheatyXML.svg?maxAge=2592000)](https://cocoapods.org/pods/CheatyXML)
[![Build Status](https://travis-ci.org/lobodart/CheatyXML.svg?branch=master)](https://travis-ci.org/lobodart/CheatyXML)
[![codecov](https://codecov.io/gh/lobodart/CheatyXML/branch/master/graph/badge.svg)](https://codecov.io/gh/lobodart/CheatyXML)

CheatyXML is a Swift framework designed to manage XML easily.

## Installation
### Cocoapods
If you're using **cocoapods**, just add `pod 'CheatyXML'` into your `Podfile` file.

### Manual
To install this, simply add the **.xcodeproj** to your project, and do not forget to link the **.framework**.

Whenever you want to use it in your code, simply type:
```swift
import CheatyXML
```

## Usage
Let's take the following XML content for all of our examples:
```xml
<blog version="1.0" creator="lobodart">
    <name>MyAwesomeBlog!</name>
    <users>
        <admin is_active="true">lobodart</admin>
        <moderator is_active="false">slash705</moderator>
        <moderator is_active="...">...</moderator>
        ...
    </users>
    <article>
        <title>My first article</title>
        <description>This is the first article</description>
        <infos>
            <date>2015-03-15 15:42:42</date>
            <rate>42</rate>
        </infos>
        ...
    </article>
    <article>
        ...
    </article>
    ...
</blog>
```

### Creating parser instance

##### Using an URL
```swift
let parser: CXMLParser! = CXMLParser(contentsOfURL: ...) // URL
```
##### Using a string
```swift
let parser: CXMLParser! = CXMLParser(string: ...) // String
```
##### Using data
```swift
let parser: CXMLParser! = CXMLParser(data: ...) // Data
```

### Retrieving an element using tags
Suppose we want to retrieve the `name` of our example:
```swift
let blogName: String! = parser["name"].stringValue // Returns a String
let blogName: String? = parser["name"].string // Returns an optional String
```
You can also use the `rootElement` if you to make your code clearer:
```swift
let element = parser.rootElement["name"] // is the same as the notation seen before
```

To access deeper elements, just chain :
```swift
let blogAdmin: String! = parser["users"]["admin"].stringValue
print(blogAdmin) // lobodart
```

### Working with multiple elements
Now let's take a look at the `article` element. We can see that our `blog` contains a few articles.

#### Get an element using its index
If we want to get the title of the first article, we can do it like this:
```swift
let firstArticleTitle: String! = parser["article", 0]["title"].stringValue
let firstArticleTitle: String! = parser["article"][0]["title"].stringValue
```

Both notations have the same effect. Choose the one you like most.

#### Browse children of an element
To iterate over **all** children of an element, just use the `for in` classic syntax:
```swift
for element in parser.rootElement {
    print(element.tagName)
}
```

This code will give us :
```
name
users
article
article
...
```

Now, to iterate over **specific** children of an element, the code is almost the same:
```swift
for element in parser.rootElement.elementsNamed("article") {
    print(element.tagName)
}
```

This time, it will give us :
```
article
article
...
```

Of course, you can use this method on any deeper elements (like `users` for example).

#### Number of children of an element
If you want to get the total number of children contained in an element, you can use this code:
```swift
// Suppose we have 3 moderators in our example
let numberOfElements: Int = parser["users"].numberOfChildElements
print(numberOfElements) // 4 (3 moderators + 1 admin)
```

Note that this code counts **all** child elements contained in `users`. Now suppose we want to get the number of moderators **only**. There are 2 different syntaxes. Once again, choose your favorite:
```swift
let numberOfElements: Int = parser["users"]["moderator"].count
let numberOfElements: Int = parser["users"].elementsNamed("moderator").count
```

### Type casting
CheatyXML allows you to cast tag/attribute values into some common types. You can get either optional or non-optional value for your cast.
```swift
let firstArticleRate = parser["article", 0]["rate"]
firstArticleRate.int // Optional(42)
firstArticleRate.intValue // 42
firstArticleRate.float // Optional(42.0)
firstArticleRate.floatValue // 42.0
```

If you are not sure about the type, use the optional cast. If you try to cast a value with an inappropriate caster, your app will crash.
```swift
let firstArticleTitle = parser["article", 0]["title"]
firstArticleTitle.string // Optional("My first article")
firstArticleTitle.stringValue // "My first article"
firstArticleTitle.int // nil
firstArticleTitle.intValue // CRASH!
```

### Missing tags
Until now, we always retrieved existing tags but what would happen if a tag doesn't exist? Let's take an example:
```swift
let articleDate: String! = parser["article", 0]["infos"]["date"].stringValue
print(articleDate) // 2015-03-15 15:42:42
let articleDateFail: String! = parser["articles", 0]["infos"]["date"].string // I intentionally add an 's' to 'article'
print(articleDateFail) // nil
```
> ###### Note
If you have any doubt, keep in mind that using `.string` is safer than using `.stringValue`. In the previous example, using `.stringValue` on `articleDateFail` will result in your application to crash.


### Attributes
#### Get one
```swift
let blogVersion = parser.rootElement.attribute("version")
let adminIsActive = parser["users"]["admin"].attribute("is_active")
```

You can also use the type casting on attributes:
```swift
let blogVersion = parser.rootElement.attribute("version").floatValue // 1.0
let creator = parser.rootElement.attribute("creator").stringValue // "lobodart"
```

#### Get all
```swift
let attributes = parser.rootElement.attributes // Will give you a [CXMLAttribute]
let dic = attributes.dictionary // Will give you a [String: String]
```

### TO-DO
- [ ] Add more Unit Tests
- [ ] Class mapping
- [ ] XML Generator
