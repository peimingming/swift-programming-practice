[TOC]



# Protocols (协议)

协议：用来定义方法，属性，下标的声明，协议可以被枚举，结构体 和 类来遵守 (多个协议用逗号隔开)。

Apple在2015年的WWDC上提出了POP (*Protocol-Oriented Programming 面向协议编程*)的思想，完全不同于OOP(*Object-Oriented Programming 面向对象编程*)，前者强调将需求的声明和实现分离开来，面向接口编程，即 在Swift开发中使用协议来定义需求，由一个个具体的实体类型来遵守协议，针对需求，提供具体的实现。详情请看官方视频：[Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/)。

Swift开发中，我们通常倾向于将公共需求抽取到协议中，而不是父类，充分利用编程语言的语法特性，面向协议编程，使得代码更具有封装性，面向协议编程的思想在Swift组件化开发中优势更加突出。



## 协议的基本规则

```swift
protocol Drawable {
    func draw()
    var x: Int { get set }
    var y: Int { get }
    subscript(index: Int) -> Int { get set }
}
```

1. 协议中定义方法时不能设置默认参数值，默认参数值只能在实体类型中设置。
2. 默认情况下，协议中定义的需求必须全部实现。
3. 协议中定义的需求，可以通过extension的方式设置成optional，具体请见 **扩展** 章节。



## 协议中的属性

1. 协议中定义属性时必须用var关键字。
2. 实现协议时的属性权限要不小于协议中定义的属性权限。
   1. 如果协议中定义的属性，可读可写，那么既可以用var存储属性，也可以用计算属性去实现。
   2. 如果协议中定义的属性，只读，那么用任何属性都可以实现。

所以以下两种方式都可以实现Drawable协议：

方式一：存储属性

```swift
struct Person: Drawable {
    var x: Int = 0
    var y: Int = 0
    
    func draw() { print("Person draw.") }
    
    subscript(index: Int) -> Int {
        get { index }
        set {}
    }
}
```

方式二：计算属性

```swift
struct Person: Drawable {
    var x: Int {
        get { 0 }
        set {}
    }
    var y: Int { 0 }
    
    func draw() { print("Person draw.") }
    
    subscript(index: Int) -> Int {
        get { index }
        set {}
    }
}
```



## static & class

为了保证通用，协议中必须用static定义类型方法，类型属性 和 类型下标，这样，实现的时候既可以用static，也可以用class。

要实现协议Drawable, 类型既可以用struct，也可以用class，并且具体的需求实现既可以用static，也可以用class来修饰：

```swift
protocol Drawable {
    static func draw()
}
```

实现一：类型 struct + 修饰 static

```swift
struct Person: Drawable {
    static func draw() {
        print("Person draw.")
    }
}
```

实现二：类型 class + 修饰 static

```swift
class Person: Drawable {
    static func draw() {
        print("Person draw.")
    }
}
```

实现三：类型 class + 修饰 class

```swift
class Person: Drawable {
    class func draw() {
        print("Person draw.")
    }
}
```



## mutating

值类型(*枚举 和 结构体*)如果要在其遵守的协议的实例方法实现中修改自身内存，那么协议中的实例方法需要用mutating修饰。

引用类型(*类*)则不受此约束。

```swift
protocol Drawable {
    mutating func draw()
}
```

实现一：结构体

```swift
struct Person: Drawable {
    var location: Int = 0
    
    mutating func draw() {
        location = 10
        print("Person draw.")
    }
}
```

实现二：类

```swift
class Person: Drawable {
    var location: Int = 0
    
    func draw() {
        location = 10
        print("Person draw.")
    }
}
```



## 初始化器 (int)

协议中定义初始化器：

1. 非final类实现时必须加上required关键字。

   ```swift
   protocol Drawable {
       init(x: Int, y: Int)
   }
   
   class Person: Drawable {
       required init(x: Int, y: Int) {}
   }
   
   final class Dog: Drawable {
       init(x: Int, y: Int) {}
   }
   ```

2. 如果从协议实现的初始化器，刚好是重写了父类的指定初始化器，那么改初始化器必须同时加上required 和 override关键字。

   ```swift
   protocol Drawable {
       init(x: Int, y: Int)
   }
   
   class Animal {
       init(x: Int, y: Int) {}
   }
   
   class Dog: Animal, Drawable {
       required override init(x: Int, y: Int) {
           super.init(x: x, y: y)
       }
   }
   ```

