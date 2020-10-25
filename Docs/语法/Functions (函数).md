[TOC]



# Functions (函数)

在Swift中，函数类型是第一等公民(*first class*)，即函数类型可以像其他类型一样使用，正因为如此，Swift是一门非常适合做函数式编程的开发语言。



## 函数的定义

```swift
func pi() -> Float {
    return 3.14
}

func sum(_ v1: Int, _ v2: Int) -> Int {
    return v1 + v2
}
```

- 函数的形参类型只能是let

- 和C, Objective-C等其他编程语言一样，函数的返回值只能是单一的值

- 无返回值的函数可以省略返回值类型的声明(或者写成*Void*, *()*)：

  > 注意
  >
  > 返回值类型如果写成 *Void*, *()*, 其实它就是一个空元组

  ```swift
  func greet() -> Void {
      print("Howdy")
  }
  
  func greet() -> () {
      print("Howdy")
  }
  
  func greet() {
      print("Howdy")
  }
  ```



## 函数的隐式返回 (Implicit Return)

如果函数体中只有一条语句，那么可以省略return，隐式返回返回值：

> 注意
>
> 这个特性只有在Swift5.x有，如果你还在使用Swift4.x, 那么必须写上return

```swift
func sum(_ v1: Int, _ v2: Int) -> Int {
    v1 + v2
}
```



## 间接实现多返回值

常用的方式就是用元组，当然也可以使用其他类型，比如struct和class。

```swift
func calculate(_ v1: Int, _ v2: Int) -> (sum: Int, difference: Int, average: Int) {
    let sum = v1 + v2
    let difference = v1 - v2
    return (sum, difference, sum >> 1)
}

let result = calculate(20, 10)
result.sum // 30
result.difference // 10
result.average // 15
result.0 // 30
result.1 // 10
result.2 // 15
```



## 文档注释

在基础语法部分我们已经说过了文档注释，即光标定位到类型, 方法或者任何代码的上一行，试一试`option + cmd + /`，然后系统就会自动生成适合的文档注释模板，然后我们只需要填空就行了。

```swift
/// 对传入的两个值进行运算，返回其和，差，以及平均值
/// - Parameters:
///   - v1: 第一个要参与运算的值
///   - v2: 第二个要参与运算的值
func calculate(_ v1: Int, _ v2: Int) -> (sum: Int, difference: Int, average: Int) {
    let sum = v1 + v2
    let difference = v1 - v2
    return (sum, difference, sum >> 1)
}
```

光标定位到函数名之上`option + click`就可以弹出来Quick Help弹框，我们以上的注释内容也会反映在该弹框里。

