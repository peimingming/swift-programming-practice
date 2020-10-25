[TOC]



# Properties (属性)

Swift中的属性可以分为两大类：

1. 实例属性 (Instance Properties)：只能通过实例去访问
   - 存储实例属性 (Stored Instance Properties)：存储在实例的内存中，每个实例都有一份
   - 计算实例属性 (Computed Instance Properties)：本质就是被限定了作用域的方法
2. 类型属性 (Type Properties)：只能通过类型去访问 (static修饰，如果是类也可以用class)
   - 存储类型属性 (Stored Type Properties)：整个程序运行过程中，只有一份内存，本质就是被限定了作用域的全局变量
   - 计算类型属性 (Computed Type Properties)：本质就是被限定了作用域的方法



## 实例属性

**存储实例属性**

- 存储在实例的内存中
- 结构体和类都可以定义存储实例属性
- 枚举不可以定义存储实例属性
- 严格来讲，在实例创建之后，使用存储实例属性之前，存储实例属性必须要有一个合适的初始化值 (*初始化值可以在初始化器中设置，也可以在定义属性的时候设置，这一点在 结构体和类 一章中有介绍*)

**计算实例属性**

- 本质就是被限定了作用域的方法
- 不占用实例的内存
- 结构体，枚举和类都可以定义计算实例属性
- 只能用var来定义，不能用let

来看一个例子：

```swift
struct Circle {
    var radius: Double
    var diameter: Double {
        set {
            radius = newValue / 2
        }
        get {
            radius * 2
        }
    }
}

var circle = Circle(radius: 15)
circle.diameter // 30

circle.diameter = 40
circle.radius
```

其中radius是存储实例属性，diameter是计算实例属性。

当然diameter的set里边除了通过newValue来获取传入的值之外，还可以自定义一个变量名来接收传入的值：

```swift
...
var diameter: Double {
    set(newDiameter) {
        radius = newDiameter / 2
    }
    ...
}
...
```

计算实例属性也可以默认只有get，写法如下：

写法一 (显示地定义get)：

```swift
...
var diameter: Double {
    get {
        radius * 2
    }
}
...
```

写法二 (默认就是get)：

```swift
...
var diameter: Double {
    radius * 2
}
...
```



## 延迟存储实例属性 (Lazy Stored Instance Properties)

使用lazy可以来定义一个延时存储属性，即 只有在该属性第一次被用到的时候才会进行初始化:

- lazy属性必须用var来定义
- lazy属性不是线程安全的 (见官方文档 [Lazy Stored Properties](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID255))

```swift
class Work {
    init() {
        print("Job init.")
    }
    
    func start() {
        print("Start working.")
    }
}

class Person {
    lazy var work = Work()
    
    init() {
        print("Person init.")
    }
    
    func onDuty() {
        print(#function, "is called.")
        work.start()
    }
}

let person = Person()
person.onDuty()

//Person init.
//onDuty() is called.
//Job init.
//Start working.
```

其实，lazy还有一种和闭包表达式结合起来的用法，在实际项目开发中比较常见：

```swift
lazy var work: Work = {
    // Some code requires complex or computationally expensive setup.
    // OR
    // Some code should not be performed unless or until it is needed.
    Work()
}()
```



## 属性观察器 (Property Observers)

可以为非lazy的var存储属性设置属性观察器。

```swift
struct Circle {
    var radius: Double {
        willSet {
            print("willSet:", newValue)
        }
        didSet {
            print("didSet:", oldValue)
        }
    }
}

var circle = Circle(radius: 15)
circle.radius = 10
circle.radius

//willSet: 10.0
//didSet: 15.0
```

属性观察器的特点：

- 在初始化器中设置属性不会触发属性观察器。

- 在定义属性的时候设置初始化值不会触发属性观察器。

- 在didSet中给自身属性赋值不会触发属性观察器。

- 变量名newValue / oldValue也可以进行自定义:

  ```swift
  struct Circle {
      var radius: Double {
          willSet(newCircle) {
              print("willSet:", newCircle)
          }
          didSet(oldCircle) {
              print("didSet:", oldCircle)
          }
      }
  }
  ```



## 全局变量 和 局部变量

存储属性和计算属性的特性同样也可以应用到**全局变量**和**局部变量**。



## In-Out参数

重新来研究一下将属性作为inout参数的一些特性：

```swift
struct Shape {
    var width: Int
    var side: Int {
        willSet {
            print("willSet:", newValue)
        }
        didSet {
            print("didSet:", oldValue, side)
        }
    }
    
    var girth: Int {
        set {
            width = newValue / side
            print("set girth:", newValue)
        }
        get {
            print("get girth")
            return width * side
        }
    }
    
    func show() {
        print("width: \(width), side: \(side), girth: \(girth)")
    }
}

func test(_ value: inout Int) {
    print(#function)
    value = 10
}

var shape = Shape(width: 2, side: 3)

test(&shape.width)
shape.show()

print("------------")

test(&shape.side)
shape.show()

print("------------")

test(&shape.girth)
shape.show()

//test(_:)
//get girth
//width: 10, side: 3, girth: 30
//------------
//test(_:)
//willSet: 10
//didSet: 3 10
//get girth
//width: 10, side: 10, girth: 100
//------------
//get girth
//test(_:)
//set girth: 10
//get girth
//width: 1, side: 10, girth: 10
```

之前在函数一章，输入输出参数那里介绍过：**inout的本质是引用传递**，但是为什么在将计算属性girth当成inout参数进行传递的时候，会先调用girth的get呢 (从上边打印结果可以看到先打印*get girth*，再打印函数调用*test(_:)*)？

直接上结论 (具体介绍请见 官方文档 [In-Out Parameters](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID545))：

1. 如果实参有物理内存地址，且没有设置属性观察器，直接将实参的内存地址传入函数，即 实参进行引用传递。
2. 如果实参是计算属性或者是拥有属性观察器的存储属性的话，遵循以下规则：
   1. 调用函数的时候，先复制实参的值到一个**副本**中，即一个临时变量。[get]
   2. 将**副本**的内存地址传递给函数 (副本进行引用传递)，在函数内部修改**副本**的值。
   3. 函数调用完成后，使用**副本**的值覆盖实参。[set]



## 类型属性 (Type Properties)

类型属性的本质就是被限定了作用域的全局变量：

1. 存储类型属性可以是var也可以是let, 但是必须要有一个初始值。
2. 存储类型属性默认就是就是lazy，并且是线程安全的，具体见 官方文档 [Type Properties](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID264)。
3. 枚举，结构体和类都可以定义存储类型属性，计算类型属性。

(*每生产一辆车，库存的count就+1*)

```swift
struct Car {
    private(set) static var count = 0
    
    init() {
        Car.count += 1
    }
}

_ = Car()
_ = Car()
_ = Car()

Car.count // 3
```



## 单例 (Singleton)

先看看Swift版本的单例实现：

(*使用struct / class来定义类型都可以，取决于具体的需求。*)

```swift
struct Singleton {
    static let shared = Singleton()
    
    private init() {}
}
```

上边如此简单的代码，是如何保证单例就是一个单例呢？

1. 类型属性是线程安全的，所以`static let shared = Singleton()`就可以保证`shared`永远都是同一个实例。
2. 私有化初始化器：`private init() {}`，就可以保证外界无法再次实例化`Singleton`。

