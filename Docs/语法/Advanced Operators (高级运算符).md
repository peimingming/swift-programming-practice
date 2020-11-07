[TOC]



# Advanced Operators (高级运算符)

除过+, -, *, /这些基本运算符，Swift也支持一些高级运算符，比如位运算符，溢出运算符 和 自定义运算符。



## 位运算符 (Bitwise Operators)

C语言拥有的位运算符，基本上都可以原封不对地对应到Swift，比如：

~：按位取反

&：按位与

|: 按位或

^: 按位异或

<<, >>: 按位左移，右移 (*如果是有符号数字的话，符号位不会移动*)

使用位运算可以直接操作二进制，并且可以写一些替代操作，比如 除以2，可以这样写：`value >> 2`。

具体的用法可以参考官方文档：[Bitwise Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID29)。



## 溢出运算符 (Overflow Operators)

默认情况下，如果运算符(`+ - *`)溢出时，就会抛出运行时错误(*相关内容，请查看 **错误处理** 章节*)，即 程序会闪退。

示例：以下操作都会导致运行时错误

❌ **error: arithmetic operation '255 + 1' (on type 'UInt8') results in an overflow**

```swift
UInt8.max + 1
UInt8.min - 1
UInt8.max * 2
```

使用溢出运算符(`&+ &- &*`)可以避免运行时错误，即 溢出的二进制位会被直接舍弃:

```swift
UInt8.max &+ 1 // 0
UInt8.min &- 1 // 255
UInt8.max &* 2 // 254
```



## 运算符重载 (Operators Overload)

枚举，结构体 和 类都可以为Swift标准库中定义的运算符提供自定义的实现，这种操作叫做：**运算符重载**。

任何标准库中定义的运算符都可以进行重载，以下列举部分作为示例：

- 运算符大致分为三种 prefix, infix, potfix，即 前缀 中缀 后缀, 默认情况下都是infix，其他情况需要明确指定关键字。
- 运算符的定义其实本质上就是函数，以下示例的运算符定义风格与Swift标准库的运算符定义风格基本一致，包括运算符的命名缩进，参数标签的命名 等，命名规范这里也建议采用和官方一致的做法。
- 运算符其实也可以定义成全局函数，但是这里使用static，并将其作用域局限在类型中是一种推荐的做法。
- 示例中用到了extension 扩展，其实也可以将所有的运算符定义放在struct xxx { }中，关于扩展，请参考 **扩展** 章节。

```swift
struct Point {
    let x: Int, y: Int
}
```

```swift
extension Point {
    static func + (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static prefix func - (operand: Point) -> Point {
        Point(x: -operand.x, y: -operand.y)
    }
    
    static func += (lhs: inout Point, rhs: Point) {
        lhs = lhs + rhs
    }
    
    static prefix func ++ (operand: inout Point) -> Point {
        operand += Point(x: 1, y: 1)
        return operand
    }
    
    static postfix func ++ (operand: inout Point) -> Point {
        defer {
            operand += Point(x: 1, y: 1)
        }
        return operand
    }
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }
}
```

```swift
do {
    let point1 = Point(x: 20, y: 30)
    let point2 = Point(x: 10, y: 10)
    print(point1 + point2) // Point(x: 30, y: 40)
}

do {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 10, y: 10)
    print(point1 - point2) // Point(x: 0, y: 10)
}

do {
    let point = Point(x: 20, y: 30)
    print(-point) // Point(x: -20, y: -30)
}

do {
    var point = Point(x: 20, y: 30)
    point += Point(x: 10, y: 10)
    print(point) // Point(x: 30, y: 40)
}

do {
    var point = Point(x: 20, y: 30)
    print(++point) // Point(x: 21, y: 31)
    print(point) // Point(x: 21, y: 31)
}

do {
    var point = Point(x: 20, y: 30)
    print(point++) // Point(x: 20, y: 30)
    print(point) // Point(x: 21, y: 31)
}

do {
    let point1 = Point(x: 20, y: 30)
    let point2 = Point(x: 20, y: 30)
    print(point1 == point2) // true
}
```



