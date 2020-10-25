[TOC]



# The Basics (基础语法)



## Playground (*Xcode->File->New-Playground*)

用来练习或者演示Swift代码，基本上可以实现实时编译输出代码运行结果，或者使用`shift + cmd + enter`来触发编译执行。

其实Playground的功能还有很多，比如可以和项目进行协作，但是根据工作中的实践经验来说，常用的还是用它来做练习和演示代码。

另外，新建一个工程来演示和练习Swift代码也可以，无非就是需要`cmd + r`来运行结果。

来看看Playground的几个特殊的应用场景吧：

### Playground终止延时操作

`PlaygroundPage.current.finishExecution()`

默认情况下，Playground并不会自动终止，可以显式地调用以上的代码来终止运行，比如，起一个Timer:

```swift
import Foundation
import PlaygroundSupport

var number = 1

Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    guard number <= 6 else {
        print("finished")
        PlaygroundPage.current.finishExecution()
    }
    print(number)
    number += 1
}
```

当强制终止Playground的时候，如果此时还有其他类似的延时操作任务仍在执行，比如另一个Timer或者网络请求等，也会跟着一起终止执行，这个就和简单地使用`timer.invalidate()`来终止定时器效果不一样了。

### 注释

> 注意
>
> 以下注释既可以在工程中使用，也可以在Playground中使用

**普通注释**

```annotation
// 单行注释

/*
 多行注释
*/

// MARK: - 分割代码

// FIXME: - 此处代码有问题，该问题待解决
        
// TODO: - 待实现
```

**文档注释**

个人感觉这部分不用死记，因为Xcode已经提供了强大的自动生成文档注释的功能, 光标定位到类型, 方法或者任何代码的上一行，试一试`option + cmd + /`。

> 注意：
>
> 函数的注释也是Markup语法。
>
> 可以根据自己的实际需要，去查阅[API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) 和 [Markup官方文档](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)

```swift
/// 给某人说一句话，仅仅为了演示文档注释
/// - Parameters:
///   - words: 要说的话
///   - person: 说话的对象
func say(_ words: String, to person: String) {
    print("say", words, "to", person)
}
```

### Playground Markup注释

使用Markup语法(与Markdown语法大同小异)，常用的操作如下:

Markup语法 (*Xcode->Editor->Show Rendered/Raw Markup*)

- 单行 / 多行

  ```markup
  //: 开始Markup
  
  /*:
   开始Markup
   */
  ```

- 上一页 / 下一页

  Playground里可以通过*File->New->Playground Page*创建多页面

  ```markup
  //: [上一页](@previous)
  //: [下一页](@next)
  ```

- 常用语法

  ```markup
  /*:
   # 一级标题
   
   ## 无序列表
   - First item
   - Second item
   
   ## 有序列表
   1. First item
   2. Second item
   
   ## NOTE(笔记)
   > NOTE
   > This is a note
   
   ## 分割线
   ---
   
   ## 图片
   ![logo](logo.png "Swift logo")
   
   ## 链接
   [百度](https://www.baidu.com)
   
   ## 粗体 / 斜体
   这是**Bold**，这是*Italic*
   */
  ```

### Playground与项目进行协作

给工程里边添加一个Playground文件，然后就可以import项目中的framework module, 调用framework的接口方法来测试framework的功能。

比如有一个framework：Etiquette, 内部有一个Greeting.swift文件：

*in Greeting.swift*

```swift
public protocol Greeting {
    func sayHello()
    func sayHowdy()
    func sayMorning()
}

public struct GreetingFactory {
    public static func makeGreeter() -> Greeting { Greeter() }
}

struct Greeter {
    init() {}
}

extension Greeter: Greeting {
    func sayHello() {
        print("Hello")
    }
    
    func sayHowdy() {
        print("Howdy")
    }
    
    func sayMorning() {
        print("Good morning")
    }
}
```

这里定义了一个工厂类型`GreetingFactory`，其拥有一个静态方法可以返回一个遵守了协议`Greeting`的实例。

在主App中或者同一个工程下的Playground中，可以这样调用方法：

```swift
import Etiquette

let greeter = GreetingFactory.makeGreeter()
greeter.sayHello()
greeter.sayHowdy()
greeter.sayMorning()
```

### Playground显示view

`PlaygroundPage.current.liveView = view`

`PlaygroundPage.current.liveView = view controller`

既可以展示`UIView`，也可以展示`UIViewController`

```swift
import UIKit
import PlaygroundSupport

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
label.backgroundColor = .white
label.font = UIFont.systemFont(ofSize: 32)
label.textAlignment = .center
label.text = "Hello Swift"
PlaygroundPage.current.liveView = label
```



## 分号

Objective-C中，每一条代码结尾都要写一个分号，而分号在Swift中已经不是必须要写的了，因为可以不写分号，所以在Swift中很少会见到分号。

但是有一些情况，仍然需要写分号，比如，将多条代码语句写在一行：

```swift
let a = 10; let b = 20
```

这样写代码虽然可以成功编译运行，但是并不建议这样做，尤其是代码很长的时候，这样写会影响代码可读性。



## 常量和变量

Swift中修饰符

`let`用来定义常量

`var`用来定义变量

```swift
let a = 10
let b = 20
var c = a + b
c += 30

let d: Int
d = 40
```

Swift中的类型分为：

*值类型(enum & struct & tuple)* 和 *引用类型(class)*

