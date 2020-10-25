[TOC]



# Optional Chaining (可选链)

可选链：多个?可以链接在一起，形成一个调用链，如果链中任何一个节点是nil，那么整个链就会调用失败。



## 可选链的规则

```swift
struct Car { var price = 0 }
struct Dog { var weight = 0 }

struct Person {
    var name: String = ""
    var dog: Dog = Dog()
    var car: Car = Car()
    var age: Int { 18 }
    func eat() { print("Person eat.") }
    subscript(index: Int) -> Int { index }
}
```

1. 如果可选项为nil，调用方法，下标，属性失败，结果为nil，并且从可选项这个节点之后的链条都不会被执行。

   ```swift
   let person: Person? = nil
   
   let age = person?.age
   print(age as Any) // nil
   let name = person?.name
   print(name as Any) // nil
   let index = person?[6]
   print(index as Any) // nil
   
   let result = person?.eat()
   print(result as Any) // nil
   //结果为nil，且没有print打印，说明eat方法并没有被调用。
   ```

   > 注意
   >
   > 上述代码中的eat方法看起来并没有返回值，为什么还可以用result接收返回结果呢，其实，没有设定返回值的函数都有一个默认的返回值 Void，即 `public typealias Void = ()`，也就是说Void和()等价，所以上边的result的类型其实是()?。
   >
   > 开发中，往往会结合可选项绑定来判断方法是否执行成功 (*下边的条件判断也可以写成 `person?.eat() != nil`*)：
   >
   > ```swift
   > if let _ = person?.eat() {
   >     print("eat() is invoked")
   > } else {
   >     print("eat() is not invoked")
   > }
   > 
   > // Output: eat() is not invoked
   > ```

2. 如果可选项不为nil，调用方法，下标，属性成功，结果会被包装成可选项。

   ```swift
   let person: Person? = Person()
   
   let age = person?.age
   print(age1 as Any) // Optional(18)
   let name = person?.name
   print(name as Any) // Optional("")
   let index = person?[6]
   print(index as Any) // Optional(6)
   ```

   > 注意
   >
   > 在开发中，如果确保可选项不为nil的话，在语法层面，也可以像下边这样写：
   >
   > ```swift
   > let age = person!.age
   > print(age2) // 18
   > ```
   >
   > 这样age的类型就是非可选项，因为person已经被强制解包了，不过这样的代码，在一般的代码标准中是被禁止掉的，**开发中，不要写这样的代码**，具体原因请查看 **可选项** 章节。

3. 如果结果本来就是可选项，不会进行再次包装。



## 可选链在数组和字典中的应用举例

字典中，通过key取出来的value默认就是可选项，所以在可选链中需要添加?，示例如下：

```swift
var scores = ["Jack": [80, 90, 100], "Eric": [100, 99, 98]]

scores["Jack"]?[0] = 100
print(scores) // ["Eric": [100, 99, 98], "Jack": [100, 90, 100]]

scores["Eric"]?[2] = 99
print(scores) // ["Eric": [100, 99, 99], "Jack": [100, 90, 100]]

scores["Rose"]?[0] = 100
print(scores) // ["Jack": [100, 90, 100], "Eric": [100, 99, 99]]
// scores["Rose"]?[0] = 100 的赋值操作并没有发生，可以通过上边介绍的判断函数返回值的方式来证明，毕竟运算符=在Swift中就是函数。
```

下边示例的运算符 + 和 - 在Swift中就是函数，类型: (Int, Int) -> Int, 这种写法在 **闭包** 章节有介绍：

```swift
let algorithms: [String: (Int, Int) -> Int] = [
    "sum": (+),
    "difference": (-)
]
algorithms["sum"]?(1, 2) // 3
```



## 可选链的赋值操作

下边的代码很少见到，但是见到了也不要奇怪，项目中有这样的特殊需求的话，也不妨用一用：

即，对于赋值操作 - `number? = xxx`，如果可选项number有值，那么赋值操作成功，否则失败。

```swift
var number: Int? = 5
number? = 10
print(number as Any) // Optional(10)

number = nil
number? = 100
print(number as Any) // nil
```