## Equatable协议

遵守Equatable协议的类型的实例之间可以使用 ==, != 运算符。

```swift
struct Point: Equatable {
    let x: Int, y: Int
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }
}

let point1 = Point(x: 20, y: 30)
let point2 = Point(x: 20, y: 30)
print(point1 == point2) // true
```

这里还有一些细节需要注意，以下三种情况，默认拥有Equatable的实现：

1. 没有关联值的枚举类型。
2. 遵守Equatable协议的枚举，并且其关联值也遵守Equatable协议。
3. 遵守Equatable协议的结构体，并且其实例存储属性也遵守Equatable协议。

拓展：用在**类(class)**实例上，用来比较对象的存储地址是否相等的运算符 ===, !==

```swift
class Point {
    let x: Int, y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

let point1 = Point(x: 20, y: 30)
let point2 = Point(x: 20, y: 30)
let point3 = point1

point1 !== point2 // true
point1 === point3 // true
```



## Comparable协议

遵守Comparable协议的类型的实例之间可以使用 >, <, >=, <= 运算符。

示例：比较student的大小的规则 - score大的student大，如果score相等，那么年龄小的student大。

```swift
struct Student: Comparable {
    let age: Int
    let score: Int
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.score < rhs.score)
            ||
        ((lhs.score == rhs.score) && (lhs.age > rhs.age))
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        !(lhs > rhs)
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        (lhs.score > rhs.score)
            ||
        ((lhs.score == rhs.score) && (lhs.age < rhs.age))
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        !(lhs < rhs)
    }
}

let student1 = Student(age: 20, score: 100)
let student2 = Student(age: 10, score: 99)
let student3 = Student(age: 20, score: 100)

student1 > student2 // true
student1 >= student2 // true

student1 >= student3 // true
student1 <= student3 // true

student2 < student3 // true
student2 <= student3 // true
```



## 自定义运算符 (Custom Operators)

Swift允许自定义运算符：

1. 在全局作用域使用operator进行声明。

   ```pseudocode
   prefix operator 前缀运算符
   infix operator 中缀运算符
   postfix operator 后缀运算符
   ```

2. 可以指定优先级组。

   ```pseudocode
   precedencegroup PlusMinusPrecedence {
       higherThan: 比谁的优先级高
       lowerThan: 比谁的优先级低
       associativity: 结合性(left/right/none)
       assignment: true代表在可选链操作中拥有跟赋值运算符一样的优先级(见示例代码 - testAssignment)
   }
   ```
   

示例：

```swift
precedencegroup PlusMinusPrecedence {
    higherThan: AdditionPrecedence
    lowerThan: MultiplicationPrecedence
    associativity: none
    assignment: true
}

prefix operator +++
infix operator +-: PlusMinusPrecedence

struct Point {
    let x: Int, y: Int
    
    static prefix func +++ (operand: inout Point) -> Point {
        operand = Point(x: operand.x * 2, y: operand.y * 2)
        return operand
    }
    
    static func +- (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y - rhs.y)
    }
}

do {
    var point = Point(x: 10, y: 20)
    let newPoint = +++point
    print(point) // Point(x: 20, y: 40)
    print(newPoint) // Point(x: 20, y: 40)
}

do {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 11, y: 22)
    print(point1 +- point2) // Point(x: 21, y: -2)
}

func testAssignment() {
    struct Animal {
        let point: Point
    }
    
    var newPoint: Point {
        print(#function)
        return Point(x: 10, y: 20)
    }
    let animal: Animal? = nil
    print((animal?.point +- newPoint) as Any) // nil
}

testAssignment()
```

> 注意
>
> 更多关于自定义运算符的细节，请查看官方文档：[Operator Declarations](https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations) [Precedence Group Declaration](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_operator-declaration)。
>
> 另外，自定义运算符在函数式编程中被大量使用，会使代码的语义更加清晰，具体请见 **函数式编程** 章节。

