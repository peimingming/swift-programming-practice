[TOC]



# Control Flow (流程控制)

相较于Objective-C，Swift的流程控制语句的条件两边的小括号可写可不写，所以也就不用写了，而且条件结果必须是Bool类型。



## if else

条件判断语句，这个没有什么好说的，就是用来做判断的，和其他编程语言很类似。

代码片段1:

```swift
let age = 18

if age <= 1 {
    print("Baby")
} else if age < 18 {
    print("Child")
} else {
    print("Adult")
}
```

但是if else还有一个比较有用的用法就是和可选类型搭配使用，也就是所谓的可选绑定，如果把*代码片段1*中的age类型变成可选类型的话，同样的判断可以改写成这样：

代码片段2:

```swift
let age: Int? = 18

if let age = age,
    age <= 1 {
    print("Baby")
} else if let age = age,
    age < 18 {
    print("Child")
} else if let age = age,
    age >= 18 {
    print("Adult")
} else {
    print("age is nil")
}
```

这里的`let`也可以换成`var`。

不过这样使用可选绑定依然不是最佳的写法，因为要多次地重复使用可选绑定来给age做解包操作，这个时候，`guard`就要来炫耀一下它的存在感了，往下看。



## guard

其实guard就是if else的一个变体，无非就是语法稍微变化了一下，先看看如何使用guard来改写上边的*代码片段1*:

代码片段1+guard:

```swift
let age = 18

func useGuard() {
    guard age > 1 else {
        print("Baby")
        return
    }

    guard age >= 18 else {
        print("Child")
        return
    }

    print("Adult")
}
```

可见，guard就是用来确保条件为真才能继续往下走，否则走else，并return，当然这里不一定非要用return，也可以使用throw来抛一个error，或者使用fatalError来终止程序进程，总而言之，只要满足能让程序没法继续往下走就可以。

虽然这个改写也可以，但是这样的改写貌似没有多大意义，因为使用if else代码貌似看起来更清晰。

接下来，我们用guard来改写一下*代码片段2*，因为我们上边说了它要炫耀一下存在感。

代码片段2+guard:

```swift
let age: Int? = 18

func useGuard() {
    guard let age = age else {
        print("age is nil")
        return
    }
    
    if age <= 1 {
        print("Baby")
    } else if age < 18 {
        print("Child")
    } else {
        print("Adult")
    }
}
```

使用Guard的话，age只需要被解包一次即可，之后的代码就可以直接使用解包后的age。



## `if else` vs `guard`

既然都是流程控制语句，那么该使用哪个呢？上边我们已经做过演示了，总结如下：

- 在保证代码可读性的前提之下，尽量使用guard，避免程序有过多的if else嵌套。
- 如果在方法中使用了过多的guard和if else，而且代码已经看起来很臃肿了，这个时候就需要考虑重构了，使用流程控制语句来解决问题已经不合适了。

所以，不管使用什么，代码的可读性和高效率执行才是最关键的，不要为了写代码而写代码，写代码归根结底是为了解决实际问题，这里又不得不再提一下我们之前多次提到过的一句流行语：

***Less is more*** (少即是多，合适的才是最好的)



## while

while

```swift
var number = 5

while number <= 10 {
    print(number)
    number += 1
}
```

repeat while, 相当于C语言中的do while

```swift
var number = 5

repeat {
    print(number)
    number += 1
} while number <= 10
```

> 注意
>
> 以上代码的`number += 1`，也可以写成`number = number + 1`, 但是C语言中的自增自减运算符在Swift中已经没有了，想必是考虑到这个运算符真的是不仅没有特别大的用处，而且放在不同的位置，会产生不同的效果才没有把它做成系统的运算符，想想，之前是不是有这样的C语言题目，把++/--放在操作数的前边或者后边让你写出运算结果，或者是多个++/--放在一个表达式中，而且还不加括号，让你写出运算结果，只能说这是C语言的奇技淫巧，实际项目中如果这样写，恐怕难免会被队友diss。
>
> 另外，如果你真的是想使用++/--, 也可以，你只需要去自定义这样的运算符，Swift是支持自定义运算符的，自定义运算符在函数式编程中会被经常用到，为的就是让缠绕在一起的代码变得行云流水。



## for

**开/闭区间**

闭区间: a...b 表示 a <= 取值 < b, 对应的类型是: ClosedRange<Bound>

开区间: a..<b 表示 a <= 取值 < b, 对应的类型是: Range<Bound>

单侧区间: a... / ...a / ..<a 让区间朝一个方向尽可能地远, 对应的类型是: PartialRangeFrom<Bound>, PartialRangeThrough<Bound>, PartialRangeUpTo<Bound>

> 注意
>
> - 开区间只能是右开区间
> - a和b可以是字面量也可以是常量或者变量

```swift
let names = ["Jack", "Tom", "Jason", "Anna", "Eric"]
for i in 0...3 {
    print(names[i])
}
```

这里i默认是常量let, 也可以显式地使用var: var i，这样i在for里边就可以被赋值了。

```swift
for var i in 0...3 {
    i += 5
    print(i)
}
```

也可以将开闭区间用在数组里：

