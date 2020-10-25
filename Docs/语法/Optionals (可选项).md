[TOC]



# Optionals (可选项)

Swift之所以是一门强类型的编程语言，就是因为它有一个可选项的概念，即所有的值只可能有两种情况：有值或者没有值：

```swift
public enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
```



## 可选项的定义

在类型后边加一个 ? 来定义一个可选项。

```swift
var name: String? = nil
name = nil

// 默认就是nil
var age: Int?
age = 30
age = nil
```

Swift中数组的操作在访问越界的时候会直接crash：

**Fatal error: Index out of range**

```swift
var array = [1, 20, 40, 60, 25]
array[100]
```

不过我们可以为数组扩展一个返回值为可选项的方法，当数组越界的时候返回一个空值:

```swift
extension Array where Element == Int {
    func get(_ index: Int) -> Int? {
        guard index > 0, index < count else { return nil }
        return self[index]
    }
}

print(array.get(1) as Any) // Optional(20)
print(array.get(10) as Any) // nil
```



## 强制解包 (Forced Unwrapping)

可选项就像一个盒子，如果有值的话，盒子里就装着被包装的数据，如果没有值的话，就是一个空盒子。

可以使用 ! 进行强制解包，取出盒子中的数据：

```swift
var age: Int? = 10
print(age!) // 10
```

但是，如果强制解包空盒子的话，程序就会crash：

**Fatal error: Unexpectedly found nil while unwrapping an Optional value**

```swift
var age: Int? = 10
age = nil
age!
```

所以就需要在强制解包之前判断一下可选项是否为空：

```swift
var age: Int? = Int("20")
if age != nil {
    print("age:", age!)
} else {
    print("age is nil")
}

// age: 20
```

在项目开发中，应该避免使用强制解包，一般编码标准里边是严禁使用强制解包的，原因只有一个：不安全。

取而代之，应该使用更加安全的方式去做解包操作，比如：可选项绑定。



## 可选项绑定 (Optional Binding)

可以使用`let`或者`var`来接收解包后的值，绝大多数的控制语句都可以进行可选项绑定操作。

**if**

```swift
if let number = Int("123456") {
    print("number is", number)
} else {
    print("number is nil")
}
```

**guard**

*在一个函数中使用guard。*

```swift
func test() {
    guard let number = Int("123456") else {
        print("number is nil")
        return
    }
    print("number is", number)
}
```

**while**

*遍历数组，将遇到的正数相加，如果遇到非正数则停止遍历。*

```swift
let array = ["40", "20", "100", "ahaha", "-1", "60"]

var index = 0
var sum = 0
while let number = Int(array[index]), number > 0 {
    sum += number
    index += 1
}

print(sum) // 160
```

可以将多个可选项绑定语句或者其他的条件用逗号隔开，相当于 &&：

```swift
if let number1 = Int("21"),
    let number2 = Int("12"),
    number1 > number2 {
    print(number1, number2)
} else {
    print("numbers are nil")
}

// 21, 12
```



## 空合并运算符 (Nil-Coalescing Operator)

`??` 

i.e. a ?? b

用一段伪代码来解释一下 ?? 的用法

```pseudocode
if a is not nil {
	return b is not optional ? a! : a
} else {
	return b
}
```

有以下规则需要遵守：

- a是可选项
- b可以是可选项，也可以是非可选项
- b和a的存储类型必须相同
- 如果a不为空，就返回a
- 如果a为空，就返回b
- 如果b不是可选项，返回a时会自动解包



## 隐式解包 (Implicitly Unwrapped Optional)

Type!

可以在定义变量的时候给类型后边加一个 ! 来表示该变量会在需要解包的地方自动进行强制解包，**显然这种做法也是极其不安全的。**

```swift
var a: Int! = 10
print(a as Any) // Optional(10)
print(a!) // 10
```

a显然还是一个可选项:

```swift
print(a ?? b) // 10

if let c = a {
    print(c) // 10
}
```

只不过当它需要被解包的时候，系统就会对它进行强制解包：

```swift
var b: Int = 20
b = a
print(b) // 10
```

如果a已经为空了，这个时候还要进行隐式解包的话，程序就会crash：

**Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value**

```swift
a = nil
b = a
```

开发中应该尽量避免使用这种危险的操作，如果真要用的话，你就得非常清楚隐式解包的变量什么时候有值，什么时候没有值，因为如果它是空的话，再隐式解包，程序就会crash。

比如UIViewController和storyboard关联的一些属性，如果你在viewDidLoad方法执行之前去调用这些属性的话，程序就会crash。



