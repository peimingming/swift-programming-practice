[TOC]



# Swift命令行工具

我们平时用的脚本语言，比较常见的就是shell script 和 python，不过Swift也可以用来写一些脚本工具。

怎么用呢？

先看看Swift在命令行终端中怎么使用：

1. 可以直接敲入Swift，然后就可以开始写Swift代码了。

   ```
   xxx:~ xxx$ Swift
   Welcome to Apple Swift version 5.1.3 (swiftlang-1100.0.282.1 clang-1100.0.33.15).
   Type :help for assistance.
     1> print("Hello Swift")
   Hello Swift
   ```

   当然这样玩一玩尚可，正规的做法还得往下看。

2. 使用`swift xxx.swift`直接运行一个Swift文件中的代码，就像通常使用`sh xxx.sh`来运行一个shell script文件一样。

   ```
   xxx:swift-cmd-tool xxx$ swift Hello.swift
   Hello
   xxx:swift-cmd-tool xxx$
   ```

   让我们用Swift写一个简单的工具来解决一个实际开发中的需求吧：

   **全局搜索给定的一些.plist文件和.strings文件(*这两个文件是干什么用的，不用做过多的解释，.plist就是一个xml文件，.strings是iOS开发中放多语言文字的*)，然后根据给定的关键字，过滤搜索到的条目，并输出到新的文件中。**

   **比如：**

   **给定一个关键字 failed。**

   **全局搜索.plist文件中的英文文字，并过滤搜索出来的所有条目，然后根据搜索出的条目的key, 去将另外两种语言对应的key所在的条目过滤出来并输出。**

   **全局搜索英文.strings文件，并过滤搜索出的所有条目，然后根据搜索出的条目的key, 去另外两种语言对应的文件中将对应的key所在的条目过滤出来。**

   怎么来完成这个需求呢？

   你大可以手动搜索，然后一条条复制粘贴到新的文件中，不过，试想一下， 如果单单一个文件的搜索结果就有上千条的话，你还愿意这么做吗？

   答案当然是: NO。花点时间写一个简单的工具来处理问题肯定比机械地复制粘贴要明智得多。

   该工具的例子我已经写好了，[示例代码请参考这里](../../Source/swift-cmd-tool)。

   为了方便使用，我写了一个shell script: filter.sh，里边其实就调用了 `swift Filter.swift`。

   最后，执行一下这个shell script就可以对所有的文件进行搜索过滤了。

   ```
   xxx:swift-cmd-tool xxx$ sh filter.sh failed
   Successfully!!! filtered file: ErrorCodes-en-Filtered.strings, count: 1
   Successfully!!! filtered file: ErrorCodes-zh_Hant-Filtered.strings, count: 1
   Successfully!!! filtered file: ErrorCodes-zh_Hans-Filtered.strings, count: 1
   Successfully!!! filtered file: ErrorCodes-Filtered.plist, count: 1
   xxx:swift-cmd-tool d3883365$
   ```

3. 还有一种脱离Swift的实践，比如本地并没有装Xcode，那就需要使用swiftc将写好的工具源码编译成可执行的文件，不过这个就要求写一个最上层的main.swift了。

   ```
   xxx:swift-cmd-tool xxx$ swiftc Greeting.swift main.swift
   xxx:swift-cmd-tool xxx$ ./main
   Hello
   xxx:swift-cmd-tool xxx$
   ```

根据实际需求来选择使用第2种和第3种方法吧！

