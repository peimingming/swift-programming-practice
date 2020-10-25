[TOC]



# Generics (泛型)

泛型：用一个自定义的标识符代表类型，并在编译阶段再确定具体的类型，这样可以将类型参数化，提高代码复用率，减少代码量。



## 泛型函数

比如写一个交换两个Int值的函数，我们可能会直接这样写：

(*关于交换函数，我们就直接写最精简的版本：(v1, v2) = (v2, v1)，详情请见 **基础语法** 章节 **元组***)

```swift
func swapIntValues(_ v1: inout Int, _ v2: inout Int) {
    (v1, v2) = (v2, v1)
}

var a = 10
var b = 20

swapIntValues(&a, &b)

a // 20
b // 10
```

如果，此时又需要一个交换两个String的函数，那么又需要写一个新的交换函数：

```swift
func swapStringValues(_ v1: inout String, _ v2: inout String) {
    (v1, v2) = (v2, v1)
}

var a = "123"
var b = "456"

swapStringValues(&a, &b)

a // "456"
b // "123"
```

不难发现：**交换函数的格式和实现都是一模一样的**。

对于这种情况，使用泛型来定义函数，就可以避免写大量重复的代码，示例如下：

```swift
func swapValues<T>(_ v1: inout T, _ v2: inout T) {
    (v1, v2) = (v2, v1)
}

do {
    var a = 10
    var b = 20
    swapValues(&a, &b)
    a // 20
    b // 10
}

do {
    var a = 10.5
    var b = 20.9
    swapValues(&a, &b)
    a // 20.9
    b // 10.5
}

do {
    var a = "123"
    var b = "456"
    swapValues(&a, &b)
    a // "456"
    b // "123"
}
```

另外，如果要将泛型函数赋值给一个变量或者常量的话，必须要明确地指定泛型的类型：

```swift
var a = 10
var b = 20
let fn: (inout Int, inout Int) -> Void = swapValues
fn(&a, &b)
a
b
```

> 注意
>
> 我们这里仅仅是用函数swapValues来做泛型函数的演示，实际开发中，我们并不需要写这样的函数，因为Swift标准库中已经定义了一个用来做值交换的函数swap。



## 泛型类型

假如要写一个可以进行栈(*一种数据结构：FILO*)操作的类型Stack, 那么，栈中的元素就可以用泛型来定义，示例如下：

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

var stack = Stack<Int>()
stack.push(100)
stack.push(200)
stack.push(300)

stack.top // 300
stack.size // 3

stack.pop() // 300
stack.pop() // 200
stack.pop() // 100
stack.pop() // nil

stack.top // nil
stack.size // 0
```

其中要注意的是，我们在上边初始化一个Stack的实例的时候，明确地指定了泛型的具体类型：`Stack<Int>()`，其实我们也可以用一个初始化器通过传参来指定泛型类型，这种方式也是Swift中的类型推断，即：

**Swift可以自动推断范型的类型，如果没有足够的线索进行推断的话，那么就得明确地指定类型。**

该初始化器可以这样定义和使用：

```swift
init(_ first: Element) {
    elements.append(first)
}

var stack = Stack(20)
```



## 协议中的关联类型 (Associated Type)

协议中可以定义关联类型，即 给协议中用到的类型定义一个泛型，由遵守协议的实际类型指定泛型类型，并且一个协议中可以定义多个关联类型。

上边的Stack也可以改写如下：(*Stackable协议抽取栈的接口，Stack遵守Stackable进行具体的实现*)

```swift
protocol Stackable {
    associatedtype Element
    mutating func push(_ element: Element)
    mutating func pop() -> Element?
    var top: Element? { get }
    var size: Int { get }
}

