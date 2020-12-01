[TOC]



# Patterns (模式匹配)



## 模式 (Pattern)

模式是用于匹配的规则，比如Switch的case，捕捉错误的catch，if/guard/while/for语句的条件等。

Swift中的模式有：

1. 通配符模式 (Wildcard Pattern)
2. 标识符模式 (Identifier Pattern)
3. 值绑定模式 (Value-Binding Pattern)
4. 元组模式 (Tuple Pattern)
5. 枚举case模式 (Enumeration Case Pattern)
6. 可选模式 (Optional Pattern)
7. 类型转换模式 (Type-Casting Patterns)
8. 表达式模式 (Expression Pattern)



## 通配符模式 (Wildcard Pattern)

`_` 用来匹配任何值

`_?` 用来匹配非nil的值

```swift
enum Species {
    case human(name: String, age: Int?)
    case animal(name: String, age: Int?)
}

func match(species: Species) {
    switch species {
    case .human(name: let name, age: _):
        print("human", name)
    case .animal(name: let name, age: _?):
        print("animal", name)
    default:
        print("other")
    }
}

match(species: .human(name: "Eric", age: 30)) // human Eric
match(species: .human(name: "Jack", age: nil)) // human Jack
match(species: .animal(name: "Wang Cai", age: 6)) // animal Wang Cai
match(species: .animal(name: "xiao qiang", age: nil)) // other
```



## 标识符模式 (Identifier Pattern)

给变量、常量名赋值

```swift
let name = "Eric"
var isRed = false
```



## 值绑定模式 (Value-Binding Pattern)

```swift
let point = (3, 2)
switch point {
case let (x, y):
    print("(\(x), \(y))") // (3, 2)
}
```



## 元组模式 (Tuple Pattern)

```swift
let points = [(1, 2), (3, 4), (10, 8)]
for (x, _) in points {
    print(x)
}

//1
//3
//10
```

```swift
let name: String? = "Eric"
let age = 30
let info: Any = [1, 2, 3]

switch (name, age, info) {
case (let name?, _, _):
    print(name) // Eric
case (_, _, _ as String):
    print("The info is of type String")
default:
    print("other")
}
```

```swift
let scores = ["Eric": 100, "Jack": 99, "Rose": 90]
for (name, score) in scores {
    print(name, score)
}

//Rose 90
//Eric 100
//Jack 99
```



## 枚举case模式 (Enumeration Case Pattern)

开发中，可能会碰见这样的代码：

```swift
enum BiometryType {
    case touchID
    case faceID
    case none
}

let type = BiometryType.touchID

if case .touchID = type {
    print("Biometry type is touchID.")
}
```

其实，这种写法就是枚举case模式匹配，if case语句等价于只写了一个case的switch语句，换句话说，**if case的用法和switch case的用法一模一样。**

其实上边的代码也可以直接写成：

```swift
if type == .touchID {
    print("Biometry type is touchID.")
}
```

但是，如果枚举BiometryType的case里有了关联值，那么普通的if判断就用不了了，就得使用if case或者switch case了。

if case除了用来做枚举case的匹配，还有更多的用法：

```swift
let age = 9

if case 0...9 = age {
    print("\(age) is in the range \(0...9).") // 9 is in the range 0...9.
}

func test() {
    guard case 0...9 = age else {
        return
    }
    print("\(age) is in the range \(0...9).") // 9 is in the range 0...9.
}
test()

switch age {
case 0...9:
    print("\(age) is in the range \(0...9).") // 9 is in the range 0...9.
default:
    break
}
```

```swift
let ages: [Int?] = [1, 3, 5, nil, 4]
for case nil in ages {
    print("nil value in ages.") // nil value in ages.
}
```

```swift
let points = [(1, 2), (4, 3), (0, 0)]
for case let (x, 0) in points {
    print(x) // 0
}
```

> 注意
>
> 显然，上边的代码还可以用更多的方式来做，比如，可以通过添加where关键字来达到条件判断的作用：
>
> ```swift
> let ages: [Int?] = [1, 3, 5, nil, 4]
> for x in ages where x == nil {
>     print("nil value in ages.") // nil value in ages.
> }
> ```
>
> 但是很明显，for case的语句看起来更加精简，可以理解为它的内部实现已经包装了 x == nil 这样的算法。



## 可选模式 (Optional Pattern)

```swift
let age: Int? = 9

if case let age? = age {
    print(age)
}

let ages: [Int?] = [1, 3, 5, nil, 4]
for case let age? in ages {
    print(age)
}
//1
//3
//5
//4

func match(_ number: Int?) {
    switch number {
    case 2?:
        print(2)
    case 4?:
        print(4)
    case 6?:
        print(6)
    case _?:
        print("other")
    case _:
        print("nil")
    }
}
match(4) // 4
match(100) // other
match(nil) // nil
```



## 类型转换模式 (Type-Casting Patterns)

**is** (*用来做类型判断*)

其实下边这段代码和直接写 `number is Int`等价，这里只是为了介绍模式匹配的用法：

```swift
let number: Any = 6
switch number {
case is Int:
    print("Int") // Int
default:
    break
}
```