```swift
let names = ["Jack", "Tom", "Jason", "Anna", "Eric"]

for name in names[0...3] {
    print(name)
}

for name in names[...3] {
    print(name)
}

for name in names[3...] {
    print(name)
}

for name in names[..<3] {
    print(name)
}
```

String和Character也可以使用区间，不过不支持for in操作，但是仍然可以使用区间的方法，比如：

```swift
let range1: ClosedRange<Character> = "c"..."f"
range1.contains("d") // true

let range2 = "cc"..."ff"
range2.contains("cd") // true
```

带间隔区间: strideThrough<T>, strideTo<T>：

```swift
let hour = 12
let interval = 2

for tick in stride(from: 4, through: hour, by: interval) {
    print(tick) // 4, 6, 8, 10, 12
}

for tick in stride(from: 4, to: hour, by: interval) {
    print(tick) // 4, 6, 8, 10
}
```

有时候在遍历数组的时候也想读取index值的话，可以这样去做：

```swift
let names = ["Jack", "Tom", "Jason", "Anna", "Eric"]

for (index, name) in names.enumerated() {
    print(index, name)
}
```

如果根本就用不到index的话，那就直接这样做：

```swift
for name in names {
    print(name)
}
```



## switch

Switch常用到枚举类型中，当然也可以用到其他类型，比如整型，字符，字符串，元组等。

假设有一个枚举类型: Season, 常量season为它的一个实例：

```swift
enum Season {
    case spring
    case summer
    case autumn
    case winter
}

let season = Season.summer
```

使用Switch来匹配season对应的case:

- 这里每一个case的条件也可以写成Season.xxx, 但是由于season是有确定类型的，所有可以省略类型Season, 直接写成.spring, .summer, .autumn, .winter。

- 如果Switch可以穷尽所有的case，那么就不用在最后写default。

- 每一个case至少要有一条语句。

- 默认情况下，case与case之间不会贯穿，所以每一条case可以不写break。

  使用关键字fallthrough, 可以使case贯穿，比如, 给以下代码的print("summer")加多一条语句fallthrough, 那么运行结果将是：summer autumn。

- 多条case写在一行的话，需要用逗号隔开，比如：case .spring, .summer:

```swift
switch season {
case .spring:
    print("spring")
case .summer:
    print("summer")
case .autumn:
    print("autumn")
case .winter:
    print("winter")
}
```

Switch匹配区间(即case使用区间进行模糊匹配)：

```swift
let count = 10000

switch count {
case 0:
    print("none")
case 1..<5:
    print("a few")
case 5..<12:
    print("several")
case 12..<100:
    print("dozens of")
case 100..<1000:
    print("hundreds of")
case 1000..<10_000:
    print("thousands of")
default:
    print("many")
}
```

Switch匹配元组(元组的每一个元素同样可以使用区间进行模糊匹配)：

> 注意
>
> 之前在基础语法中，我们讲过，对于不想要读取的值，可以用_来忽略掉。

```swift
let point = (1, 1)

switch point {
case (_, 0):
    print("on the x axis")
case (0, _):
    print("on the y axis")
case (-2...2, -2...2):
    print("inside the box")
default:
    print("outside the box")
}
```

Switch匹配元组，使用值绑定：

> 可以使用let也可以使用var，并且let, var可以分开修饰单个元素，即放在括号里边，也可以修饰整个元组，即放在括号外边。

```swift
let point = (1, 1)

switch point {
case (let x, 0):
    print("on the x axis with a value of \(x)")
case (0, let y):
    print("on the y axis with a value of \(y)")
case let (x, y):
    print("somewhere else at (\(x), \(y))")
}
```



## where

条件约束，可以用于for和switch。

比如，有一个数组：
`var numbers = [20, 30, -40, 10, 55]`

要求打印出所有的正数(*可以把条件约束写在where后边*):

> 注意
>
> where只能写一个，也就是说，如果有多个条件约束的话，就得使用 &&或者||，比如再加一个number必须小于30的约束条件的话，就得写成这样: where number > 0 && number < 30

```swift
for number in numbers where number > 0 {
    print(number)
}
```

switch语句则需要将where写在每一个case的后边：

```swift
let point = (1, 1)

switch point {
case let (x, y) where x == y:
    print("on the line x == y")
case let (x, y) where x == -y:
    print("on the line x == -y")
case let (x, y):
    print("(\(x), \(y)) is just an arbitrary point")
}
```

if, while虽然不能用where，但是其条件约束可以写在if和while之后，多个条件用逗号隔开：

```swift
let number = 10

if number > 0,
    number < 100 {
    print(number)
}
```

```swift
let flag = true
var number = 10

while flag, number > 0 {
    print("haha")
    number -= 1
}
```



## 标签语句

可以给for或者while循环语句添加一个标签，这样，就可以在多个循环嵌套内部通过该标签操作外部循环，比如break/continue：

```swift
var number = 6
outer: while true {
    while true {
        if number <= 0 {
            break outer
        }
        print(number)
        number -= 1
    }
}
```

```swift
outer: for i in 0...3 {
    for j in 0...6 {
        if j == 3 {
            continue outer
        }
        if i == 3 {
            break outer
        }
        print("i = \(i)", "j = \(j)")
    }
}
```

