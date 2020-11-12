[TOC]



# Access Control (访问控制)



## 访问控制修饰符

Swift提供了5个访问控制级别的修饰符 (*优先级从高到低*)：

> 注意
>
> 实体：被访问控制修饰符修饰的内容。

1. open

   允许在定义实体的模块 和 其他模块访问，允许其他模块进行继承，重写 (open只适用于类和类的成员)。

2. public

   允许在定义实体的模块 和 其他模块访问，但是不允许其他模块进行继承，重写。

3. internal

   *(一般情况下，默认就是internal。)*

   只允许在定义实体的模块中访问，不允许在其他模块中访问。

4. fileprivate

   只允许在定义实体的源文件中访问。

5. private

   只允许在定义实体的封闭声明中访问。



## 访问控制的规则

直接摘抄[官方](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html#ID5)的说法：

> *No entity can be defined in terms of another entity that has a lower (more restrictive) access level.*

即：一个实体不可以被更低访问级别的实体定义。

- 变量/常量类型 >= 变量/常量
- 参数，返回值类型 >= 函数
- 父类 >= 子类
- 父类型 >= 子协议
- 原类型 >= typealias
- 原是值类型，关联值类型 >= 枚举类型
- 定义类型A的时候用到的其他类型 >= 类型A
- ...



## 元组类型

元组类型的访问级别是所有成员类型中最低的那个。

```swift
fileprivate struct Dog {}
struct Cat {}

fileprivate let animal: (Dog, Cat)
```

例子中的animal只能被fileprivate或者private修饰，因为所有成员类型中访问级别最低的是fileprivate。



## 泛型类型

泛型类型的访问级别是 类型的访问级别 和 所有泛型类型参数 的访问级别中最低的那个。

```swift
fileprivate struct Dog {}
struct Cat {}

struct Animal<A1, A2> {}

fileprivate let animal: Animal<Dog, Cat>
```

例子中的animal只能被fileprivate或者private修饰，因为所有泛型类型参数中访问级别最低的是fileprivate。



## 成员 和 嵌套类型

类型的级别会影响 成员(属性、方法、初始化器、下标) 和 嵌套类型 的默认访问级别：

1. **一般情况下，类型为fileprivate或private，那么成员和嵌套类型默认也是fileprivate或private。**

2. **一般情况下，类型为public或internal，那么成员和嵌套类型默认是internal。**

   开发中经常会看到的代码是：将类型设置为public，那么其初始化器也要显示指定为public，否则无法在其他模块中做初始化。



## 成员的重写

**子类重写成员的访问级别必须 >= 父类被重写成员的访问级别。**

下边的代码会报错：

❌ **error: overriding property must be as accessible as the declaration it overrides**

也就是说，重写后的age至少也得是fileprivate。

```swift
public class Person {
    fileprivate var age: Int = 0
}

public class Student: Person {
    override private var age: Int {
        get { 10 }
        set {}
    }
}
```

**父类的成员不能被成员作用域外定义的子类重写。**

下边的代码会报错：

❌ **error: property does not override any property from its superclass**

age的作用域只在起所在的类型中的两个大括号之间，所以不能被定义在外部的Student重写。

```swift
public class Person {
    private var age: Int = 0
}

public class Student: Person {
    override var age: Int {
        get { 10 }
        set {}
    }
}
```

如果将Student放在其作用域内就可以：

```swift
public class Person {
    private var age: Int = 0
    
    public class Student: Person {
        override var age: Int {
            get { 10 }
            set {}
        }
    }
}
```



## private 和 fileprivate

在全局作用域下定义的 private 和 fileprivate 等价。

```swift
private class Person {}
fileprivate class Student: Person {}
```

但是，如果把上边的代码嵌套在另外一个类型中的话，就会报错：

❌ **error: class cannot be declared fileprivate because its superclass is private**

```
class Test {
    private class Person {}
    fileprivate class Student: Person {}
}
```



## getter 和 setter

开发中，经常会将实体的setter设置成private (*或者其他的比getter更低的访问级别*)，这样外界只能读取该属性值，而实体的写操作只能发生在限定的作用域内，这样是一种非常有用和安全的操作。

```swift
fileprivate(set) var number = 10

class Person {
    private(set) var age: Int {
        get { 10 }
        set {}
    }
    
    private(set) subscript(_ index: Int) -> Int {
        get { index }
        set {}
    }
}
```



## 协议

协议实现的访问级别必须 >= 协议的访问级别。

下边的代码会报错：

❌ **error: method 'run()' must be declared public because it matches a requirement in public protocol 'Runnable'**

方法run必须用public修饰才可以。

```swift
public protocol Runnable {
    func run()
}

public class Person: Runnable {
    func run() {
        print("Person run.")
    }
}
```



## 扩展

**如果给扩展显示地指定了访问级别，那么其内部成员也默认接收该访问级别。**

下例中的hobby也是public。

```swift
public class Person {
    func run() {}
    
    public init() {}
}

public extension Person {
    // public
    func hobby() -> String {
        "basketball"
    }
}
```

**如果不显示地指定访问级别，那么扩展中的内容就相当于直接定义在了原类型中，其访问级别也和原类型中内容的默认访问级别相同。**

