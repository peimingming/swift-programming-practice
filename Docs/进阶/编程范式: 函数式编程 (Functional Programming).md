[TOC]



# 编程范式: 函数式编程 (Functional Programming)



## 参考资料

- [Functors, Applicatives, and Monads in Pictures](http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html)
- [Swift Functors, Applicatives, and Monads in Pictures](https://mokacoding.com/blog/functor-applicative-monads-in-pictures/)



## 本章的示例代码

[FunctionalProgramming.playground](../../Source/FunctionalProgramming.playground)



## Array的常见操作

### map flatMap compactMap

map: 将数组中的元素按照指定的算法进行映射，并返回一个新的数组。

```swift
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let newNumbers = numbers.map { "\($0)" }
    newNumbers // ["1", "2", "5", "-10", "2", "7"]
}
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    func double(_ value: Int) -> Int { value * 2 }
    let newNumbers = numbers.map(double)
    newNumbers // [2, 4, 10, -20, 4, 14]
}
do {
    let numbers = [1, 2, 3]
    let newNumbers = numbers.map { Array.init(repeating: $0, count: $0) }
    newNumbers // [[1], [2, 2], [3, 3, 3]]
}
do {
    let numbers = ["123", "Eric", "456", "789"]
    let newNumbers = numbers.map { Int($0) }
    newNumbers // [123, nil, 456, 789]
}
```

flatMap: 在map的基础上，flatMap如果发现算法的返回结果也是一个数组的话，会将该返回结果拆开并拼接到数组中。

```swift
do {
    let numbers = [1, 2, 3]
    let newNumbers = numbers.flatMap { Array.init(repeating: $0, count: $0) }
    newNumbers // [1, 2, 2, 3, 3, 3]
}
```

compactMap: 在map的基础上，compactMap如果发现算法的返回结果是一个nil (*Optional<xxx>.none*)的话，就会将该结果直接摒弃掉。

```swift
do {
    let numbers = ["123", "Eric", "456", "789"]
    let newNumbers = numbers.compactMap { Int($0) }
    newNumbers // [123, 456, 789]
}
```

### filter

使用指定的算法对数组进行过滤。

```swift
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let newNumbers = numbers.filter { $0 > 0 }
    newNumbers // [1, 2, 5, 2, 7]
}
```

### reduce

使用指定的算法将数组浓缩成另外一种类型的结果，常用来做数组的求和运算等。

```swift
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let reducedResult = numbers.reduce(0) { $0 + $1 }
    reducedResult // 7
}
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let reducedResult = numbers.reduce(0, +)
    reducedResult // 7
}
```

同样，根据reduce的特点，我们也可以使用其模拟map和filter的功能 (*了解即可，一般情况下不这么做，毕竟 **术业有专攻***)。

```swift
do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let mappedResult = numbers.map { $0 * 2 }
    mappedResult // [2, 4, 10, -20, 4, 14]
    let reducedResult = numbers.reduce([]) { $0 + [$1 * 2] }
    reducedResult // [2, 4, 10, -20, 4, 14]
}

do {
    let numbers = [1, 2, 5, -10, 2, 7]
    let mappedResult = numbers.filter { $0 > 0 }
    mappedResult // [1, 2, 5, 2, 7]
    let reducedResult = numbers.reduce([]) { $1 > 0 ? $0 + [$1] : $0 }
    reducedResult // [1, 2, 5, 2, 7]
}
```

### Array lazy的用法

以下代码使用了数组中的lazy功能去读取map后的元素，相对于直接一次性map完所有的数组元素来说，是一种优化。

即 **只有在真正需要读取newNumbers中的某一个元素的时候，才会去走map的方法，计算出新的值。**

```swift
let numbers = [1, 4, 2, 8, 0]
let newNumbers = numbers.lazy.map { (number: Int) -> String in
    print("mapping:", number)
    return "\(number * 2)"
}
print("mapped:", newNumbers[0])
print("mapped:", newNumbers[1])

//mapping: 1
//mapped: 2
//mapping: 4
//mapped: 8
```



## Optional的常见操作

数组中用到的高阶函数基本上在可选项中依然适用，比如`map`, `flatMap`.

一般情况下操作一个可选项的传统做法可能是先进行解包，再进行具体的操作，比如：

```swift
do {
    let number: Int? = 10
    let newNumber = (number != nil) ? (number! * 2) : nil
    print(newNumber as Any) // Optional(20)
}
```

> 注意
>
> 强制解包在实际开发中是禁止使用的，具体原因以及更多解包的操作详情请见章节 [Optionals (可选项)](../语法/Optionals%20(可选项).md)

这里要说的是，我们仍然可以使用函数式的做法来做相同的事情，提高代码的**可读性**和**简洁性**，示例如下：

### map

语法的语义很明显：

如果可选项有值的话，map内部的运算会进行先解包 -> 运算 -> 进行可选项包装再返回

如果可选项没有值的话，直接返回nil

```swift
do {
    let number: Int? = 10
    let newNumber = number.map { $0 * 2 }
    print(newNumber as Any) // Optional(20)
}
do {
    let number: Int? = nil
    let newNumber = number.map { $0 * 2 }
    print(newNumber as Any) // nil
}
```

另外一个可选项目中**??**(具体请参考 章节 [Optionals (可选项)](../语法/Optionals%20(可选项).md))的用法，结合函数式的用法，示例如下：

```swift
do {
    let score: Int? = 80
    let description1 = score != nil ? "score is \(score!)" : "no score"
    let description2 = score.map { "score is \($0)" } ?? "no score"
    print(description1) // score is 80
    print(description2) // score is 80
}
```

### flatMap

与map做对比，如果是flatMap的话，flatMap内部的运算会进行先解包 -> 运算 -> 如果运算结果是非可选项的话才进行一次包装

也就是说，如果flatMap内部的运算结构本来就是一个可选项的话，就不会进行二次包装

```swift
do {
    let number: Int? = 10
    let newNumber = number.map { Optional.some($0 * 2) }
    print(newNumber as Any) // Optional(Optional(20))
}
do {
    let number: Int? = 10
    let newNumber = number.flatMap { Optional.some($0 * 2) }
    print(newNumber as Any) // Optional(20)
}
```

另外一个函数式的用法是，可以把一个函数直接作为实参传递给flatMap，因为flatMap的参数本来也就是一个函数类型：

```swift
do {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd"
    let string: String? = "2021-01-26"
    let date1 = string != nil ? formatter.date(from: string!) : nil
    let date2 = string.flatMap(formatter.date)
    print(date1 as Any) // Optional(2021-01-26 00:00:00 +0000)
    print(date2 as Any) // Optional(2021-01-26 00:00:00 +0000)
}
```

因为flatMap不会对本身就是可选项的运算结果进行二次包装，所以也可以直接传入一些返回值可为选项的函数：

```swift
do {
    struct Person: CustomStringConvertible {
        let name: String
        let age: Int
        
        var description: String {
            return "name: \(name), age: \(age)"
        }
        
        init?(_ json: [String: Any]) {
            guard let name = json["name"] as? String,
                let age = json["age"] as? Int else {
                    return nil
            }
            self.name = name
            self.age = age
        }
    }
    
    let json: [String: Any]? = ["name": "Eric", "age": 18]
    let person1 = json != nil ? Person(json!) : nil
    let person2 = json.flatMap(Person.init)
    print(person1 as Any) // Optional(name: Eric, age: 18)
    print(person2 as Any) // Optional(name: Eric, age: 18)
}
```

### Array & Optional map

这里只是想说`func getPerson(...)`才是最佳的做法，其他的`func`只是为了配合演示，实现同样的功能，还能有其他的做法，但是实际开发中，这种绕路的做法就不要写了。

```swift
do {
    struct Person: CustomStringConvertible {
        let name: String
        let age: Int
        
        var description: String {
            return "name: \(name), age: \(age)"
        }
    }
    
    let people = [
        Person(name: "Eric", age: 18),
        Person(name: "Jack", age: 20),
        Person(name: "Tiger", age: 30)
    ]
    
    func getPerson(withName name: String) -> Person? {
        people.first { $0.name == name }
    }
    
    func getPerson1(withName name: String) -> Person? {
        let index = people.firstIndex { $0.name == name }
        return index != nil ? people[index!] : nil
    }
    
    func getPerson2(withName name: String) -> Person? {
        return people.firstIndex { $0.name == name }.map { people[$0] }
    }
    
    print(getPerson(withName: "Jack") as Any) // Optional(name: Jack, age: 20)
    print(getPerson1(withName: "Jack") as Any) // Optional(name: Jack, age: 20)
    print(getPerson2(withName: "Jack") as Any) // Optional(name: Jack, age: 20)
}
```



## 函数式编程 (Functional Programming)

### 概念

函数式编程(*FP*)是一种编程范式，也就是一种如何编写程序的方法论。

主要的思想：尽量把一些计算过程或者计算算法分解成一系列可复用函数的调用

主要的特征：函数可以像其他类型那样具有同等的地位 (*可以赋值给其他变量，也可以作为函数参数，返回值 等*)，可以被灵活使用，即，函数是 “**第一等公民**”。

函数式编程中的几个常见的概念：

- Higher-Order Function 高阶函数
- Function Currying 函数柯里化
- Functor 函子
- Applicative Function 适用函子
- Monad 单子

### FP的例子

接下来我们看一个例子：

计算表达式的值 - `[(number + 3) * 5 - 1] % 10 / 2`

**方法一：传统做法**

显然为了计算表达式的结果，下边的几个函数调用会嵌套在一起

```swift
do {
    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func subtract(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiply(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    let number = 1
    let result = divide(mod(subtract(multiply(add(number, 3), 5), 1), 10), 2)
    print(result) // 4
}
```

**方法二：FP做法**

使用 *函数式 + 自定义高级运算符* 的做法，代码看起来更加简洁

```swift
infix operator >>>: AdditionPrecedence
func >>><A, B, C>(f1: @escaping (A) -> B, f2: @escaping (B) -> C) -> (A) -> C { { f2(f1($0)) }}

do {
    func add(_ v: Int) -> (Int) -> Int { { $0 + v } }
    func subtract(_ v: Int) -> (Int) -> Int { { $0 - v } }
    func multiply(_ v: Int) -> (Int) -> Int { { $0 * v } }
    func divide(_ v: Int) -> (Int) -> Int { { $0 / v } }
    func mod(_ v: Int) -> (Int) -> Int { { $0 % v } }
    
    do {
        let number = 1
        let result = divide(2)(mod(10)(subtract(1)(multiply(5)(add(3)(number)))))
        print(result) // 4
    }
    
    do {
        let number = 1
        let f = add(3) >>> multiply(5) >>> subtract(1) >>> mod(10) >>> divide(2)
        let result = f(number)
        print(result) // 4
    }
}
```



## 高阶函数 (Higher-Order Function)

高阶函数的定义 (*至少满足一个条件的函数*)：

- 接受一个或多个函数作为参数输入 (*map, reduce, filter都符合这一条件，都是高阶函数*)
- 返回一个函数

FP编程中所定义的函数绝大多数都是高阶函数，比如：`func add(_ v: Int) -> (Int) -> Int { { $0 + v } }`



## 柯里化 (Currying)

定义：将一个接受多参数的函数转变成一系列只接受单个参数函数

`func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }`

⬇️ 柯里化

`func add(_ v: Int) -> (Int) -> Int { { $0 + v } }`

比如，可以将上边定义的传统的函数进行自动柯里化，以下就是 *自动柯里化 + 函数式 + 自定义高级运算符* 的例子：

```swift
prefix func ~<A, B, C>(f: @escaping (A, B) -> C) -> (B) -> (A) -> C { { b in { a in f(a, b) } } }

do {
    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func subtract(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiply(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    let number = 1
    let f = (~add)(3) >>> (~multiply)(5) >>> (~subtract)(1) >>> (~mod)(10) >>> (~divide)(2)
    let result = f(number)
    print("Currying result:", result) // 4
}
```



## 函子 (Functor)

函子：能支持map运算的类型，例如 Array & Optional

```swift
[1, 2, 3].map { $0 * 2 }
// public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]

Optional.some(10).map { $0 * 2 }
// public func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?
```

更多关于 Array 和 Optional 中map的用法，请见本文开始开始的示例



## 适用函子 (Applicative Functor)

适用函子：对任何一个函子，如果能支持以下运算，该函子就是一个适用函子

```swift
func pure<A>(_ value: A) -> F<A>
func <*><A, B>(f: F<(A) -> B>, value: F<A>) -> F<B>
```

自定义运算符如下：

```swift
infix operator <*>: AdditionPrecedence
```

### Array是适用函子

```swift
func <*><A, B>(fs: [((A) -> B)], values: [A]) -> [B] {
    var results = [B]()
    fs.forEach { f in values.forEach { results.append(f($0)) } }
    return results
}

do {
    func pure<A>(_ value: A) -> [A] { [value] }
    
    print("--- Array is an Applicative Functor ---")
    let pureResult = pure(10)
    print("pureResult =", pureResult)
    let fs: [(Int) -> Int] = [{ $0 * 2 }, { $0 * 3 }]
    let values = [1, 3, 6]
    let secondResult = fs <*> values
    print("secondResult =", secondResult)
}
```

### Optional是适用函子

```swift
func <*><A, B>(f: ((A) -> B)?, value: A?) -> B? {
    guard let f = f, let value = value else { return nil }
    return f(value)
}

do {
    func pure<A>(_ value: A) -> A? { value }
    
    print("--- Optional is an Applicative Functor ---")
    let pureResult = pure(10)
    print("pureResult =", pureResult as Any)
    let f: (Int) -> Int = { $0 * 2 }
    let secondResult = f <*> pureResult
    print("secondResult =", secondResult as Any)
}
```



## 单子 (Monad)

单子：对任何一个类型F，如果能支持以下运算，就可以称之为单子

```swift
func pure<A>(_ value: A) -> F<A>
func flatMap<A, B>(_ value: F<A>, _ f: (A) -> F<B>) -> F<B>
```

显然，Array 和 Optional都是单子，因为，首先，它们都支持pure (*上边已经举例过了*)，其次，他们在Swift标准库中都有`flatMap`的定义 (只不过Array的`flatMap`已经被废弃掉了，并用一个新的方法 - `compactMap` 进行了替换)：

```swift
[1, 2, 3].compactMap { $0 * 2 }
Optional.some(10).flatMap { $0 * 2 }
```