struct Stack<Element>: Stackable {
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

var stack = Stack<Int>()
stack.push(100)
stack.push(200)
stack.push(300)

stack.top // 300
stack.size // 3

stack.pop() // 300
stack.pop() // 200
stack.pop() // 100
stack.pop() // nil

stack.top // nil
stack.size // 0
```

上边的代码也是进行了类型推断：

即 在类型Stack中，我们并没有明确地指定协议Stackable的关联类型，Swift就会默认Stack的泛型Element就是Stackable中的关联类型Element，这里你也可以将Stack中的泛型命名成其他的标识符，由开发者自己决定，比如`Stack<E>`。

也可以明确地指定关联类型的实际类型：

即在Stack内部写上，`typealias Element = Element` 或者 `typealias E = Element` 或者 `typealias Int = Element`，只不过通常情况下这样的代码很废，本着精简代码的原则，并充分利用Swift类型推断的特性，**可写可不写的代码就不要写了**。



## 类型约束

类型约束：对泛型类型进行约束限定，比如限定其继承指定的父类，遵守一些协议或者符合其他一些条件。

比如，本章的函数swapValues，就可以对其泛型T进行约束：

```swift
protocol Runnable {}
class Person {}

func swapValues<T: Person & Runnable>(_ v1: inout T, _ v2: inout T) {
    (v1, v2) = (v2, v1)
}
```

还可以使用where关键字对泛型类型进行进一步的约束：

```swift
protocol Runnable {
    associatedtype Speed
    associatedtype Species
}
class Person {}

func swapValues<T: Person & Runnable>(_ v1: inout T, _ v2: inout T) where T.Speed == Int, T.Species: Hashable {
    (v1, v2) = (v2, v1)
}
```

类型中的类型约束和函数中的类型约束大同小异，在此不再赘述。



## 协议中的关联类型注意点

如果协议中没有关联类型的话，代码可以这样写，不会有任何问题：

```swift
protocol Runnable {}
struct Person: Runnable {}
struct Car: Runnable {}

func get(_ type: Int) -> Runnable {
    if type == 0 {
        return Car()
    } else {
        return Person()
    }
}
```

但是，如果有关联类型的话，就会编译报错：

(*原因：编译阶段无法确定关联类型的实际类型。*)

❌ **Protocol 'Runnable' can only be used as a generic constraint because it has Self or associated type requirements**

```swift
protocol Runnable {
    associatedtype Speed
    var speed: Speed { get }
}

struct Person: Runnable {
    var speed: Int { 10 }
}

struct Car: Runnable {
    var speed: Double { 60.0 }
}

func get(_ type: Int) -> Runnable {
    if type == 0 {
        return Car()
    } else {
        return Person()
    }
}
```

解决方案有两个：

***解决方案 一：使用范型***

```swift
func get<T: Runnable>(_ type: Int) -> T? {
    if type == 0 {
        return Car() as? T
    } else {
        return Person() as? T
    }
}

let car: Car? = get(0)
car?.speed // 60.0

let person: Person? = get(1)
person?.speed // 10
```

***解决方案 二：使用不透明类型来限定只能返回一种类型 (具体见官方文档 [Opaque Types](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html))***

(*some关键字不仅仅可以用在返回值类型上*)

```swift
func get(_ type: Int) -> some Runnable {
    return Car()
}
```



## 泛型举例：可选项的本质

可选项的本质：**一个拥有泛型的枚举类型。**

Swift标准库中对可选项的定义：

```swift
public enum Optional<Wrapped> : ExpressibleByNilLiteral {
    case none
    case some(Wrapped)
    public init(_ some: Wrapped)
    ...
}
```

先来看看通常如何定义一个可选项并进行赋值操作：

*代码块 一*

```swift
var age: Int? = 10
age = 20
age = nil
```

也可以像使用一个枚举类型那样去改写 代码块 一：

*代码块 二*

```swift
var age: Optional<Int> = .some(10) // or var age = Optional(10)
age = .some(20)
age = .none
```

也可以混合使用：

*代码块 三*

```swift
var age: Optional<Int> = 10
age = .some(20)
age = nil
```

**代码块 一 二 三 完全等价。**

那么，这么多写法，实际开发中用哪种合适呢？我觉得都可以，如果非要选一个最合适的，那就是 代码块 一，原因：很精简。

再来看看可选项的使用，如何进行解包，列举主要的几种：

*解包方式 一*

```swift
if let age = age {
    print(age)
} else {
    print("age is nil")
}
```

*解包方式 二*

```swift
switch age {
case let age?:
    print(age)
case nil:
    print("age is nil")
}
```

*解包方式 三*

```swift
switch age {
case .some(let age):
    print(age)
case .none:
    print("age is nil")
}
```

对于上述代码不做过多的解释，无非就是枚举的使用和可选项语法糖，同样的，实际开发中写哪个都可以，用哪个合适，得看具体的使用场景。

> 注意
>
> 更多关于可选项的内容，请阅读 **可选项** 章节。

