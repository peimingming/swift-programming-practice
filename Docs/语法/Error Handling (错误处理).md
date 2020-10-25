[TOC]



# Error Handling (错误处理)

程序中的错误大概分以下几类：

1. 编译错误 (*有可能是语法错误或者语法使用不当导致编译阶段就报错*)。
2. 逻辑错误 (*代码逻辑问题导致的错误*)。
3. 运行时错误，也叫异常 (*即 程序运行起来才产生的错误，一般表现为程序闪退*)。

Swift中所说的**错误处理**，即第三点 - **运行时错误**。



## 自定义错误

函数内部可以通过throw关键字抛出自定义错误，该自定义错误的类型必须遵守Error协议，可能会抛出Error的函数必须加上throws声明。

> 注意
>
> 下边的类型DivisionError，也可以换成结构体或类，需要根据具体需求来选择，不过通常情况下，使用枚举来罗列出所有的错误case是一种比较常见的做法。

```swift
enum DivisionError: Error {
    case illegalArgument(message: String)
}

func divide(_ v1: Int, _ v2: Int) throws -> Int {
    guard v2 != 0 else {
        throw DivisionError.illegalArgument(message: "Divisor can not be 0.")
    }
    
    return v1 / v2
}
```

需要使用try关键字来调用可能会抛出Error的函数：

(*下边的代码，如果把第二个参数换成0，程序就会闪退，因为我们并没有处理抛出来的Error。*)

```swift
let result = try divide(10, 5) // 2
```



## 处理Error

有以下3种方式：

1. do-catch。

   - 如果函数divide抛出了其他的Error，就会走到最后一个catch里边。
   - 抛出Error后，try下一句直到作用域结束的代码都将停止运行，比如，下边的代码如果抛出error，`print(result)`就不会执行。

   ```swift
   do {
       let result = try divide(10, 5)
       print(result) // 2
   } catch let DivisionError.illegalArgument(message: message) {
       print(message)
   } catch {
       print("Unknown error: \(error)")
   }
   ```

2. 将Error抛给上层函数。

   - divide函数的调用者可以不处理Error，将Error继续往上抛，比如在test函数内部调用divide，这样就把处理Error的职责交给了test函数的调用者：

     ```swift
     func test() throws {
         print(try divide(10, 5))
     }
     ```

   - 或者，直接像下边这样写，Error就会自动抛给上层函数，直到被处理为止，如果确实抛出了Error，而上层函数一直到顶层都没有处理该Error， 那么程序闪退：

     ```swift
     let result = try divide(10, 5) // 2
     ```

3. 使用 try? 或者 try! 来忽略Error。

   - try?

     result是可选类型，如果抛出Error，那么result就会是nil。

     ```swift
     let result = try? divide(10, 5) // 2
     ```

   - try! (*实际开发中，一般禁止使用，任何强制解包的操作在实际开发中都是不推荐使用的。*)

     result是非可选类型，如果抛出Error，运算结果为nil, try!会进行强制解包，程序就会闪退。

     ```swift
     let result = try! divide(10, 5) // 2
     ```



## rethrows

rethrows: 函数本身不会抛出Error，但是闭包参数有可能会抛出Error，使用rethrows表明该函数的调用者需要处理该Error。

(*下边的rethrows也可以换成throws, 但是正规的做法还是使用rethrows。区别就在于，使用throws的话，函数内部还可以抛出其他Error。*)

```swift
func test(_ fn: (Int, Int) throws -> Int, v1: Int, v2: Int) rethrows {
    print(try! fn(v1, v2))
}
```



## defer

清理操作 (*官方文档叫 cleanup action*)，有时候需要在函数，代码块作用域结束之前(*在return, throw之后*)执行一些代码，就可以用defer。

比如，文件操作，打开文件进行操作，但是有很多种情况会导致操作失败或者操作提前退出，并且无论如何，我们都希望在最后关闭文件：

```swift
func processFile(filename: String) throws {
    if exists(filename) {
        let file = open(filename)
        defer {
            close(file)
        }
        while let line = try file.readline() {
            // Work with the file.
            // Throw error if needed.
            throw FileError.anyError
        }
        // close(file) is called here, at the end of the scope.
    }
}
```

defer语句的执行顺序与定义顺序相反：

```swift
func test() {
    defer {
        print(1)
    }
    defer {
        print(2)
    }
    defer {
        print(3)
    }
}

test()

//3
//2
//1
```



## assert & fatalError & precondition

这3个函数都可以使得程序终止运行，因为确实是有一些需求需要程序终止运行，先看看各自的特点：

1. assert断言函数，默认只在Debug模式下起作用，可以通过下边的方式进行自定义配置：

   Build Settings -> Other Swift Flags

   **-assert-config Release**：表示强制关闭断言

   **-assert-config Debug**：表示强制开启断言

2. fatalError在任何模式下都会强制终止程序运行。

3. precondition在不满足给定条件的情况下会强制终止程序运行。

实际开发中，需要根据具体的需求来决定用哪一个，比如：

- 如果你只希望在开发阶段或者调试程序的时候才会在指定的位置终止运行程序，那么就用assert。
- 如果你写了一段代码，并不希望任何人去调用，或者在你还没有想好如何去实现的时候，可以用fatalError。
- 如果你写了一个关于keychain操作的函数，可以接收keychain操作的参数，但是如果外界传进来的参数刚好覆盖了你默认设定的一些参数的话，而这种行为在你看来是需要禁止掉的，那么就用precondition。

