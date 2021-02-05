import Foundation

//: # Calculate the expression: [(number + 3) * 5 - 1] % 10 / 2

//: ## Traditional functions

do {
    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func subtract(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiply(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    let number = 1
    let result = divide(mod(subtract(multiply(add(number, 3), 5), 1), 10), 2)
    print(result) // 4
}

//: ## FP

infix operator >>>: AdditionPrecedence
func >>><A, B, C>(f1: @escaping (A) -> B, f2: @escaping (B) -> C) -> (A) -> C { { f2(f1($0)) }}

do {
    func add(_ v: Int) -> (Int) -> Int { { $0 + v } }
    func subtract(_ v: Int) -> (Int) -> Int { { $0 - v } }
    func multiply(_ v: Int) -> (Int) -> Int { { $0 * v } }
    func divide(_ v: Int) -> (Int) -> Int { { $0 / v } }
    func mod(_ v: Int) -> (Int) -> Int { { $0 % v } }
    
    do {
        let number = 1
        let result = divide(2)(mod(10)(subtract(1)(multiply(5)(add(3)(number)))))
        print(result) // 4
    }
    
    do {
        let number = 1
        let f = add(3) >>> multiply(5) >>> subtract(1) >>> mod(10) >>> divide(2)
        let result = f(number)
        print(result) // 4
    }
}

//: # Currying

prefix func ~<A, B, C>(f: @escaping (A, B) -> C) -> (B) -> (A) -> C { { b in { a in f(a, b) } } }

do {
    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func subtract(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiply(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    let number = 1
    let f = (~add)(3) >>> (~multiply)(5) >>> (~subtract)(1) >>> (~mod)(10) >>> (~divide)(2)
    let result = f(number)
    print("Currying result:", result) // 4
}

//: # Functor

[1, 2, 3].map { $0 * 2 }
// public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]

Optional.some(10).map { $0 * 2 }
// public func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?

//: # Applicatice Functor

//: > F is a Functor, and it's also an Applicative Functor if it's able to support the below 2 functions
//: >
//: > func pure<A>(_ value: A) -> F<A>
//: > func <*><A, B>(f: F<(A) -> B>, value: F<A>) -> F<B>

infix operator <*>: AdditionPrecedence

//: ## Array is an Applicative Functor

func <*><A, B>(fs: [((A) -> B)], values: [A]) -> [B] {
    var results = [B]()
    fs.forEach { f in values.forEach { results.append(f($0)) } }
    return results
}

do {
    func pure<A>(_ value: A) -> [A] { [value] }
    
    print("--- Array is an Applicative Functor ---")
    let pureResult = pure(10)
    print("pureResult =", pureResult)
    let fs: [(Int) -> Int] = [{ $0 * 2 }, { $0 * 3 }]
    let values = [1, 3, 6]
    let secondResult = fs <*> values
    print("secondResult =", secondResult)
}

//: ## Optional is an Applicative Functor

func <*><A, B>(f: ((A) -> B)?, value: A?) -> B? {
    guard let f = f, let value = value else { return nil }
    return f(value)
}

do {
    func pure<A>(_ value: A) -> A? { value }
    
    print("--- Optional is an Applicative Functor ---")
    let pureResult = pure(10)
    print("pureResult =", pureResult as Any)
    let f: (Int) -> Int = { $0 * 2 }
    let secondResult = f <*> pureResult
    print("secondResult =", secondResult as Any)
}

//: # Monad

//: > F is a Monad if it's able to support the below 2 functions
//: > func pure<A>(_ value: A) -> F<A>
//: > func flatMap<A, B>(_ value: F<A>, _ f: (A) -> F<B>) -> F<B>
//: > Obviously, Array and Optional are Monads

[1, 2, 3].compactMap { $0 * 2 }
Optional.some(10).flatMap { $0 * 2 }
