[TOC]



# Memory Safety (内存安全)

Swift管理堆空间内存也是使用ARC机制，主要用3种引用关系：

1. 强引用 (strong reference)

   默认情况下不加任何修饰的话，都是强引用。

2. 弱引用 (weak reference)

   使用**weak**进行修饰，weak只能修饰var，并且不会对引用计数产生影响，实例销毁后，weak修饰的变量也会被置为nil，并且该设置不会出发属性观察器。

3. 无主引用 (unowned reference)

   使用**unowned**进行修饰，也不会对引用计数产生影响，实例销毁后仍然存储着实例的内存地址，并且这个时候如果试图访问无主引用，就会产生运行时错误。

   所以很明显，无主引用是很不安全的，开发中往往不建议用，除非在某些特定情况下。



## weak & unowned

weak & unowned只能修饰类的实例。

也就是说，如果下边例子中的Runnable没有遵守AnyObject的话，那么类型为Runnable的实例就不能用weak或者unowned修饰。

```swift
protocol Runnable: AnyObject {}
class Person: Runnable {}

do {
    weak var person1: Person?
    weak var person2: AnyObject?
    weak var person3: Runnable?
}

do {
    unowned var person1: Person?
    unowned var person2: AnyObject?
    unowned var person3: Runnable?
}
```



## autoreleasepool

Swift中我们依然可以使用autoreleasepool创建一个自动释放池。

不过，实际开发中，基本上看不到这种用法，所以我个人认为，只需要知道如何用就可以了。

```swift
class Person {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

autoreleasepool {
    let person = Person(name: "Eric")
    print(person.name)
}
```



## 循环引用

循环引用基本上是编程语言绕不过的一个难题，简而言之就是：**你中有我，我中有你，互相拥有彼此，导致谁都不舍得先死。**

上边说的 “谁都不舍得死” 的意思是说，引用类型相互引用，并且都是强引用，导致彼此都没办法释放内存。

最经典的就是代理和闭包很容易产生循环引用的问题，下边我们用闭包来举例，看看如何解决循环引用的问题。

大致列举以下几种情况：

**情况一：闭包作为类的属性**

下边的代码会产生循环引用，因为test函数执行完后，局部变量person并没有被释放 (*其deinit方法并没有被调用*)：

(*fn是person实例的属性，而fn闭包内部又强引用了person实例，相互引用，所以局部变量person实例无法被释放掉。*)

```swift
class Person {
    var fn: (() -> Void)?
    func run() { print("run") }
    deinit { print("deinit") }
    
}

func test() {
    let person = Person()
    person.fn = { person.run() }
}

test()
```

解决循环引用的方法就是用**weak**或者**unowned**来修饰其中一方的引用实例：

weak：

```swift
person.fn = { [weak person] in person?.run() }
```

weak，并自定义变量：

```swift
person.fn = { [weak weakPerson = person] in weakPerson?.run() }
```

unowned:

```swift
person.fn = { [unowned person] in person.run() }
```

unowned，并自定义变量：

```swift
person.fn = { [unowned unownedPerson = person] in unownedPerson.run() }
```

在定义fn的时候设置了初始值，也是同样的情况：

(此时，*fn必须用**lazy**进行修饰，因为在初始化的时候，闭包内部还不能访问self，只能通过lazy进行延后调用，以访问到self，并且self必须要明确地写出来，否则会编译报错。*)

```swift
class Person {
    lazy var fn: (() -> Void)? = { [weak self] in
        self?.run()
    }
    func run() { print("run") }
    deinit { print("deinit") }
    
}

func test() {
    let person = Person()
    person.fn?()
}

test()

//run
//deinit
```

> 注意
>
> - 捕获列表中也可以放其他的变量，如果真的有这样的需求的话：
>
>   ```swift
>   person.fn = { [unowned unownedPerson = person, a = 10 + 20] in
>       unownedPerson.run()
>       print(a)
>   }
>   ```
>
> - 如果闭包后面有小括号，即 闭包会被立即执行，那么就不会产生循环引用的问题。
>
>   ```swift
>   person.fn = {
>       person.run()
>   }()
>   ```
>
>   ```swift
>   lazy var fn: Void = {
>       run()
>   }()
>   ```

**情况二：逃逸闭包**

逃逸闭包一般当作函数参数进行传递，如果逃逸闭包内部捕获了类实例，也有可能产生循环引用的问题：

```swift
class Person {
    var fn: (() -> Void)?
    func run() { print("run") }
    deinit { print("deinit") }
}

do {
    let person = Person()

    func test(fn: @escaping (() -> Void)) {
        person.fn = fn
    }

    test { [weak person] in
        person?.run()
    }
    
    person.fn?()
}

//run
//deinit
```



## 内存访问冲突 (Conflicting Access to Memory)

Swift中，内存访问冲突可能会在两个访问符合以下条件时产生：

1. 至少一个是写入操作。
2. 它们访问的是同一块内存。
3. 它们的访问在同一时间发生。

示例：

❌：**Simultaneous accesses to 0x10de4e060, but modification requires exclusive access.**

```swift
var stepSize = 1

func increment(_ number: inout Int) {
    number += stepSize
}

increment(&stepSize)
```

更多例子，请参考官方文档：[Memory Safety](https://docs.swift.org/swift-book/LanguageGuide/MemorySafety.html#)

