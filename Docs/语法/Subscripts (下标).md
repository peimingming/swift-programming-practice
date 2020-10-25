[TOC]



# Subscripts (下标)

任意类型(*枚举，结构体和类*)都可以拥有下标功能，可以将下标功能与计算属性和方法进行类比，其实，下标语法的本质就是方法。

```swift
struct Point {
    var x = 0.0
    var y = 0.0
    
    subscript(index: Int) -> Double {
        set {
            if index == 0 {
                x = newValue
            } else if index == 1 {
                y = newValue
            } else {
                fatalError("index is out of bound.")
            }
        }
        get {
            if index == 0 {
                return x
            } else if index == 1 {
                return y
            }
            fatalError("index is out of bound.")
        }
    }
}

var point = Point()
point[0] = 11
point[1] = 22
print(point) // Point(x: 11.0, y: 22.0)
```

subscript的特性，可以类比**计算属性和方法**：

1. subscript的返回值决定了get方法的返回值类型以及set方法中newValue的类型。
2. subscript可以定义多个参数，并且可以是任意类型。
3. subscript的参数可以拥有参数标签，这样使用的时候也需要写上对应的参数标签。
4. subscript和计算属性一样，可以只拥有get，计算属性的使用细节请查看 属性 章节。
5. subscript可以是类型方法，即使用static/class对subscript进行修饰，用法也基本上和类型方法类似，关于类型方法的使用细节，请参考 方法 章节。

另外，关于值类型(enum/struct)和引用类型(class)在使用subscript的时候，有一些细微的差别，示例如下：

(*该示例也可以用来演示值类型和引用类型的本质区别*)

```swift
struct Point {
    var x = 0.0
    var y = 0.0
}

class PointManager {
    var point = Point()
    
    subscript(index: Int) -> Point {
        point
    }
}

var pointManager = PointManager()
pointManager[0].x = 11
pointManager[0].y = 22

print(pointManager[0].x)
print(pointManager[0].y)
```

上边这段代码会编译报错：

❌**Cannot assign to property: subscript is get-only**

可以这样修改：

- 将`struct Point`改成`class Point`就可以了。

- 或者给上述subscript提供一个set方法。

可以思考一下是为什么！

> 注意
>
> 值类型和引用类型的本质区别可以查看 结构体和类 章节。

