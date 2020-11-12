[TOC]



# Methods (方法)

方法其实就是被限定了作用域的函数，关于函数的介绍，请阅读 函数 章节。



## 实例方法 和 类型方法

```swift
class Car {
    private static var count = 0
    
    let brand: String
    
    init(brand: String) {
        self.brand = brand
        Car.count += 1
    }
    
    static func getCount() -> Int {
        self.count
    }
    
    func getBrand() -> String {
        brand
    }
}

let bmw = Car(brand: "BMW")
let chevron = Car(brand: "Chevron")
let porsche = Car(brand: "Porsche")

Car.getCount() // 3

bmw.getBrand() // BMW
```

方法分两类：

1. 实例方法，只能通过实例去访问。

   比如上例中的：`bmw.getBrand()`

2. 类型方法，可以用static 或者 class去修饰，只能通过类型去访问。

   比如上例中的：`Car.getCount()`，并且在该类型方法内部，Car.self.count, self.count 和 count完全等价。



## mutating

枚举和结构体的实例方法默认不能修改自身或者自身的属性，除非用mutating对实例方法进行修饰。

枚举

```swift
enum Switch {
    case on
    case off
    
    mutating func toggle() {
        switch self {
        case .on:
            self = .off
        case .off:
            self = .on
        }
    }
}

var lampSwitch = Switch.on
lampSwitch.toggle()
print(lampSwitch) // off
```

结构体

```swift
struct Point {
    var x: Int
    var y: Int
    
    mutating func moveBy(_ x: Int, _ y: Int) {
        self.x += x
        self.y += y
    }
}

var point = Point(x: 1, y: 2)
point.moveBy(2, 2)
print(point) // Point(x: 3, y: 4)
```



## @discardableResult

如果一个有返回值的函数，在被调用的时候，返回值可以不被读取，就可以用@discardableResult来修饰该函数，否则系统就会报一个警告：⚠️**Result of call to 'xxx' is unused**

```swift
struct Point {
    var x: Int
    var y: Int
    
    @discardableResult
    mutating func moveBy(_ x: Int, _ y: Int) -> (Int, Int) {
        self.x += x
        self.y += y
        return (self.x, self.y)
    }
}

var point = Point(x: 1, y: 2)
point.moveBy(2, 2)
print(point) // Point(x: 3, y: 4)
```



## 将方法赋值给一个变量或者常量

可以像函数那样，将方法赋值给一个变量或者常量。

这里实例方法和类型方法有点不同，示例如下：

```swift
struct Person {
    func run() {
        print("method run.")
    }
    
    static func run() {
        print("static method run.")
    }
}

let method1: (Person) -> () -> () = Person.run
method1(Person())() // method run.

let method2: () -> () = Person.run
method2() // static method run.
```