但是有时候标配的模板也许并不能满足需求，有可能你想添加更多的标记，那么请参考[这里](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/Attention.html#//apple_ref/doc/uid/TP40016497-CH29-SW1)。

另外也请参考[API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) 和 [Markup官方文档](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)，了解更多，这一部分我们在基础语法也提到过，其很类似于Markdown语法，在实际的应用过程中，完全可以用Markdown的对应语法进行类比 + 查阅[Markup官方文档](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)。

> 注意
>
> 文档注释并不是越多越好，但是有一点非常重要，如果你开发了一个framework给其他团队用，给接口API加上详细的文档注释非常重要，可以让使用者更好地理解API的用法，也可以让你做的framework显得非常专业，毕竟如果你去阅读一些优秀的第三方框架，或者大公司开发的第三方SDK，亦或者你去看苹果官方的API定义，你会发现他们的接口API都会非常注重文档注释的书写。



## 参数标签 (Argument Label)

合理地使用参数标签会使得你的函数阅读起来像自然语言一样，这会明显地增加函数的可读性和意图，默认情况下，如果不指定参数标签的话，参数名就是参数标签, 下边函数的参数标签就是words和somebody。

```swift
func say(words: String, somebody: String) {
    print("say", words, "to", somebody)
}

say(words: "Hello", somebody: "Eric") // say Hello to Eric
```

下边函数的参数标签是something和to, 不过该函数与上边的函数相比可读性明显增强了，也更贴近自然语言的习惯: say something to somebody。

```swift
func say(something words: String, to somebody: String) {
    print("say", words, "to", somebody)
}

say(something: "Hello", to: "Eric") // say Hello to Eric
```

参数标签也可以使用`_`进行忽略，这个我们也在基础语法部分有讲过，下边的函数就没有参数标签：

```swift
func sum(_ v1: Int, _ v2: Int) -> Int {
    v1 + v2
}

sum(10, 20) // 30
```



## 默认参数值 (Default Parameter Value)

参数可以有默认值，这样在调用函数的时候，就可以选择性地给或者不给拥有默认值的参数传值：

- Swift拥有参数标签，所以默认参数值可以给任意一个参数设置，不用像C++那样必须从后往前设置
- 要注意合理使用`_`，因为这样会忽略掉参数标签

```swift
func signup(name: String = "annonymous", phoneNumber: String, job: String = "none") {
    print("name:", name, "phoneNumber:", phoneNumber, "job:", job)
}

signup(phoneNumber: "12345678901")
signup(name: "Eric", phoneNumber: "12345678902", job: "coder")
signup(name: "Jack", phoneNumber: "12345678903")
signup(phoneNumber: "12345678904", job: "manager")
```



## 可变参数 (Variadic Parameter)

字面意思就是这个参数你可以随便写多个都可以，然后在函数内部你就可以像使用数组那样使用该可变参数：

- 下边求和我们使用了Swift处理数组的高阶函数：reduce, 这个在以后的函数式编程章节中会详细介绍。

  传统的方法可能会这样写：

  ```swift
  var sum = 0
  for number in numbers {
      sum += number
  }
  return sum
  ```

  与函数式方法：

  ```swift
  numbers.reduce(0) { $0 + $1 }
  ```

  或者：

  ```swift
  numbers.reduce(0, +)
  ```

  相比，哪种方法逼格更高，不言而喻。

- 一个函数最多只能有一个可变参数

- 可变参数的后一个参数的参数标签不能省略，否则会产生歧义

```swift
func sum(numbers: Int...) -> Int {
    numbers.reduce(0, +)
}

sum(numbers: 1, 2, 3, 4, 5, 6) // 21
```

Swift自带的print函数：

`public func print(_ items: Any..., separator: String = " ", terminator: String = "\n")`

就是用了可变参数，这样我们使用的时候可以这样调用：

`print("name:", "Eric", "age:", 30) // name: Eric age: 30`



## print函数在实际开发中的使用

实际开发中，可能会有这样的需求：

1. Debug模式下，开启log，Release模式下，关闭所有的log
2. log输出需要定位到当前的文件名，方法名，代码行号

这个需求很普遍，原因就是我们发布的App并不需要log输出，因为这样会耗费性能，而开发阶段我们又想尽量多地输出一些有用的log帮助我们开发调试。

以下是一种实现：

Log.swift (该文件往往会被放在一个独立的framework中，当然也可以被放在主App中):

```swift
import Foundation

/// Writes the textual representations of the given items into the standard
/// output.
///
/// You can pass zero or more items to the `print(_:separator:terminator:)`
/// function. The textual representation for each item is the same as that
/// obtained by calling `String(item)`. The following example prints a string,
/// a closed range of integers, and a group of floating-point values to
/// standard output:
///
///     printLog("One two three four five")
///     // Prints "One two three four five"
///
///     printLog(1...5)
///     // Prints "1...5"
///
///     printLog(1.0, 2.0, 3.0, 4.0, 5.0)
///     // Prints "1.0 2.0 3.0 4.0 5.0"
///
/// To print the items separated by something other than a space, pass a string
/// as `separator`.
///
///     printLog(1.0, 2.0, 3.0, 4.0, 5.0, separator: " ... ")
///     // Prints "1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0"
///
/// The output from each call to `print(_:separator:terminator:)` includes a
/// newline by default. To print the items without a trailing newline, pass an
/// empty string as `terminator`.
///
///     for n in 1...5 {
///         printLog(n, terminator: "")
///     }
///     // Prints "12345"
///
/// - Note:
/// This function takes effect in Debug mode only.
///
/// - Parameters:
///   - items: Zero or more items to print.
///   - file: The file path of the current log line.
///   - method: The method name of the current log line belongs to.
///   - line: The line number of the current log.
///   - separator: A string to print between each item. The default is a single space (`" "`).
///   - terminator: The string to print after all items have been printed. The default is a newline (`"\n"`).
public func printLog(_ items: Any...,
                     file: String = #file,
                     method: String = #function,
                     line: Int = #line,
                     separator: String = " ",
                     terminator: String = "\n") {
    #if DEBUG
    let verbosePrefix = "[\((file as NSString).lastPathComponent)][\(method)][\(line)]:"
    guard items.count != 0 else {
        print(verbosePrefix, terminator: terminator)
        return
    }
    print(verbosePrefix, terminator: "")
    items.enumerated().forEach {
        var innerTerminator = separator
        if $0 == items.endIndex - 1 {
            innerTerminator = ""
        }
        print($1, terminator: innerTerminator)
    }
    print("", terminator: terminator)
    #endif
}
```

在使用的时候可以像调用系统print方法那样使用，唯一的区别就是该方法只在Debug模式下起作用：

```swift
printLog("Hi man") // [ViewController.swift][touchesBegan(_:with:)][29]:Hi man
```

接下来，详解一下这个需求的实现：

- printLog函数定义仿照系统的print函数参数使用了可变参数来接受items, separator和terminator设置了默认参数，这两个参数的作用就是用来做每一个item的分隔符和整体log的结束符，默认值分别是空格和换行。除此之外，加多了3个参数用来获取当前log所有在的文件名，方法名，以及代码行号，也分别有默认值，一般情况下，这个3个参数不需要接受任何实参。

- printLog函数设置为public，是因为Log.swift往往会被放在一个独立的framework中，这样需要设置它的访问权限为public，这样外界(*其他framework或者主App*)才能调用到该函数。

  你可能会问，可以设置成open么，不能，因为open只能用来修饰class以及class可以被重写的成员。

- Swift中的条件编译远远没有Objective-C中那样灵活，Swift中只能使用#if xxx #elseif xxx #else xxx #endif, DEBUG这个宏默认在你创建一个Swift项目的时候就会定义好，如果是老项目，你可以去*BuildSettings->Swift Compiler - Custom Flags->Active Compilation Conditions->Debug*右侧双击添加DEBUG，或者去*BuildSettings->Swift Compiler - Custom Flags->Other Swift Flags->Debug*右侧双击添加-D DEBUG，这样在Release模式下上边的printLog就不会起任何作用，相当于一个空方法，空方法在Release模式下的App里头会被移除掉，所以也就不会有任何log在Release模式下的App中被打印出来了。

- 该函数的文档注释拷贝了系统的print函数的文档注释，并在其基础上添加了一个标记*- Note: This function takes effect in Debug mode only.*说明只有在Debug模式下才会有起作用，当使用者光标放在函数名之上，并*option+click*的时候，就可以看到Quick Help里头有这一条标记。

  如何在注释中添加更多的标记，在上边的文档注释里已经提到过的[Markup官方文档](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)里[Inserting Callouts](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/Attention.html#//apple_ref/doc/uid/TP40016497-CH29-SW1)。



## 输入输出参数 (In-Out Parameter)

输入输出参数：即可以在函数内部修改外部实参的值。

我们之前在基础语法部分已经举过一个交换数据的例子：

```swift
var a = 10
var b = 20

func swapValue<T>(_ a: inout T, _ b: inout T) {
    (a, b) = (b, a)
}

swapValue(&a, &b)

print(a, b) // 20 10
```

这里使用了inout关键字去修饰形参类型，这样，传入的实参如果在函数内部被修改了，该改动也会反应在传入的实参上。

inout参数有这么几个规则：

- 可变参数不能标记为inout。
- inout参数不能设置默认值。
- inout参数只能传入变量。
- inout参数本质是地址传递 (引用传递)。



## 函数重载 (Function Overload)

函数重载的规则如下：

1. 函数名相同。
2. 参数个数不同 或者 参数类型不同 或者 参数标签不同，但是要特别注意避免一些会出现歧义的情况，比如使用了默认参数值或者可变参数等。

参数个数不同：

```swift
func sum(_ v1: Int, _ v2: Int) -> Int {
    v1 + v2
}

func sum(_ v1: Int, _ v2: Int, _ v3: Int) -> Int {
    v1 + v2 + v3
}
```

参数类型不同：

```swift
func sum(_ v1: Int, _ v2: Int) -> Int {
    v1 + v2
}

func sum(_ v1: Float, _ v2: Float) -> Float {
    v1 + v2
}
```

参数标签不同：

```swift
func sum(_ v1: Int, _ v2: Int) -> Int {
    v1 + v2
}

func sum(v1: Int, v2: Int) -> Int {
    v1 + v2
}
```

但是也有一些注意点需要避免：

- 函数返回值不同，这样虽然也构成函数重载，但是在调用的时候要格外小心：

  ```swift
  func sum(_ v1: Int, _ v2: Int) -> Int {
      v1 + v2
  }
  
  func sum(_ v1: Int, _ v2: Int) {
      print(v1 + v2)
  }
  
  sum(1, 2)
  ```

  这样的代码在编译阶段就会报错：ambiguous use of 'sum'。

  因为编译器并不知道你调用的是哪一个sum函数。

  也许你会有这样的疑问，那我接收返回值的话，编译器不就可以确定了么，还真可以，不过你要显式地声明返回值的类型，否则会报同样的错：

  比如，如果你这样写：`let result = sum(1, 2)`, 同样会报上边的错，因为我们在函数的定义中说过，无返回值，其实本质上返回值是一个空元组。

  所以得这样写才可以：`let result: Int = sum(1, 2)`。

  实际开发中很**不建议**这样去重载函数，能不这样写就不要这样写，因为这样的代码语义很不清晰，调用的时候很容易产生歧义。

- 默认参数值和函数重载一起使用会产生二义性：

  ```swift
  func sum(_ v1: Int, _ v2: Int) -> Int {
      v1 + v2
  }
  
  func sum(_ v1: Int, _ v2: Int, _ v3: Int = 60) -> Int {
      v1 + v2 + v3
  }
  
  sum(1, 2)
  ```

  这样的代码虽然不报错，也能正常执行，但是有二义性，因为你根本猜不到编译器会调用哪一个函数。虽然通过实验，第一个函数会被调用，但是说实话，这种代码在实际开发中，毛用都没有，只会降低代码的可读性。

  所以，实际开发中，这种写法**尽量要避免**。

- 无参数标签函数和可变参数也会产生二义性：

  ```swift
  func sum(_ v1: Int, _ v2: Int) -> Int {
      v1 + v2
  }
  
  func sum(_ numbers: Int...) -> Int {
      numbers.reduce(2, +)
  }
  
  sum(1, 2)
  ```

  这样写也不会报错，而且默认会调用第一个函数，但是同样地会降低代码的可读性，想想，既然能用可变参数实现的功能，为什么还要画蛇添足写第一个函数呢！

  再有，如果写多一个有标签的函数，就立马会编译报错，举例如下：

  ```swift
  func sum(v1: Int, v2: Int) -> Int {
      v1 + v2
  }
  
  func sum(_ v1: Int, _ v2: Int) -> Int {
      v1 + v2
  }
  
  func sum(_ numbers: Int...) -> Int {
      numbers.reduce(2, +)
  }
  
  sum(1, 2)
  ```

  这个时候，编译器貌似醒悟了，直接报错：ambiguous use of 'sum'。

  这种代码实际开发中**要避免**。

**总结一下：**

函数重载功能要适度使用，虽然写出来的代码有时候确实是可以运行，也不报错，但是代码写出来不光是要能正常运行的，而且要易维护，那么就要求代码有较高的可读性，毕竟，谁都不喜欢看无意义地绕来绕去的代码。

**高效并且可读性高**的代码才是最优选。



## 编译器优化

默认情况下，iOS会在Release模式下对代码进行速度方面的优化，而Debug模式下会默认关闭该优化：

Build Settings->Swift Compiler - Code Generation->Optimization Level->

Debug->No Optimization [-Onone]

Release->Optimize for Speed [-O]

优化有3个选项可以选择：

1. No Optimization [-Onone]
2. Optimize for Speed [-O]
3. Optimize for Size [-Osize]

会优化什么呢？

如果是速度优化，编译器会尽量避免直接进行函数调用，而会选择直接调用函数内部的实现，并且直接移除掉一些定义了却没有在任何地方被调用的函数。

这一点可以通过一个简单的函数进行测试：

```swift
func test() {
    print("test")
}
```

在任何一个地方调用一下该函数，然后打勾Debug->Debug Workflow->Always Show Disassembly，在函数调用的地方打断点，分别在Debug和Release模式下运行程序，看看汇编代码是如何调用该函数的。

会发现在Release模式下，test函数直接被拆开了，直接调用了print函数。

也可以通过给方法前边加`@inline (never)`来告诉编译器不需要优化。

实际开发中，其实我们并不需要去操作这一块的内容，App一般建议用Release模式打包，编译器会做最大程度的优化。



## 函数类型 (Function Type)

### 函数类型定义

函数类型由形参类型和返回值类型组成，每一个函数都是有类型的。

```swift
func test() {}
```

如下所示，test函数的类型为：() -> Void, () -> ()

> 注意
>
> `is`是用来判断类型的，i.e. `"123" is String // true`

```swift
test is () -> Void // true
test is () -> () // true
```

本章的最开始我们说过，函数类型在Swift中是第一等公民，即它可以像其他类型那样被使用。

函数可以被赋值给一个函数类型实体：

```swift
func sum(v1: Int, v2: Int) -> Int {
    v1 + v2
}
sum is (Int, Int) -> Int // true
```

```swift
let fn: (Int, Int) -> Int = sum
fn(10, 20)
```

fn进行调用的时候，不需要写参数标签，直接传值就可以。

### [高阶函数](https://en.wikipedia.org/wiki/Higher-order_function) (Higher-Order Function)

在Swift实际开发中，使用高阶函数的地方几乎到处都是，这也得益于Swift对是一门非常适合做函数式编程的开发语言。关于高阶函数，我们还会在函数式编程的章节中做介绍。

> 维基百科上对高阶函数的定义：
>
> In [mathematics](https://en.wikipedia.org/wiki/Mathematics) and [computer science](https://en.wikipedia.org/wiki/Computer_science), a **higher-order function** is a [function](https://en.wikipedia.org/wiki/Function_(mathematics)) that does at least one of the following:
>
> - takes one or more functions as arguments (i.e. [procedural parameters](https://en.wikipedia.org/wiki/Procedural_parameter)),
> - returns a function as its result.

也就是说符合以下其中至少一种情况就可以称该函数为高阶函数：

1. 形参有一个或多个是函数类型。

   ```swift
   func sum(v1: Int, v2: Int) -> Int {
       v1 + v2
   }
   
   func diff(v1: Int, v2: Int) -> Int {
       v1 - v2
   }
   
   func calculate(fn: (Int, Int) -> Int, v1: Int, v2: Int) {
       print(fn(v1, v2))
   }
   
   calculate(fn: sum, v1: 20, v2: 10) // 30
   calculate(fn: diff, v1: 20, v2: 10) // 10
   ```

   calculate函数接收一个类型为(Int, Int) -> Int的函数，以及两个Int值，然后在其内部做运算，外部只需要传进来一个符合该形参类型的函数既可以，至于算法具体是什么，这个完全由外界来控制。

   这也非常符合[策略设计模式](https://en.wikipedia.org/wiki/Strategy_pattern)的思想。

2. 返回值类型为函数类型。

   ```swift
   func stepForward(_ input: Int) -> Int {
       return input + 1
   }
   func stepBackward(_ input: Int) -> Int {
       return input - 1
   }
   
   func chooseStepFunction(backward: Bool) -> (Int) -> Int {
       return backward ? stepBackward : stepForward
   }
   
   var currentValue = 3
   let moveNearerToZero = chooseStepFunction(backward: currentValue > 0)
   
   print("Counting to zero:")
   
   while currentValue != 0 {
       print("\(currentValue)... ")
       currentValue = moveNearerToZero(currentValue)
   }
   
   print("zero!")
   
   /*
    Counting to zero:
    3...
    2...
    1...
    zero!
    */
   ```

   stepForward和stepBackward两个函数分别表示由负方向和正方向向坐标轴原点靠近，函数chooseStepFunction则根据条件返回需要前进或者后退的函数，之后通过循环执行该函数就可以让给定的点一步步移动到原点。

   至于前进后退函数算法如何实现，则完全由外界来控制。

   这也非常符合[策略设计模式](https://en.wikipedia.org/wiki/Strategy_pattern)的思想。



## typealias

顾名思义，给类型起一个别名。

在实际开发中，通常如果使用的类型在具体的使用场景中语义不明显或者类型过长有碍代码阅读的话等等，都可以给类型起一个别名，然后在之后的代码中用该别名替换原本该写原始类型的地方。

```swift
typealias MyDate = (year: Int, month: Int, day: Int)

let birthday: MyDate = (2020, 1, 1)

birthday.year
birthday.month
birthday.day
```

之前我们有说过Void和()等价，都表示一个空元组，其实系统也是使用typealias来实现的：

`public typealias Void = ()`



## 嵌套函数 (Nested Functions)

如果有些函数只在某一个函数中被用到，并且想限定这些函数的作用域，不希望它们在其他地方能被调用到，那就可以将这些函数定义到该函数的函数体内部，这就是函数嵌套。

虽然外界无法直接访问到这些嵌套函数，但是还是可以通过返回一个函数的形式来间接让外界调用到这些嵌套函数。

上边我们写的chooseStepFunction函数会选择性地返回stepForward或者stepBackward函数，而这两个函数有可能只是用到chooseStepFunction里，这样的话，我们就可以将它进行一下改写。

```swift
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    func stepForward(input: Int) -> Int { input + 1 }
    func stepBackward(input: Int) -> Int { input - 1 }
    return backward ? stepBackward : stepForward
}
```

改写后的chooseStepFunction里边有两个嵌套函数stepForward和stepBackward，这样外界就无法再直接调用到stepForward和stepBackward，而只能通过接收chooseStepFunction的返回值来调用函数。

这样就限定了stepForward和stepBackward的作用域，想想，有时候一些方法，有可能是出于安全考虑或者外界调用这些方法并不合适，那么就做成嵌套函数吧！