**as** (*用来做类型转换*)

```swift
class Animal {
    func eat() {
        print("\(type(of: self)) eat.")
    }
}

class Dog: Animal {
    func run() {
        print("\(type(of: self)) run.")
    }
}

class Cat: Animal {
    func jump() {
        print("\(type(of: self)) jump.")
    }
}

func match(_ animal: Animal) {
    switch animal {
    case let dog as Dog:
        dog.eat()
        dog.run()
    case is Cat:
        animal.eat()
    default:
        break
    }
}

match(Animal())

match(Dog())
//Dog eat.
//Dog run.

match(Cat())
//Cat eat.
```



## 表达式模式 (Expression Pattern)

```swift
let point = (1, 2)

switch point {
case (0, 0):
    print("\(point) is at the origin.")
case (-2...2, -2...2):
    print("\(point) is near the origin.") // (1, 2) is near the origin.
default:
    print(point)
}
```



## 自定义表达式模式

开发中也许碰见过这样的代码：

```swift
let statusCode = 403

if 401..<404 ~= statusCode {
    print("Login session time out.") // Login session time out.
}
```

> **解读一下这段代码：**
>
> 首先 `~=` 是一个Swift标准库中定义的运算符，而类型Range提供了该运算符的实现 - `public static func ~= (pattern: Range<Bound>, value: Bound) -> Bool`, 所以上边的代码其实就是一个运算符函数的调用而已。`401..<404`是该运算符函数的第一个参数，`statusCode`是该运算符函数的第二个参数。
>
> 其次，这个运算符内部的实现也很好猜 (*其实也不用猜，直接去Swift官方github上看源码就行了，这里我们姑且猜一下。*)，有可能这样写 - `pattern.contains(value)`。
>
> 所以这段代码的语义就非常清晰了 - **用模式 `401..<404` 和值 statusCode 进行匹配，并返回匹配结果，而运算符函数内部定义了具体的匹配算法。**

那么，我们同样可以为类型(*系统的 和 自定义的*)自定义运算符 `~=` 的匹配规则，示例：

```swift
struct Student {
    let name: String
    let score: Int
    
    static func ~= (pattern: Int, student: Student) -> Bool {
        pattern <= student.score
    }
    
    static func ~= (pattern: Range<Int>, student: Student) -> Bool {
        pattern.contains(student.score)
    }
    
    static func ~= (pattern: ClosedRange<Int>, student: Student) -> Bool {
        pattern.contains(student.score)
    }
}

let student = Student(name: "Eric", score: 90)
90 ~= student // true
80..<91 ~= student // true
80...90 ~= student // true
```

也可以这样用：

**很显然我们可以通过自定义运算符 ~= 来自定义模式匹配的规则。**

case 后边的内容是运算符函数 `~=` 的第一个参数 `pattern`，需要进行模式匹配的值是第二个参数。

```swift
let student = Student(name: "Eric", score: 90)
90 ~= student // true
80..<91 ~= student // true
80...90 ~= student // true

switch student {
case 90:
    print("A") // A
case 80..<90:
    print("B")
case 60...79:
    print("C")
default:
    print("D")
}

if case 90 = student {
    print("A") // A
}

let information = (student, "A")
if case let (90, text) = information {
    print(text) // A
}
```



## 更多自定义表达式的用法

> 注意
>
> 基于上边的知识，以下代码不做过多解释，另外，以下代码有一些函数式编程的思想，详情请见 **函数式编程** 章节。

**String** (*自定义是否包含前后缀的模式匹配规则*)

```swift
extension String {
    static func ~=(pattern: (String) -> Bool, value: String) -> Bool {
        pattern(value)
    }
}

func has(prefix: String) -> (String) -> Bool { { $0.hasPrefix(prefix) } }
func has(suffix: String) -> (String) -> Bool { { $0.hasSuffix(suffix) } }

let name = "Jackie"

switch name {
case has(prefix: "J"), has(suffix: "k"):
    print("Starts with J, or ends with k.")
default:
    break
}
```

**Int** (*自定义奇偶判断以及大小比较的模式匹配规则*)

```swift
func isOdd(_ i: Int) -> Bool { i % 2 != 0 }
func isEven(_ i: Int) -> Bool { i % 2 == 0 }

extension Int {
    static func ~=(pattern: (Int) -> Bool, value: Int) -> Bool {
        pattern(value)
    }
}

let age = -10

switch age {
case isEven:
    print("\(age) is even.")
case isOdd:
    print("\(age) is odd.")
default:
    print("other")
}
```

```swift
prefix operator ~>
prefix operator ~>=
prefix operator ~<
prefix operator ~<=

prefix func ~>(_ i: Int) -> (Int) -> Bool { { $0 > i } }
prefix func ~>=(_ i: Int) -> (Int) -> Bool { { $0 >= i } }
prefix func ~<(_ i: Int) -> (Int) -> Bool { { $0 < i } }
prefix func ~<=(_ i: Int) -> (Int) -> Bool { { $0 <= i } }

let age = 10

switch age {
case ~>0:
    print("\(age) > 0")
default:
    break
}
// 10 > 0
```

