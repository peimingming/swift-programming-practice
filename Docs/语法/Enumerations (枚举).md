[TOC]



# Enumerations (枚举)

在C语言系统中，枚举其实对应的就是整型值，而且不能有关联值，计算属性，方法，初始化方法等，而在Swift中，枚举是一种新的值类型，其功能更加强大。



## 枚举的基本用法

用枚举类型来枚举四季 (*每个case可以独占一行*)：

```swift
enum Season {
    case spring
    case summer
    case autumn
    case winter
}
```

或者，case可以写在一行用逗号隔开：

```swift
enum Season {
    case spring, summer, autumn, winter
}
```

关于枚举的基本用法，已经在流程控制章节中说过了，本章我们主要看看它的其他用法。



## 关联值 (Associated Values)

枚举的每一个case都可以拥有关联值，这在实际开发中非常有用。

```swift
enum Score {
    case points(Int)
    case grade(Character)
}

let score = Score.points(100)

switch score {
case .points(let points):
    print(points, "points")
case .grade(let grade):
    print("grade", grade)
}
```

这里需要注意的点如下：

- 每一个case定义的关联值可以拥有参数标签，比如定义第一个case可以这样写: `case points(points: Int)`, 上边的例子当然并不适合加标签，如果case有多个关联值的话，适当增加标签，会增强代码的可读性。

- 如果一个case有多个关联值，每一个关联值用逗号隔开，case points(subject1: Int, subject2: Int)。

- 用switch来遍历每一个case的时候，上边的例子不仅仅可以用let, 也可以用var。

- 上边的例子let可以写在括号内部，也可以直接写在case之后，比如：`case let .points(points):`。

- 某些情况下，也可以使用if/guard来匹配case，比如：

  ```swift
  if case .points(let points) = score {
      print(points, "points")
  }
  ```



## 原始值 (Raw Values)

在定义枚举的时候，可以给每一个case指定一个相同的类型，然后给每一个case指定一个原始值。

```swift
enum PokerSuit: Character {
    case spade = "♠️"
    case heart = "♥️"
    case diamond = "♦️"
    case club = "♣️"
}

var suit = PokerSuit.spade
suit = .heart
suit.rawValue // ♥️
PokerSuit.club.rawValue // ♣️
```

原始值类型也可以使用`String`等其他类型：

```swift
enum Grade: String {
    case perfect = "perfect"
    case great = "great"
    case good = "good"
    case bad = "bad"
}

Grade.perfect.rawValue // perfect
Grade.great.rawValue // great
Grade.good.rawValue // good
Grade.bad.rawValue // bad
```

原始值类型如果是`String`或者`Int`的话，系统会自动分配原始值，这个就是：**隐式返回值 (*Implicitly Assigned Raw Values*)**

- 原始值是`String`：

  ```swift
  enum Direction: String {
      case north = "north"
      case south = "south"
      case east = "east"
      case west = "west"
  }
  ```

  等价于

  ```swift
  enum Direction: String {
      case north
      case south
      case east
      case west
  }
  ```

  ```swift
  Direction.north.rawValue // north
  Direction.east.rawValue // east
  ```

- 原始值是`Int`:

  这个就和C语言的枚举有点类似了，默认每一个case的原始值从0开始。

  ```swift
  enum Season: Int {
      case spring
      case summer
      case autumn
      case winter
  }
  
  Season.spring.rawValue // 0
  Season.summer.rawValue // 1
  Season.autumn.rawValue // 2
  Season.winter.rawValue // 3
  ```

  如果指定了某一个case的原始值，那么之后的case如果在没有指定原始值的情况下其原始值依次递增。

  ```swift
  enum PokerRank: Int, CaseIterable {
      case ace = 1
      case two, three, four, five, six, seven, eight, nine, ten
      case jack, queen, king
  }
  
  PokerRank.ace.rawValue // 1
  print(PokerRank.allCases.map { $0.rawValue })
  // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
  ```



## 递归枚举 (Recursive Enumerations)

如果枚举中的case存在递归的情况，就需要用`indirect`关键字进行修饰：

```swift
indirect enum ArithmeticExpression {
    case number(Int)
    case sum(ArithmeticExpression, ArithmeticExpression)
    case difference(ArithmeticExpression, ArithmeticExpression)
}

extension ArithmeticExpression {
    var result: Int {
        switch self {
        case .number(let number):
            return number
        case let .sum(expression1, expression2):
            return expression1.result + expression2.result
        case let .difference(expression1, expression2):
            return expression1.result - expression2.result
        }
    }
}

let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.sum(five, four)
let difference = ArithmeticExpression.difference(five, four)
sum.result // 9
difference.result // 1
```

`indirect`可以对整个枚举类型进行修饰，也可以单独对case进行修饰：

```swift
enum ArithmeticExpression {
    case number(Int)
    indirect case sum(ArithmeticExpression, ArithmeticExpression)
    indirect case difference(ArithmeticExpression, ArithmeticExpression)
}
```