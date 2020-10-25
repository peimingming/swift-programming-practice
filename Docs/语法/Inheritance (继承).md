[TOC]



# Inheritance (继承)

Swift中只有类支持继承，值类型(枚举和结构体)不支持继承。

Objective-C的所有类必须要继承自NSObject(默认基类)，但是Swift中并没有这样的规定。

即，你可以像下边这样定义一个*没有任何父类*的**基类**：

```swift
class Person {
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
```



## 重写 (Overriding)

子类可以重写父类的下标，方法 和 属性，并且必须在重写的实体前显示地加上override关键字。



## 重写实例方法和下标

Animal是基类，是Dog的父类，Dog是Animal的子类。

```swift
class Animal {
    func speak() {
        print("Animal speak")
    }
    
    subscript(index: Int) -> Int {
        index
    }
}

let animal = Animal()
animal.speak() // Animal speak
animal[6] // 6
```

```swift
class Dog: Animal {
    override func speak() {
        super.speak()
        print("Dog speak")
    }
    
    override subscript(index: Int) -> Int {
        index + 1
    }
}

let dog = Dog()
dog.speak()
//Animal speak
//Dog speak

dog[6] // 7
```



## 重写类型方法和下标

1. 被class修饰的类型方法或者下标，可以被子类重写，而被static修饰的不可以(*这一点也是static和class的唯一区别*)。
2. 被重写后的类型方法或者下标，可以被class或者static修饰，即下边的例子中，Dog的方法`override class func speak()`也可以写成`override static func speak()`。

```swift
class Animal {
    class func speak() {
        print("Animal speak")
    }
    
    class subscript(index: Int) -> Int {
        index
    }
}

Animal.speak() // Animal speak
Animal[6] // 6
```

```swift
class Dog: Animal {
    override class func speak() {
        super.speak()
        print("Dog speak")
    }
    
    override class subscript(index: Int) -> Int {
        index + 1
    }
}

Dog.speak()
//Animal speak
//Dog speak

Dog[6] // 7
```



## 重写属性

重写属性大概有以下几个规则：

1. 子类可以将父类的属性(存储属性，计算属性)重写为计算属性。
2. 子类不可以将父类的属性(存储属性，计算属性)重写为存储属性。
3. 子类不能重写let属性。
4. 子类重写后的属性权限，不能小于父类属性的权限，即如果父类的属性是只读的，那么子类重写后的属性可以是只读，也可以是可读可写的，如果父类的属性是可读可写的，那么子类重写后的属性必须也是可读可写的。



## 重写实例属性

1. 重写实例存储属性radius为一个实例计算属性。
2. 重写实例计算属性diameter。

```swift
class Circle {
    var radius = 0
    var diameter: Int {
        set {
            print("Circle setDiameter.")
            radius = newValue / 2
        }
        get {
            print("Circle getDiameter.")
            return radius * 2
        }
    }
}

let circle = Circle()
circle.radius = 6
circle.diameter
//Circle getDiameter.
//12

circle.diameter = 20 // Circle setDiameter.
circle.radius // 10
```

```swift
class SubCircle: Circle {
    override var radius: Int {
        set {
            print("SubCircle setRadius.")
            super.radius = newValue > 0 ? newValue : 0
        }
        get {
            print("SubCircle getRadius.")
            return super.radius
        }
    }
    
    override var diameter: Int {
        set {
            print("SubCircle setDiameter.")
            super.diameter = newValue > 0 ? newValue : 0
        }
        get {
            print("SubCircle getDiameter.")
            return super.diameter
        }
    }
}

let subCircle = SubCircle()
subCircle.radius = 6 // SubCircle setRadius.

subCircle.diameter
//SubCircle getDiameter.
//Circle getDiameter.
//SubCircle getRadius.
//12

subCircle.diameter = 30
//SubCircle setDiameter.
//Circle setDiameter.
//SubCircle setRadius.

subCircle.radius
//SubCircle getRadius.
//15
```



## 重写类型属性

1. 类型存储属性只能被static修饰，所以类型属性不能被重写，所以示例中的radius不能被重写。
2. 类型计算属性只有被class修饰的时候，才可以被重写，所以示例中的类型计算属性diameter可以被重写，而且被重写后的计算属性可以使用static或者class进行修饰。

```swift
class Circle {
    static var radius = 0
    class var diameter: Int {
        set {
            print("Circle setDiameter.")
            radius = newValue / 2
        }
        get {
            print("Circle getDiameter.")
            return radius * 2
        }
    }
}

Circle.radius = 6
Circle.diameter
//Circle getDiameter.
//12

Circle.diameter = 20 // Circle setDiameter.
Circle.radius // 10
```

