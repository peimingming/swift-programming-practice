[TOC]



# Structures and Classes (结构体和类)

结构体是值类型 (*枚举也是值类型*)，而类是引用类型，有什么区别呢？下边会做详细介绍。



## 结构体 (struct)

Swift标准库中，绝大多数的类型都是结构体，比如: Bool, Int, Float, Double, String, Array, Dictionary 等。

这里有一个简单的规则：如果类型定义成结构体能够满足需求，那么就尽量用结构体而不是类。

```swift
struct Person {
    let name: String
    let age: Int
    let city: String
}
```

所有的结构体都有一个编译器自动生成的初始化器(*initializer*)，用来初始化所有的存储属性，宗旨只有一个：**就是确保所有的存储属性都具有初始值。**

Person就有一个自动生成的初始化器：`init(name: String, age: Int, city: String)`:

```swift
let person = Person(name: "Jack", age: 20, city: "Xi'an")
```

如果我们改动一下Person，给属性city设置一个初始化值，如下：

```swift
struct Person {
    let name: String
    let age: Int
    let city: String = "Xi'an"
}
```

这个时候，编译器自动生成的初始化器就会变成：`init(name: String, age: Int)`:

```swift
let person = Person(name: "Jack", age: 20)
```

当然我们也可以自定义符合一定需求的初始化器，这个时候，编译器就不会自动帮我们生成了：

```swift
struct Person {
    let name: String
    let age: Int
    let city: String
    
    init() {
        name = "unknown"
        age = 0
        city = "unknown"
    }
    
    init(name: String) {
        self.name = name
        age = 0
        city = "unknown"
    }
}

let person1 = Person()
let person2 = Person(name: "Jack")
```

> 一般情况下使用系统自动创建的初始化器即可，如果自动生成的初始化器不能够满足需求时，比如我们需要public初始化器，或者需要自定义初始化器参数，那么再自定义。



## 结构体的内存结构

```swift
struct Point {
    let x: Int
    let y: Int
}

print(MemoryLayout<Point>.size) // 16
print(MemoryLayout<Point>.stride) // 16
print(MemoryLayout<Point>.alignment) // 8
```

由于结构体是值类型，所以存储属性直接存储在结构体对象的内存中，这个结论也可以用我高仿的另外一个工具：`memory-in-swift`进行进一步证明。



## 类 (class)

类的定义和结构体基本差不多，只不过编译器并不会为类自动生成可以传入参数的初始化器。

所以，如果直接像下边这样定义一个类的话，就会报错：

**Class 'Point' has no initializers**

```swift
class Point {
    let x: Int
    let y: Int
}
```

这个时候我们就需要 (*以下两种做法等价*)：

1. 给每一个属性设置一个初始值，这样，编译器就会自动生成一个无参的初始化器：

   ```swift
   class Point {
       let x: Int = 0
       let y: Int = 0
   }
   
   let point = Point()
   ```

2. 或者，直接自己创建一个初始化器（下边创建一个无参的初始化器来做例子）:

   ```swift
   class Point {
       let x: Int
       let y: Int
       
       init() {
           x = 0
           y = 0
       }
   }
   
   let point = Point()
   ```

不管是给每一个存储属性设置初始化值或者是在初始化器中对存储属性进行初始化，其实我们只需要记住一个原则即可，和结构体中的规则一样：**就是确保所有的存储属性都具有初始值。**



## 结构体和类的区别

开头我们说过结构体和枚举是值类型，而类是引用类型 (指针类型)，有什么区别呢？

结论：

结构体的的对象内容 (存储属性)直接存储在对象的内存空间中，而类由于是指针类型，指针所指向的另外一块内存空间才真正存储着其对象内容。同样可以使用我高仿的工具：`memory-in-swift`来进行验证。

例如有两个类型，分别是类和结构体：

```swift
class Size {
    let width: Int = 2
    let height: Int = 3
}

struct Point {
    let x: Int
    let y: Int
}
```

使用工具`momory-in-swift`来打印内存结构：

```swift
func test() {
    var size = Size()
    var point = Point(x: 10, y: 20)
    show(value: &size)
    show(reference: size)
    show(value: &point)
}
/*
-------------- function: test(), Size --------------
pointer: 0x00007ffeefbff460
memory: 0x00000001031494d0
size: 8

-------------- function: test(), Size --------------
pointer: 0x00000001031494d0
memory: 0x0000000100009990 0x0000000200000002 0x0000000000000002 0x0000000000000003
size: 32

-------------- function: test(), Point --------------
pointer: 0x00007ffeefbff450
memory: 0x000000000000000a 0x0000000000000014
size: 16
*/
```

可以看到size和point由于是函数的局部变量，内存地址分别是：0x00007ffeefbff460 & 0x00007ffeefbff450，即栈空间的内存地址。

前一个内存地址存储着size对象堆空间的地址：0x00000001031494d0，也就是size对象内容所在的内存空间，里边有32个字节，前16个字节存储着类型信息和引用计数相关的信息，后16个字节，分别存储着其存储属性width和height的值2和3。

后一个内存地址直接存储着point对象的内容，即存储属性x和y的值10和20。



## 值类型和引用类型的区别

1. 内存结构上，请见[结构体和类的区别](##结构体和类的区别)。
2. 基于内存结构的不同：值类型一般(*因为Swift标准库中的部分类型，有`copy-on-write`技术，即只有在进行写操作的时候才会进行深拷贝，比如`Array`*)在进行赋值操作的时候，会进行深拷贝(*deep copy*)。而引用类型在进行赋值操作的时候，仅仅会拷贝指针，即有多个指针指向同一块内存空间，也就是浅拷贝(shallow copy)。



## 嵌套类型

在一个类型的内部是可以定义其他类型的，这样做就是为了限定这些类型的作用域，或者也可以完全对外界隐藏这些类型，这就是所谓的嵌套类型，例子如下：

```swift
struct Poker {
    enum Suit: Character {
        case spades = "♠️", hearts = "♥️", diamonds = "♦️", clubs = "♣️"
    }
    enum Rank: Int {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
    }
}

print(Poker.Suit.spades.rawValue) // ♠️

var suit = Poker.Suit.hearts
suit = .clubs

var rank = Poker.Rank.ace
rank = .two
```



## 定义方法

定义在类型内部的函数，即方法，具体请见 `函数` 章节。