## 字符串插值

如果在字符串插值中直接使用可选项的话，会有警告报出来：

⚠️String interpolation produces a debug description for an optional value; did you mean to make this explicit?

Use 'String(describing:)' to silence this warning `fix`

Provide a default value to avoid this warning `fix`

```swift
let number: Int? = 10
print("number is \(number)")
```

系统已经给了2个消除警告的建议：

- 使用String的初始化方法

  ```swift
  print("number is \(String(describing: number))")
  ```

- 提供一个默认值

  ```swift
  print("number is \(number ?? 0)")
  ```

除此之外还有2种方法：

- 强制解包 (***不推荐***)

  ```swift
  print("number is \(number!)")
  ```

- 使用 as Any 类型转换

  ```swift
  print("number is \(number as Any)")
  ```



## 多重可选项

分两种情况：

1. 有包装值

   ```swift
   let number1: Int? = 10
   let number2: Int?? = number1
   let number3: Int?? = 10
   
   print(number1 == number2) // true
   print(number2 == number3) // true
   print(number1 == number3) // true
   ```

   结论：在有包装值的情况下，不管层级有多深，换句话说，不管盒子的层数有多少，只要包装值相等，可选项的比较结果就是等同于包装值的比较结果。

2. 无包装值

   ```swift
   let number1: Int? = nil
   let number2: Int?? = number1
   let number3: Int?? = nil
   
   print(number1 == number2) // true
   print(number2 == number3) // false
   print(number1 == number3) // false
   ```

   结论：在无包装值的情况下，在比较的时候就要考虑将不同层级的盒子拉齐对等，然后再进行比较，可以用以下的盒子理论解释上边代码的比较过程：

   number1相当于一个类型为Int?的盒子，即一个装有空气的空盒子。

   number2相当于一个类型为Int??的盒子，这个盒子中装了另外一个类型为Int?的盒子。

   number3相当于一个类型为Int??的盒子，这个盒子中装的是空气。

   number1 == number2, 进行比较的时候，就需要将number1装在一个同样类型为Int??的盒子中，这样的话，两个盒子才能变得大小一致，显然两个盒子此时的内容也是一模一样的，都是类型为Int??的盒子里套了一个类型为Int?的盒子，所有比较结果为true。

   number2 == number3, 进行比较的时候，两个盒子本来就是大小一样的盒子，只不过一个装着类型为Int?的盒子，另外一个装着空气，显然运行结果为false。

   number1 == number3, 进行比较的时候，需要将第一个盒子用Int??的盒子进行包装，同样的外包装，第一个盒子里头放着Int?, 而第二个装着空气，显然运行结果也是false。

   怎么去证明这个盒子理论呢？只有一个方法，那就是去研究Swift源码到底是怎么实现==这个运算符的。

   由于Swift是开源的，所以我们可以在GitHub上找到它的[所有源代码](https://github.com/apple/swift)。[Optional.swift](https://github.com/apple/swift/blob/master/stdlib/public/core/Optional.swift)里边就是可选项的所有代码实现。

   以下3个方法就是可选项==的对应实现：

   ```swift
   public static func ==(lhs: Wrapped?, rhs: Wrapped?) -> Bool
   public static func ==(lhs: Wrapped?, rhs: _OptionalNilComparisonType) -> Bool
   public static func ==(lhs: _OptionalNilComparisonType, rhs: Wrapped?) -> Bool
   ```

   阅读一下对应的实现吧！如果想更进一步Debug一下比较的过程，可以这样做：

   在一个Swift工程中，将以上3个方法以及对应的实现拷贝到一个新的可选项扩展中

   ```swift
   extension Optional where Wrapped: Equatable {
       public static func ==(lhs: Wrapped?, rhs: Wrapped?) -> Bool {
           print(lhs as Any, rhs as Any)
           switch (lhs, rhs) {
           case let (l?, r?):
               return l == r
           case (nil, nil):
               return true
           default:
               return false
           }
       }
       
       public static func ==(lhs: Wrapped?, rhs: _OptionalNilComparisonType) -> Bool {
           switch lhs {
           case .some:
               return false
           case .none:
               return true
           }
       }
       
       public static func ==(lhs: _OptionalNilComparisonType, rhs: Wrapped?) -> Bool {
           switch rhs {
           case .some:
               return false
           case .none:
               return true
           }
       }
   }
   ```

   然后打上断点，结合lldb指令 `frame variable -R 变量` 或者 `fr v -R 变量`(*这个是简写*) 打印出可选项的结构，即盒子的层级关系，就可以去验证上述的盒子理论了。

