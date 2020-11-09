[TOC]



# Extensions (扩展)

Swift中的扩展有点类似于Objective-C中的范畴(Category)，但是Swift中的扩展不需要命名。

**扩展可以：**

为枚举，结构体，类 和 协议添加新功能(方法，计算属性，下标，(便捷)初始化器，嵌套类型，协议 等)。

**扩展不能：**

- 不能覆盖原有的功能。
- 不能添加存储属性，不能向已有的属性添加属性观察器。
- 不能添加父类。
- 不能添加指定初始化器，不能添加required修饰的初始化器，不能添加反初始化器。



## 扩展计算属性、下标、方法 和 嵌套类型

直接举几个例子就可以了。

(*关于具体的属性、下标、方法 和 嵌套类型(枚举，结构体 和 类)请参考对应的章节。*)

**扩展计算属性** 

*直接摘抄官方的例子*

```swift
extension Double {
    var km: Double { self * 1_000 }
    var m: Double { self }
    var dm: Double { self / 10 }
    var cm: Double { self / 100 }
    var mm: Double { self / 1_000 }
}

let number = 10.0
number.km // 10_000
number.m // 10
number.dm // 1
number.cm // 0.1
number.mm // 0.01
```

*给Int扩展一个计算属性*

```swift
extension Int {
    var digits: Int {
        var temp = self
        var result = 0
        while true {
            temp /= 10
            result += 1
            if temp == 0 { break }
        }
        return result
    }
}

123.digits // 3
```

**扩展下标**

*给数组扩展一个允许越界的下标*

```swift
extension Array {
    subscript(nullable index: Int) -> Element? {
        guard (startIndex..<endIndex).contains(index) else {
            return nil
        }
        return self[index]
    }
}

let array = [10, 20, 30]
array[nullable: 0] // 10
array[nullable: 6] // nil
```

*给Int扩展一个下标*

```swift
extension Int {
    subscript(digitalIndex: Int) -> Int {
        guard digitalIndex < self.digits else {
            return 0
        }
        var decimalBase = 1
        (0..<digitalIndex).forEach { _ in decimalBase *= 10 }
        return (self / decimalBase) % 10
    }
}

123[0] // 3
123[100] // 0
```

**扩展方法**

*给Int扩展方法*

```swift
extension Int {
    func `repeat`(task: () -> Void) {
        (0..<self).forEach { _ in task() }
    }
    
    func square() -> Int { self * self }
}

3.repeat {
    print("I am 3.")
}
//I am 3.
//I am 3.
//I am 3.

6.square() // 36
```

**扩展嵌套类型**

*给Int扩展嵌套类型*

```swift
extension Int {
    enum Kind { case negative, zero, positive }
    var kind: Kind {
        switch self {
        case 0:
            return .zero
        case let x where x < 0:
            return .negative
        default: return .positive
        }
    }
}

12.kind // positive
```



## 扩展初始化器

**在扩展中定义初始化器，那么编译器默认生成的初始化器也存在。**

(*关于初始化器的规则，请参考 **初始化** 章节。*)

```swift
struct Point {
    let x: Int, y: Int
}

extension Point {
    init() {
        self.x = 0
        self.y = 0
    }
}

Point()
Point(x: 1, y: 2)
```

**不能为类扩展指定初始化器 和 required修饰的初始化器。**



## 扩展协议

**在实际开发中，协议的实现都是通过扩展来定义的，这个同样也是官方推荐的做法。**

> 注意
>
> 如果一个类型已经实现了协议中的所有需求，但是类型的定义中并没有遵守该协议，那么就可以使用扩展来让他遵守这个协议，比如，下边例子中的==运算符如果已经定义在了Person类型中，那么只需要用扩展来声明一下遵守Equatable这个协议即可：
>
> ```swift
> extension Person: Equatable {}
> ```

```swift
class Person {
    let age: Int
    let name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.age == rhs.age && lhs.name == rhs.name
    }
}
```

**可以给已有的协议扩展需求。**

> 注意
>
> 下边例子中，直接给协议BinaryInteger扩展方法，也就意味着所有的整数类型都可以拥有该扩展功能，因为所有的整数类型都遵守BinaryInteger协议。

```swift
extension BinaryInteger {
    var isOdd: Bool { self % 2 != 0 }
}

3.isOdd
```

**可以给协议扩展默认实现，同时也实现了可选协议的效果。**

```swift
protocol TestProtocol {
    func test1()
}

extension TestProtocol {
    func test1() {
        print("TestProtocol test1.")
    }
    
    func test2() {
        print("TestProtocol test2.")
    }
}

class TestClass: TestProtocol {}

let cls = TestClass()
cls.test1() // TestProtocol test1.
cls.test2() // TestProtocol test2.
```

但是如果TestClass中已经提供了test1 和 test2 的实现，那么就会执行类中的实现：

```swift
class TestClass: TestProtocol {
    func test1() {
        print("TestClass test1.")
    }
    
    func test2() {
        print("TestClass test2.")
    }
}

let cls = TestClass()
cls.test1() // TestClass test1.
cls.test2() // TestClass test2.
```

如果限定了cls的类型为TestProtocol的话，那么test1会调用类中的实现，而test2会直接调用协议中的实现：

```swift
class TestClass: TestProtocol {
    func test1() {
        print("TestClass test1.")
    }
    
    func test2() {
        print("TestClass test2.")
    }
}

let cls: TestProtocol = TestClass()
cls.test1() // TestClass test1.
cls.test2() // TestProtocol test2.
```



## 扩展泛型

扩展中仍然可以使用原类型中的泛型类型。

```swift
struct Stack<Element> {
    var elements = [Element]()
    
    mutating func push(_ element: Element) {
        elements.append(element)
    }
    
    mutating func pop() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeLast()
    }
    
    var top: Element? { elements.last }
    
    var size: Int { elements.count }
}

extension Stack {
    func getTop() -> Element? { top }
}

extension Stack: Equatable where Element: Equatable {
    static func == (lhs: Stack, rhs: Stack) -> Bool {
        lhs.elements == rhs.elements
    }
}
```

