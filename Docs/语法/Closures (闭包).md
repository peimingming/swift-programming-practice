[TOC]



# Closures (闭包)

Swift中的闭包其实和Objective-C中的blocks，以及其他开发语言中的lambdas类似。



## 闭包表达式 (Closure Expressions)

Swift中定义一个函数有两种方式：

1. *func*

   (*这个在函数一章中已经介绍过了*)

   ```swift
   func sum(_ v1: Int, _ v2: Int) -> Int {
       v1 + v2
   }
   sum(1, 2) // 3
   ```

2. 闭包表达式

   *格式大概如下：*

   ```pseudocode
   { (参数列表) -> 返回值类型 in
       函数体代码
   }
   ```

   示例一：

   (*可以利用闭包表达式，像定义普通的变量/常量那样定义一个函数*)

   ```swift
   let sum = { (v1: Int, v2: Int) -> Int in
       v1 + v2
   }
   sum(1, 2) // 3
   ```

   示例二：

   (*可以不定义函数名称，而直接进行一次调用，这种就有点像`匿名函数`*)

   ```swift
   { (v1: Int, v2: Int) -> Int in
       v1 + v2
   }(1, 2) // 3
   ```



## 闭包表达式的各种写法

闭包表达式有各种各样的写法，比如有一个函数，接收3个参数，前两个参数分别是Int类型，最后一个参数是一个函数类型，如下：

```swift
func execute(_ v1: Int, _ v2: Int, algorithm: (Int, Int) -> Int) -> Int {
    algorithm(v1, v2)
}
```

那都能怎么调用这个函数呢？

调用方式一：

(*比较中规中矩的调用方法，显示地在闭包表达式中定义了函数的参数列表和返回值类型*)

```swift
execute(1, 2, algorithm: { (v1, v2) -> Int in
    v1 + v2
}) // 3
```

调用方式二：

(*直接在闭包表达式中省略返回值类型，而且如果代码很短，完全可以写成一行*)

```swift
execute(1, 2, algorithm: { v1, v2 in v1 + v2 }) // 3
```

调用方式三：

(*直接使用$x来表示参数，$0和$1分别表示闭包表达式的第一个和第二个参数*)

```swift
execute(1, 2, algorithm: { $0 + $1 }) // 3
```

调用方式四：

(*刚好`+`在Swift中就是一个类型为`(Int, Int) -> Int`的函数，所以直接当成第三个参数的实参传进去就可以了，`+`其实就等价于上边写的`sum`函数*)

```swift
execute(1, 2, algorithm: +) // 3
```

调用方式五：

(*使用**尾随闭包**的方式，可以直接省略函数的参数标签，至于什么是尾随闭包，那就继续往下看吧！*)

```swift
execute(1, 2) { $0 + $1 }
```

基本上也就这么5种写法了，实际开发中到底该怎么写才是最优的写法呢？

- 如果第三个实参确实很复杂，单独定义一个函数可以使代码更清晰的话，或者这个函数本来就是已经写好的，并没有必要重复定义，那么就选择**调用方式四吧**。
- 其他情况下，直接选择**调用方式五**，因为充分利用语法特性，写出更加简洁易读的代码才是王道。

> 注意
>
> 很多情况下，像调用方式二，根本就不用显示地写出返回值类型，像调用方式三，四，五，根本就不用显示地定义参数列表，因为当闭包被作为实参进行传递的时候，Swift会自动进行类型推导。



## 尾随闭包 (Trailing Closures)

如果闭包是函数的最后一个实参，使用尾随闭包可以使代码更具可读性：

- 函数其他参数可以用小括号括起来，尾随闭包直接写在括号外。

  见 *上一个标题下的**调用方式五**的写法*

- 如果函数没有其他参数，那么，小括号也可以省略。

  ```swift
  func execute(algorithm: (Int, Int) -> Int) -> Int {
      algorithm(1, 2)
  }
  
  execute { $0 + $1 } // 3
  ```



## 数组的排序举例

基于上边的知识点，我们就直接写最佳的写法吧：

(*降序*)

```swift
var numbers = [1, 5, 2, 0, 7]
numbers.sort(by: >)
// or
numbers.sort { $0 > $1 }
```



## 如何忽略参数

1. 如何使用$符号读取参数的话，那么必须在闭包表达式内读取所有的参数，否则编译报错。

   ⚠️下边的代码会报错：**error: contextual closure type '(Int, Int) -> Int' expects 2 arguments, but 1 was used in closure body execute { $0 \* 2 }**

   ```swift
   execute { $0 * 2 }
   ```

   也就是说，必须要读取 $0 和 $1，缺一不可

2. 可以使用下划线 `_` 忽略参数列表中的参数。

   (*这一点在基础语法也有介绍，即在Swift中，下划线就是用来做忽略的，几乎可以使用到任何地方。*)

   ```swift
   execute { _, _ in 20 } // 20
   ```



## 闭包 (Closures)