3. 协议中定义的init!, init?, 可以用init, init!, init?去实现。

4. 协议中定义的init，可以用init, init?去实现。



## 协议继承

一个协议可以继承其他的协议：

```swift
protocol Protocol1: Protocol2, Protocol3 {
    // requirements
}
```

多个协议也可以组合在一起：

(*协议组合中也可以组合类，但是由于Swift是单继承，所以最多只能放一个类进去，关于继承，请查看 **继承** 章节。*)

```swift
typealias ProtocolGroup = Protocol1 & Protocol2 & Protocol3
```



## CaseIterable

枚举类型遵守CaseIterable协议的话，我们就可以调用该协议中的类型属性allCases来获取所有的case：

```swift
enum Test: CaseIterable {
    case one
    case two
    case three
}

Test.allCases.forEach {
    print($0)
}

//one
//two
//three
```



## CustomStringConvertible & CustomDebugStringConvertible

类型遵守CustomStringConvertible 和 CustomDebugStringConvertible都可以自定义实例的打印字符串：

1. print方法调用的是CustomStringConvertible协议中定义的description。
2. debugPrint, po(*lldb指令：关于lldb指令，请查看 **内存窥探** 章节*)调用的是CustomDebugStringConvertible的debugDescription

```swift
struct Person: CustomStringConvertible, CustomDebugStringConvertible {
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    var description: String {
        """
        \(#function)
        name: \(name)
        age: \(age)
        """
    }
    
    var debugDescription: String {
        """
        \(#function)
        name: \(name)
        age: \(age)
        """
    }
}

let xm = Person(name: "xm", age: 10)

print(xm)
//description
//name: xm
//age: 10

debugPrint(xm)
//debugDescription
//name: xm
//age: 10
```



## Any & AnyObject

Any就可以代表任意类型 (枚举，结构体，类，函数类型，元组 等等)。

AnyObject代表任意类类型：

1. 协议后边如果写上`: AnyObject`，那么只有类才可以遵守该协议。
2. 协议后边写上`: class`，也代表只有类才可以遵守该协议。



## is & as? as! as

is用来判断是否为某种类型：

```swift
10 is Int // true
```

as用来做类型转换。

在实际开发中 as!(强制类型转换) 也是禁用的，因为一旦转换不成功，程序就会崩溃。

```swift
protocol Runnable {
    func run()
}

struct Student: Runnable {
    func run() {
        print("Student run.")
    }
    
    func study() {
        print("Student study.")
    }
}

var xm: Any = 10
(xm as? Student)?.run() // run is not invoked.

xm = Student()

(xm as? Student)?.study() // Student study.
(xm as! Student).study() // Student study.
(xm as? Runnable)?.run() // Student run.

"123" as NSString

123 as Double

enum CustomError: Error {
    case one
    case two
    case three
}

CustomError.one as NSError
```



## X.self, X.Type & AnyClass

X.self是一个元类型(metadata)指针，存放着类型信息。

X.Type是X.self的类型。

AnyClass代表任何类的元类型指针的类型，系统定义的别名：`public typealias AnyClass = AnyObject.Type`。

```swift
class Person {}
class Student: Person {}

var personType: Person.Type = Person.self
var studentType: Student.Type = Student.self

personType = Student.self

var anyType: AnyObject.Type = Person.self
anyType = Student.self

var anyType2: AnyClass = Person.self
anyType2 = Student.self

var person = Person()
var personType2 = type(of: person)
Person.self == personType2 // true
```

**应用**：

批量实例化：

```swift
class Animal { required init() {} }
class Dog: Animal {}
class Cat: Animal {}
class Pig: Animal {}

let animalPointers: [Animal.Type] = [Dog.self, Cat.self, Pig.self]
let animals = animalPointers.map { $0.init() }
```

调用runtime方法获取对象占用的实际内存空间大小：

```swift
class Person {
    let age: Int = 0
}

class_getInstanceSize(Person.self)
```



## Self

大写的Self代表当前类型。在协议中使用Self(*参数或者返回值*)，Self代表实现协议的具体类型。

```swift
protocol Runnable {
    func test() -> Self
}

class Person: Runnable {
    required init() {}
    func test() -> Self {
        type(of: self).init()
    }
}

class Student: Person {}

let person = Person()
print(person.test()) // Person

let student = Student()
print(student.test()) // Student
```