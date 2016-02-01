# CheatyXML
CheatyXML is a Swift framework designed to manage XML easily.

## Installation
To install this, simply add the **.xcodeproj** to your project, and do not forget to link the **.framework**.

If you're using **cocoapods**, just add `pod 'CheatyXML'` into your `Podfile` file.

Whenever you want to use it in your code, simply type :
```swift
import CheatyXML
```

## Usage
Let's take the following XML content for all of our examples :
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
        </infos>
        ...
    </article>
    <article>
        ...
    </article>
    ...
</blog>
```

There are different ways to create an instance of XMLParser.
##### Using an URL
```swift
let parser: XMLParser! = XMLParser(contentsOfURL: ...) // NSURL
```
##### Using a string
```swift
let parser: XMLParser! = XMLParser(string: ...) // String
```
##### Using data
```swift
let parser: XMLParser! = XMLParser(data: ...) // NSData
```
--
### Retrieving an element using tags
Suppose we want to retrieve the blog `name` of our example :
```swift
let blogName: String! = parser["name"].stringValue // Returns a String
let blogName: String? = parser["name"].string // Returns an optional String
```
> ###### Note
> You don't have to worry about the root element, but if you want to clarify your code, you can add `rootElement` :
```swift
let element = parser.rootElement["name"] // is the same as the notation seen before
```


If you want to access to deeper elements like `admin` for example, just chain :
```swift
let blogAdmin: String! = parser["users"]["admin"].stringValue
print(blogAdmin) // lobodart
```
--
### Working with multiple elements
Now let's take a look at the `article` element. Our `blog` element contains a couple of articles.
#### Get an element using its index
If we want to get the title of the first article, we can do it like this :
```swift
let firstArticleTitle: String! = parser["article", 0]["title"].stringValue
let firstArticleTitle: String! = parser["article"][0]["title"].stringValue
```
Both notation have the same effect. Choose the one you like most.
#### Browse children of an element
To iterate over **all** children of an element, just use the `for in` classic syntax :
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
Now, to iterate over **specific** children of an element, the code is almost the same :
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
If you want to get the total number of child elements contained in an element, you can use this code :
```swift
// Suppose we have 3 moderators in our example
let numberOfElements: Int = parser["users"].numberOfChildElements
print(numberOfElements) // 4
```
Note that this code counts **all** child elements contained in `users`. Now suppose we want to get the number of moderators **only**. There are 2 different syntaxes. Once again, choose your favorite one :
```swift
let numberOfElements: Int = parser["users"]["moderator"].count
let numberOfElements: Int = parser["users"].elementsNamed("moderator").count
```
--
### Missing tags
Until now, we always retrieved existing tags but what would happen if a tag doesn't exist ? Fortunaly for us, CheatyXML manages this case. Let's take an example :
```swift
let articleDate: String! = parser["article", 0]["infos"]["date"].stringValue
print(articleDate) // 2015-03-15 15:42:42
let articleDateFail: String! = parser["articles", 0]["infos"]["date"].string // I intentionally add an 's' to 'article'
print(articleDateFail) // nil
```
> ###### Note
If you have doubts on your chain, keep in mind that using `.string` is safer than using `.stringValue`. In the previous example, using `.stringValue` on `articleDateFail` will result in your application to crash.


In sum, you can make mistakes without worrying about your application crash as long as you don't use `.stringValue`.

--
### Attributes
With CheatyXML, getting any attribute is very simple.
```swift
let blogVersion = parser.rootElement.attributes["version"]
```
Another example using a deeper element :
```swift
let adminIsActive = parser["users"]["admin"].attributes["is_active"]
```