其实官方对闭包有一个广义的定义：**闭包是自包含一定功能的代码块，并且可以在你的代码中被传递。**

有3种表现形式：

1. 全局函数
2. 嵌套函数(有*能力捕获外层函数的局部变量/常量*)
3. 闭包表达式(*如果是局部定义的，同样也有能力捕获外层函数的局部变量/常量*)



## 闭包可以捕获局部变量/常量

既然是捕获，那么顾名思义，就是，直接将局部变量/常量拷贝一份给闭包，这样局部变量/常量game over以后(*即作用域执行完成以后，栈空间的内存就会被释放，比如一个函数执行完成以后，它内部的局部变量/常量就会被释放掉*)，拷贝的那一份还依然存在，这就是一种**保命**操作。

来看一个官方提供的例子：

*函数makeIncrementer接收一个Int类型的参数，返回一个类型为() -> Int的函数(闭包)，而且内部嵌套函数incrementer里边用到了外层函数的变量runningTotal*。

```swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
```

可以这样去调用：

```swift
var incrementBy10 = makeIncrementer(forIncrement: 10)

incrementBy10() // 10
incrementBy10() // 20
incrementBy10() // 30
```

incrementBy10就是一个闭包变量，其内部捕获了runningTotal，这样每次执行incrementBy10，runningTotal都会累加10。

如果我们像下边这样用一个类来**类比**incrementBy10的类型的话，姑且将它的类型命名成Closure，就一目了然了：

```swift
class Closure {
    var runningTotal = 0
    
    func incrementer() -> Int {
        runningTotal += 10
        return runningTotal
    }
}

var incrementBy10 = Closure()

incrementBy10.incrementer() // 10
incrementBy10.incrementer() // 20
incrementBy10.incrementer() // 30
```

所以，你不觉得闭包和一个类的实例对象很像么！

**闭包和class一样都是引用类型。**

> 注意：
>
> 如果makeIncrementer有多个局部变量被嵌套函数捕获的话，也就相当于给类Closure中多添加了几个对应的属性；
>
> 如果makeIncrementer有多个嵌套函数并且其返回值返回了多个闭包(*多个返回值的实现有很多，比如放在元组中*)，也就相当于给类Closure中多添加了几个对应的方法。



## 逃逸闭包 (Escaping Closures)

类型为函数类型的函数参数，在函数return之后才会被执行的话，就需要加上一个修饰符@escaping，用来表明该函数参数是一个逃逸闭包：

```swift
class Person {
    private var friends: [() -> String] = []
    
    func makeFriend(_ friend: @escaping @autoclosure () -> String) {
        friends.append(friend)
    }
    
    func introduceFriends() {
        friends.forEach {
            print($0())
        }
    }
}

let xiaoming = Person()
xiaoming.makeFriend("xiaohong")
xiaoming.makeFriend("xiaohua")

xiaoming.introduceFriends()
```

Person在交朋友的时候，他只会在需要的时候再向外界介绍他的朋友们。



## 自动闭包 (Autoclosures)

自动闭包就是会自动将传进去的实参包装成一个类型为`() -> T`的闭包，这样做的目的就是，在传入实参的那一刻，闭包并不会被执行，而是会等到需要执行的时候才去执行闭包，看个例子：

```swift
func firstPositive(_ v1: Int, _ v2: Int) -> Int {
    v1 > 0 ? v1 : v2
}

firstPositive(10, 20) // 10
```

如果将这段代码的v2的实参换成一个函数调用，而且这个函数内部的操作及其复杂，比如该函数定义如下：

```swift
func getNumber() -> Int {
    print(#function)
    let a = 10
    let b = 20
    let c = 30
    return a + b + c
}

firstPositive(10, getNumber()) // 10 getNumber()
```

这样，每次调用firstPositive，getNumber函数都会被调用并将其返回值作为实参。

但是v1 > 0，getNumber函数的返回值在firstPositive内部根本就用不到，这样的代码是可以优化的，将v2改成一个函数类型，并延时调用：

```swift
func firstPositive(_ v1: Int, _ v2: () -> Int) -> Int {
    v1 > 0 ? v1 : v2()
}

func getNumbers() -> Int {
    print(#function)
    let a = 10
    let b = 20
    let c = 30
    return a + b + c
}

firstPositive(10, getNumbers) // 10
```

如果用自动闭包的话，就可以再改成下边的样子：

```swift
/// Return v1 if it's positive, otherwise, return v2
/// - Parameters:
///   - v1: the first integer
///   - v2: the second integer, an autoclosure, may or may not be executed
func firstPositive(_ v1: Int, _ v2: @autoclosure () -> Int) -> Int {
    v1 > 0 ? v1 : v2()
}

func getNumbers() -> Int {
    print(#function)
    let a = 10
    let b = 20
    let c = 30
    return a + b + c
}

firstPositive(10, getNumbers()) // 10
```

> 注意
>
> 如果在一个函数中使用了自动闭包，最好添加一句注释，用来说明该参数有可能被延时执行。