```swift
class SubCircle: Circle {
    override static var diameter: Int {
        set {
            print("SubCircle setDiameter.")
            super.diameter = newValue > 0 ? newValue : 0
        }
        get {
            print("SubCircle getDiameter.")
            return super.diameter
        }
    }
}

SubCircle.radius = 6
SubCircle.diameter
//SubCircle getDiameter.
//Circle getDiameter.
//12

SubCircle.diameter = 30
//SubCircle setDiameter.
//Circle setDiameter.

SubCircle.radius //15
```



## 属性观察器

可以在子类中为父类存储属性(除过let属性)添加属性观察器。

```swift
class Circle {
    var radius = 1
}

class SubCircle: Circle {
    override var radius: Int {
        willSet {
            print("SubCircle willSet radius: ", newValue)
        }
        didSet {
            print("SubCircle didSet radius", "oldValue: \(oldValue)", "currentValue: \(radius)")
        }
    }
}

var subCircle = SubCircle()
subCircle.radius = 10
//SubCircle willSet radius:  10
//SubCircle didSet radius oldValue: 1 currentValue: 10
```

```swift
class Circle {
    var radius = 1 {
        willSet {
            print("Circle willSet radius: ", newValue)
        }
        didSet {
            print("Circle didSet radius", "oldValue: \(oldValue)", "currentValue: \(radius)")
        }
    }
}

class SubCircle: Circle {
    override var radius: Int {
        willSet {
            print("SubCircle willSet radius: ", newValue)
        }
        didSet {
            print("SubCircle didSet radius", "oldValue: \(oldValue)", "currentValue: \(radius)")
        }
    }
}

var subCircle = SubCircle()
subCircle.radius = 10
//SubCircle willSet radius:  10
//Circle willSet radius:  10
//Circle didSet radius oldValue: 1 currentValue: 10
//SubCircle didSet radius oldValue: 1 currentValue: 10
```

可以在子类中为父类计算属性(除过只读计算属性)添加属性观察器。

(*这里需要注意的是，第一行打印`Circle get radius`的原因是 在整个set之前先调用了get并将返回值赋值给了oldValue。*)

```swift
class Circle {
    var radius: Int {
        set {
            print("Circle set radius: ", newValue)
        }
        get {
            print("Circle get radius")
            return 20
        }
    }
}

class SubCircle: Circle {
    override var radius: Int {
        willSet {
            print("SubCircle willSet radius: ", newValue)
        }
        didSet {
            print("SubCircle didSet radius", "oldValue: \(oldValue)", "currentValue: \(radius)")
        }
    }
}

var subCircle = SubCircle()
subCircle.radius = 10
//Circle get radius
//SubCircle willSet radius:  10
//Circle set radius:  10
//Circle get radius
//SubCircle didSet radius oldValue: 5 currentValue: 20
```

```swift
class Circle {
    class var radius: Int {
        set {
            print("Circle set radius: ", newValue)
        }
        get {
            print("Circle get radius")
            return 20
        }
    }
}

class SubCircle: Circle {
    override static var radius: Int {
        willSet {
            print("SubCircle willSet radius: ", newValue)
        }
        didSet {
            print("SubCircle didSet radius", "oldValue: \(oldValue)", "currentValue: \(radius)")
        }
    }
}

SubCircle.radius = 10
//Circle get radius
//SubCircle willSet radius:  10
//Circle set radius:  10
//Circle get radius
//SubCircle didSet radius oldValue: 5 currentValue: 20
```



## 多态

继承中的多态：父类指针指向子类对象。

Swift在多态的实现上类似于C++，都是用的虚表(虚函数表)，关于虚表，请参考另外一个仓库 lifelong-learning 里边的C++ -> 继承 -> 虚表。

```swift
class Animal {
    func speak() {
        print("Animal speak.")
    }
    
    func run() {
        print("Animal run.")
    }
}

class Dog: Animal {
    override func speak() {
        print("Dog speak.")
    }
    
    override func run() {
        print("Dog run.")
    }
    
    func jump() {
        print("Dog jump.")
    }
}

var animal = Animal()
animal.speak() // Animal speak.
animal.run() // Animal run.

animal = Dog()
animal.speak() // Dog speak.
animal.run() // Dog run.
```



## final

被final修饰的类，是不可以被继承的。

被final修饰的方法，下标 和 属性，是不可以被重写的。