> 注意
>
> 许多系统定义的基本类型都是值类型，比如：
>
> enum: `Optional`
>
> struct: `Int` `Double` `Float` `Bool` `Character` `String` `Array` `Dictionary` `Set`



## _ 下划线

可以用来代替**任何**你不想读取的值，比如有些变量或者常量被定义了，但是却没有在任何地方用到，而且你又不得不去定义它，不定义的话，会有编译警告或者报错，定义的话，也会有编译警告。

这个时候就可以使用`_`来做一个占位，表示这个值爱是啥就是啥，你不care。

```swift
let (_, second) = (2, 5)
print(second)
```

这段代码表示我只想读second，first是啥我不关心。

当然你非要定义first也可以，不过此刻那句***Less is more***又得被拉出来念叨念叨了。

想想，干干净净的代码里多了几条警告，你说美气不美气？



## 字面量

常用的基本类型

```swift
// Swift有类型推断的功能，即可以根据value来推断常量或者变量的类型。
let bool = false
let bool2: Bool = false

let string = "eric"
let character: Character = "e"

// 都是表示 17
let intDecimal = 17
let intBinary = 0b10001
let intOctal = 0o21
let intHexadecimal = 0x11

// 数字中间可以加下划线，或者前边补0来调整格式
let bigNumber   = 1_000_000_000 // 10亿
let smallNumber = 0_000_000_001 // 1

let array = [1, 2, 3, 6, 4, 8]
let dictionary: [String : Any] = ["age": 20, "height": 172, "name": "Jack"]
```

类型转换

默认，不同的有明确类型的值是不能直接进行运算的，需要进行类型转换：

`Type(value)`

```swift
let int1: UInt16 = 2_000
let int2: UInt8 = 1
int1 + UInt16(int2) // 2_001
```



## 标识符

Swift中的标识符一定会颠覆你的三观，因为它几乎可以由任何字符组成：

```swift
func 🐂🍺() {
    print("牛皮")
}

let 👽 = "ET"
let 🥛 = "Milk"
```

但是在项目中还是不要这么去定义标识符，尤其是团队合作的时候，最好按照传统的命名规范来。



## Tuple (元组)

### 元组语法

常用来包装多个简单的值为一个整体

```swift
let http404Error = (404, "Not Found")
http404Error.0 // 404
http404Error.1 // Not Found

let (statusCode, statusMessage) = http404Error
statusCode // 404
statusMessage // Not Found

let (onlyReadStatusCode, _) = http404Error
onlyReadStatusCode // 404

let http200Error = (statusCode: 200, statusMessage: "success")
http200Error.0 // 200
http200Error.1 // "success"
http200Error.statusCode // 200
http200Error.statusMessage // "success"
```

在实践中，如果数据组合过于复杂，不建议使用元组，而应该使用`struct`或者`class`

也就是说，元组只是Swift这门编程语言提供的一个语法糖而已，至于要不要用，不用过于纠结，根据实际需求来定即可

软件开发有一句流行语：***Less is more***

也就是宁缺毋滥的意思，***合适的才是最好的***

不过，恰当地使用元组，会让代码看起来更加Swift, 更加优雅。

接下来看看几个和元组相关的实际例子吧：

### 交换数据

> 注意
>
> Swift已经自带一个`swap<T>(_ a: inout T, _ b: inout T)`函数，用来交换数据，所以这里我们只是为了演示元组的特殊用法

普通程序员可能会使用亘古不变的传统方法，借助一个新的空瓶子来置换可乐和雪碧，写法如下：

```swift
var a = 10
var b = 20

func swapValue<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

swapValue(&a, &b)

print(a, b) // 20 10
```

然鹅，文艺程序员则会写出下边这样更加优雅的代码：

```swift
var a = 10
var b = 20

func swapValue<T>(_ a: inout T, _ b: inout T) {
    (a, b) = (b, a)
}

swapValue(&a, &b)

print(a, b) // 20 10
```

### `CGRectDivide` vs `CGRect.divide`

这个是苹果Cocoa API自带的方法，用来分割CGRect, 在Objective-C中几乎所有的类型都是指针类型，并且沿用C语言的语法特性，函数的返回值只能是一个，所以Objective-C用来分割CGRect的代码如下：

```objective-c
CGRect rect = CGRectMake(0, 0, 100, 100);
CGRect small;
CGRect large;
CGRectDivide(rect, &small, &large, 20, CGRectMinXEdge);
// small = (origin = (x = 0, y = 0), size = (width = 20, height = 100))
// large = (origin = (x = 20, y = 0), size = (width = 80, height = 100))
```

可见，Objective-C使用了指针传值的方式来应对函数单一返回值的局限

不过，在Swift中，系统使用了元组类型来返回多个值，代码如下：

```swift
let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
let dividedResult = rect.divided(atDistance: 20, from: .minXEdge)
dividedResult.slice // (0, 0, 20, 100)
dividedResult.remainder // (20, 0, 80, 100)
dividedResult.0 // (0, 0, 20, 100)
dividedResult.1 // (20, 0, 80, 100)
```

这样，代码会看起来更加简洁，更具可读性。



## 局部作用域

可以使用do来做到和函数一样的局部作用域，这个在练习Swift的时候非常有用，甚至你可以将其应用到你的项目代码中，视情况而定：

```swift
struct Dog {
    func bark() {
        print("Dog bark.")
    }
}

do {
    let dog = Dog()
    dog.bark()
}

do {
    let dog = Dog()
    dog.bark()
}

do {
    let dog = Dog()
    dog.bark()
}
```

