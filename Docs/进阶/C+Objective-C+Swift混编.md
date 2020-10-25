[TOC]



# C + Objective-C + Swift 混编

[示例代码: Etiquette](../../Source/C+Objective-C+Swift/Etiquette)



## 在Swift中调用Objective-C / C

[官方文档](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift)

### App

1. 创建一个桥接 `.h` 文件，一般命名为`{ProductModuleName}-Bridging-Header.h`，比如在示例代码`EtiquetteHost`中的桥接文件`EtiquetteHost-Bridging-Header.h`，并在{Target}->BuildSettings里头配置对应的桥接文件相对路径，在这个`.h`文件中导入需要暴露给Swift的Objective-C / C头文件。这个文件在第一次创建一个新的编程语言文件时会询问是否要自动创建，选择'Create Bridging Header'即可。
2. 在任何一个Swift文件中，就可以直接调用到对应的Objective-C / C代码。

### Framework

1. 确保{Target}->BuildSettings->Packaging->Defines Module设置的是YES。

2. 在umbrella header文件中，即示例代码中的`Etiquette.h`，导入需要暴露给Swift的Objective-C / C头文件。

   > **限制**
   >
   > 导入的头文件必须是Public的。

   

## 在Objective-C / C中调用Swift

[官方文档](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c)

### App

直接在需要调用Swift代码的.m文件中(*`{ProductModuleName}-Swift.h`是系统自动生成的*)：

#import "{ProductModuleName}-Swift.h"

### Framework

1. 确保{Target}->BuildSettings->Packaging->Defines Module设置的是YES。

2. 直接在需要调用Swift代码的.m文件中(*`{ProductModuleName}-Swift.h`是系统自动生成的*)：

   \#import <{ProductName}/{ProductModuleName}-Swift.h>

   > **限制**
   >
   > Swift代码必须要用Public修饰。



## 在Objective-C / C头文件中访问Swift代码

不要直接#import，好的做法是使用：

@class xxx

@protocol xxx

然后在.m文件中#import。



## 关于混编的考量

1. 可以发现，如果在Framework中进行混编的话是有一些限制的，比如要混编的代码必须是public才行，这样可能会暴露给外界一些我们并不想让外界访问到的API，这个时候其实也有一个解决思路，就是不要使用官方推荐的方法了，直接使用像App中一样的桥接文件。
2. 如果可以话，就用纯Swift代码做开发吧，尽量不要在一个项目中使用多种开发语言，除非是老得掉牙的项目，不得不这样做，原因如下：
   - Swift在各个方面都要优于Objective-C / C，所有没有理由不选择它。
   - 混编的framework，做不到将ProductName和ModuleName设置成不一样的值，因为在有些特殊需求下，就是要将他们设置成不一样的值。

