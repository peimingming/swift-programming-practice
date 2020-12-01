[TOC]



# Literals (字面量)



## 标准库中类型的字面量初始化

直接可以写出来的常量就叫做字面量，比如下边例子中的 `10` `false` `Eric`就是字面量：

```swift
let age = 10 // Int
let isRed = false // Bool
let name = "Eric" // String
```

字面量的默认类型定义如下：

```swift
public typealias IntegerLiteralType = Int
public typealias FloatLiteralType = Double
public typealias BooleanLiteralType = Bool
public typealias StringLiteralType = String
```

也就是说，整型字面量的默认类型为Int, 浮点型字面量的默认类型为Double, 布尔型字面量的默认类型为Bool, 字符串字面量的默认类型为String。

我们也可以自定义默认类型，比如 (***但是这种做法真的没有什么意义，一般不建议这样做。***)：

```swift
public typealias IntegerLiteralType = UInt8

let age = 10
age is UInt8 // true
```



## 字面量协议

很多Swift标准库中定义的类型都支持直接通过字面量进行初始化，是因为他们遵守了对应的协议：

```swift
Bool: ExpressibleByBooleanLiteral
Int: ExpressibleByIntegerLiteral
Float: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
String: ExpressibleByStringLiteral
Array, Set: ExpressibleByArrayLiteral
Dictionary: ExpressibleByDictionaryLiteral
Optional: ExpressibleByNilLiteral
```

示例：

```swift
let b: Bool = false
let i: Int = 10
let f0: Float = 10
let f1: Float = 10.0
let d0: Double = 10
let d1: Double = 10.0
let s: String = "123"
let array: Array = [1, 2, 3]
let set: Set = [1, 2, 3]
let dictionary: Dictionary = ["key": "value"]
let o: Optional<Int> = nil
```

所以，如果我们自定义的类型也希望能直接通过字面量进行初始化的话，就只需要遵守对应的字面量协议，实现对应的方法即可：

```swift
struct Student: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral {
    var age: Double = 0
    var name: String = ""
    
    init(integerLiteral value: Int) {
        age = Double(value)
    }
    
    init(floatLiteral value: Double) {
        age = value
    }
    
    init(stringLiteral value: String) {
        name = value
    }
}

let gouzi: Student = "🐶"
print(gouzi) // Student(age: 0.0, name: "🐶")
```

其他的字面量协议的使用也大同小异。

> 注意：
>
> 开发中，知道有这种用法即可，视实际情况决定要不要用字面量去初始化一个自定义实例。
>
> 建议：**尽量用中规中矩的初始化方法去初始化实例，以保证代码的语义清晰。**

