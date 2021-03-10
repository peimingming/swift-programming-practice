[TOC]



# 编程范式: 面向[协议](../语法/Protocols%20(协议).md)编程 (Protocol Oriented Programming)



Apple于[2015年的WWDC](https://developer.apple.com/videos/play/wwdc2015/408/)上提出**面向协议编程**的编程思想，并且结合Swift举例说明了为什么引入该思想

在Swift开发中，也大量用到了面向协议的编程范式

使用协议的好处：

1. 面向接口编程，这样可以隐藏实体类及其内部实现，比如，代理设计模式，策略设计模式 都用到了面向协议编程的思想
2. 面向协议可以解决面向对象基类的臃肿问题，回想一下，如果把所有需要复用的属性或者方法都放在基类中的话，那么这个基类就可能会越来越庞大，反之，如果做成一个个的协议的话，就会轻便和灵活很多
3. 利于单元测试，即可以将遵守指定协议的Mock类型实例注入到另外一些使用到该协议的类型中进行测试

使用协议的注意点：

1. **面向协议不能取代面向对象而单独存在**
2. 优先创建协议，而不是一个基类 (*但是不要为了面向协议而使用协议，应该根据实际情况进行考量*)
3. 优先考虑使用值类型 (struct, enum)，而不是引用类型 (class)
4. 巧用协议的扩展功能

> 注意
>
> 关于协议的详细用法，请参考 [协议](../语法/Protocols%20(协议).md) 一章



下边举 **2** 个使用协议的例子:



## Swift中利用协议实现优雅前缀

在一些流行的Swift第三方库中，大家可能会看到这样的代码：

```swift
textField.rx.text.xxx
imageView.kf.setImage(...)
```

这样做的好处是，自定义的标识符可以完全保持和系统中的一致，方便调用者使用，比如：

textField本来就有一个text的属性，textField.text访问的就是textField自己的属性，而textField.rx.text则访问的是RxSwift中定义的text，这样就完美地区分开了两个text；否则的话，也可以使用textField.rxText来区分text，但是这样，就需要为所有的自定义标识符添加一个rx前缀，也可以，不过看起来就不那么Swift了

该前缀 (*使用 `eric` 作为示例*) 简单实现如下：

- 定义一个Eric类型，并泛型其存储属性为Base类型，作为其内部包装实例：

  ```swift
  struct Eric<Base> {
      let base: Base
      init(_ base: Base) {
          self.base = base
      }
  }
  ```

- 定义协议EricCompatible，并扩展2个命名为eric的实例计算属性和类型计算属性，该命名为eric的属性就是要实现的前缀：

  ```swift
  protocol EricCompatible {}
  extension EricCompatible {
      var eric: Eric<Self> { Eric(self) }
      static var eric: Eric<Self>.Type { Eric<Self>.self }
  }
  ```

使用方法 (*具体类型遵守EricCompatible协议，并对类型Eric进行扩展*)：

1. string.eric.numberCount (*计算字符串内包含的数字个数*)

   ```swift
   extension String: EricCompatible {}
   extension Eric where Base == String {
       var numberCount: Int { base.filter { "0"..."9" ~= $0 }.count }
   }
   
   "123haha".eric.numberCount // 3
   ```

2. class-instance.eric.xxx (*调用类的实例成员*) class-type.eric.xxx (*调用类的类型成员*)

   ```swift
   class Person {}
   class Student: Person {}
   
   extension Person: EricCompatible {}
   extension Eric where Base: Person {
       func run() {
           print(self, "run")
       }
       
       func jump() {
           print(self, "jump")
       }
   }
   
   extension Eric where Base: Person {
       static func eat() {
           print(Base.self, "run")
       }
   }
   
   let person = Person()
   person.eric.run() // Eric<Person>(base: __lldb_expr_18.Person) run
   person.eric.jump() // Eric<Person>(base: __lldb_expr_18.Person) jump
   
   let student = Student()
   student.eric.run() // Eric<Student>(base: __lldb_expr_18.Student) run
   student.eric.jump() // Eric<Student>(base: __lldb_expr_18.Student) jump
   
   Person.eric.eat() // Person run
   Student.eric.eat() // Student run
   ```

3. string.eric.numberCount nsstring.eric.numberCount (*Base添加约束，实现numberCount*)

   ```swift
   extension String: EricCompatible {}
   extension NSString: EricCompatible {}
   extension Eric where Base: ExpressibleByStringLiteral {
       var numberCount: (countable: Bool, count: Int) {
           guard let string = base as? String else {
               return (false, 0)
           }
           return (true, string.filter { "0"..."9" ~= $0 }.count)
       }
   }
   
   let string1: String = "123haha"
   let string2: NSString = "123haha"
   let string3: NSMutableString = "123haha"
   string1.eric.numberCount
   string2.eric.numberCount
   string3.eric.numberCount
   ```



## 使用协议判断数组类型

判断一个类型的方法其实很简单，直接使用 `xxx is Type` 即可，不过数组类型比较特殊，列举 2 种判断方法：

1. `value is [Any]`

   ```swift
   func isArray(_ value: Any) -> Bool { value is [Any] }
   
   isArray([1, 2]) // true
   isArray(["1", 2]) // true
   isArray(NSArray()) // true
   isArray(NSMutableArray()) // true
   isArray(1) // false
   ```

2. 通过协议来实现

   数组可以大致分为两种类型 Array & NSArray (*NSMutableArray也是继承自NSArray*)，所以只需要新创建一个协议，让所有的数组类型都遵守该协议，然后通过 `value is 协议` 来判断即可

   ```swift
   protocol ArrayType {}
   
   extension Array: ArrayType {}
   extension NSArray: ArrayType {}
   
   func isArrayType(_ value: Any) -> Bool { value is ArrayType }
   
   isArrayType([1, 2]) // true
   isArrayType(["1", 2]) // true
   isArrayType(NSArray()) // true
   isArrayType(NSMutableArray()) // true
   isArrayType(1) // false
   ```

> 注意
>
> 在示例中的**方法一**显然要比**方法二**更好一点，这里**方法二**只是为了演示POP的一种用法

