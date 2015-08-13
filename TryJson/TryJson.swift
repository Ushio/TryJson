//
//  TryJson.swift
//  EnumJsonConsole
//
//  Created by Ushio on 2015/08/12.
//  Copyright © 2015年 Ushio. All rights reserved.
//

import Foundation

/// Json Data Structure
public enum Json {
    case JObject  ([String : Json])
    case JArray   ([Json])
    case JNumber  (NSNumber)
    case JString  (String)
    case JBoolean (Bool)
    case JNull
}
extension Json : DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = Json
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [String : Json]()
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = .JObject(dictionary)
    }
}
extension Json : ArrayLiteralConvertible {
    public typealias Element = Json
    public init(arrayLiteral elements: Element...) {
        self = .JArray(elements)
    }
}
extension Json : StringLiteralConvertible {
    public init(stringLiteral value: StringLiteralType) {
        self = .JString(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .JString(value)
    }
    
    public typealias UnicodeScalarLiteralType = String
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .JString(value)
    }
}
extension Json : FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .JNumber(value)
    }
}
extension Json : IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .JNumber(value)
    }
}
extension Json : BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .JBoolean(value)
    }
}
extension Json : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .JNull
    }
}

public protocol JsonDecodable {
    static func decode(json: Json) throws -> Self
}

public enum JsonError : ErrorType {
    case InvalidType(String)
    case InvalidKey(String)
    case Filtered(String)
    case ParseFailed
    case Any(String)
}

public func filter<T>(lhs: T, @noescape _ rhs: T -> Bool) throws -> T {
    if rhs(lhs) {
        return lhs
    }
    throw JsonError.Filtered("\(lhs)")
}

extension Json {
    public var isNull: Bool {
        switch self {
        case .JNull:
            return true
        default:
            return false
        }
    }
    
    // key short cut
    public func key(key: String) throws -> Json {
        switch self {
        case let .JObject(object):
            if let value = object[key] {
                return value
            } else {
                throw JsonError.InvalidKey("key(\"\(key)\"), self => \(self)")
            }
        default:
            throw JsonError.InvalidType("key(\"\(key)\"), self => \(self)")
        }
    }
    public func keyOrNil(key: String) -> Json? {
        do {
            return try self.key(key)
        } catch {
            return nil
        }
    }
    
    // to any
    public func take<T: JsonDecodable>() throws -> T {
        return try T.decode(self)
    }
    public func takeOrNil<T: JsonDecodable>() -> T? {
        do {
            let r: T = try self.take()
            return r
        } catch {
            return nil
        }
    }
    
    // to array
    public func take<T: JsonDecodable>() throws -> [T] {
        return try [T].decode(self)
    }
    public func takeOrNil<T: JsonDecodable>() -> [T]? {
        do {
            return try self.take()
        } catch {
            return nil
        }
    }
    
    // to dictionary
    public func take<T: JsonDecodable>() throws -> [String:T] {
        return try [String:T].decode(self)
    }
    public func takeOrNil<T: JsonDecodable>() ->[String:T]? {
        do {
            return try self.take()
        } catch {
            return nil
        }
    }
    
    // key + take
    public func keyedTake<T: JsonDecodable>(key: String) throws -> T {
        return try self.key(key).take()
    }
    public func keyedTake<T: JsonDecodable>(key: String) throws -> [T] {
        return try self.key(key).take()
    }
    public func keyedTake<T: JsonDecodable>(key: String) throws -> [String:T] {
        return try self.key(key).take()
    }
}

extension Json : JsonDecodable {
    public static func decode(json: Json) throws -> Json {
        return json
    }
}

extension Dictionary where Value : JsonDecodable {
    public static func decode(json: Json) throws -> [String:Value] {
        switch json {
        case let .JObject(value):
            var r = [String:Value]()
            for (k, v) in value {
                r[k] = try Value.decode(v)
            }
            return r
        default:
            throw JsonError.InvalidType("Dictionary.decode(), self => \(json)")
        }
    }
}

extension Array where Element : JsonDecodable {
    public static func decode(json: Json) throws -> [Element] {
        switch json {
        case let .JArray(value):
            var r = [Element]()
            r.reserveCapacity(value.count)
            for j in value {
                r.append(try Element.decode(j))
            }
            return r
        default:
            throw JsonError.InvalidType("Array.decode(), self => \(json)")
        }
    }
}

extension Double : JsonDecodable {
    public static func decode(json: Json) throws -> Double {
        switch json {
        case let .JNumber(value):
            return value.doubleValue
        default:
            throw JsonError.InvalidType("Double JsonDecodable, json => \(json)")
        }
    }
}
extension Int : JsonDecodable {
    public static func decode(json: Json) throws -> Int {
        switch json {
        case let .JNumber(value):
            return value.integerValue
        default:
            throw JsonError.InvalidType("Int JsonDecodable, json => \(json)")
        }
    }
}
extension Int64 : JsonDecodable {
    public static func decode(json: Json) throws -> Int64 {
        switch json {
        case let .JNumber(value):
            return value.longLongValue
        default:
            throw JsonError.InvalidType("Int JsonDecodable, json => \(json)")
        }
    }
}

extension String : JsonDecodable {
    public static func decode(json: Json) throws -> String {
        switch json {
        case let .JString(value):
            return value
        default:
            throw JsonError.InvalidType("String JsonDecodable, json => \(json)")
        }
    }
}
extension Bool : JsonDecodable {
    public static func decode(json: Json) throws -> Bool {
        switch json {
        case let .JBoolean(value):
            return value
        default:
            throw JsonError.InvalidType("Bool JsonDecodable, json => \(json)")
        }
    }
}

public protocol JsonEncodable {
    static func encode(value: Self) -> Json
}
extension Json {
    public init<T: JsonEncodable>(_ value: T) {
        self = T.encode(value)
    }
    public init<T: JsonEncodable>(_ value: [String:T]) {
        self = Json.JObject([String:T].encode(value))
    }
    public init<T: JsonEncodable>(_ value: [T]) {
        self = Json.JArray([T].encode(value))
    }
}

extension Json : JsonEncodable {
    public static func encode(value: Json) -> Json {
        return value
    }
}

extension Dictionary where Value : JsonEncodable {
    public static func encode(value: [String:Value]) -> [String:Json] {
        var r = [String:Json](minimumCapacity: value.count)
        for (k, v) in value {
            r[k] = Value.encode(v)
        }
        return r
    }
}

extension Array where Element : JsonEncodable {
    public static func encode(value: [Element]) -> [Json] {
        return value.map { x in Element.encode(x) }
    }
}

extension Double : JsonEncodable {
    public static func encode(value: Double) -> Json {
        return Json.JNumber(value)
    }
}
extension Int : JsonEncodable {
    public static func encode(value: Int) -> Json {
        return Json.JNumber(value)
    }
}
extension Int64 : JsonEncodable {
    public static func encode(value: Int64) -> Json {
        return Json.JNumber(NSNumber(longLong:value))
    }
}
extension String : JsonEncodable {
    public static func encode(value: String) -> Json {
        return Json.JString(value)
    }
}
extension Bool : JsonEncodable {
    public static func encode(value: Bool) -> Json {
        return Json.JBoolean(value)
    }
}

extension Json {
    public var anyObject: AnyObject {
        switch self {
        case let .JObject(dictionary):
            let dic = NSMutableDictionary(capacity: dictionary.count)
            for (key, value) in dictionary {
                dic[key] = value.anyObject
            }
            return dic
        case let .JArray(array):
            return array.map { x in x.anyObject }
        case let .JString(string):
            return string
        case let .JNumber(number):
            return number
        case let .JBoolean(boolean):
            return boolean
        case .JNull:
            return NSNull()
        }
    }
    public var isValidJsonObject: Bool {
        return NSJSONSerialization.isValidJSONObject(self.anyObject)
    }
    public var data: NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(self.anyObject, options: NSJSONWritingOptions(rawValue: 0))
        } catch {
            return nil
        }
    }
    public var string: String {
        return self.data.flatMap { x in NSString(data: x, encoding: NSUTF8StringEncoding) as? String } ?? ""
    }
}
extension Json {
    static func parse(data: NSData) throws -> Json {
        func toJson(anyObject: AnyObject) throws -> Json {
            switch anyObject {
            case let dictionary as NSDictionary:
                var object = [String:Json](minimumCapacity: dictionary.count)
                for (key, value) in dictionary {
                    if let key_s = key as? String {
                        object[key_s] = try toJson(value)
                    }
                }
                return .JObject(object)
            case let array as [NSObject]:
                var jarray = [Json]()
                jarray.reserveCapacity(array.count)
                for value in array {
                    jarray.append(try toJson(value))
                }
                return .JArray(jarray)
            case let string as String:
                return .JString(string)
            case let number as NSNumber:
                if CFNumberGetType(number as CFNumber) == .CharType {
                    return .JBoolean(number.boolValue)
                }
                return .JNumber(number.doubleValue)
            case _ as NSNull:
                return .JNull
            default:
                throw JsonError.ParseFailed
            }
        }
        do {
            return try toJson(NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)))
        } catch {
            throw JsonError.ParseFailed
        }
    }
}

// Curry
public func curry<A, B>(f : A -> B) -> A -> B {
    return f
}

public func curry<A, B, C>(f : (A, B) -> C) -> A -> B -> C {
    return { a in { b in f(a, b) } }
}

public func curry<A, B, C, D>(f : (A, B, C) -> D) -> A -> B -> C -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

public func curry<A, B, C, D, E>(f : (A, B, C, D) -> E) -> A -> B -> C -> D -> E {
    return { a in { b in { c in { d in f(a, b, c, d) } } } }
}

public func curry<A, B, C, D, E, F>(f : (A, B, C, D, E) -> F) -> A -> B -> C -> D -> E -> F {
    return { a in { b in { c in { d in { e in f(a, b, c, d, e) } } } } }
}

public func curry<A, B, C, D, E, F, G>(f : (A, B, C, D, E, F) -> G) -> A -> B -> C -> D -> E -> F -> G {
    return { a in { b in { c in { d in { e in { ff in f(a, b, c, d, e, ff) } } } } } }
}

public func curry<A, B, C, D, E, F, G, H>(f : (A, B, C, D, E, F, G) -> H) -> A -> B -> C -> D -> E -> F -> G -> H {
    return { a in { b in { c in { d in { e in { ff in { g in f(a, b, c, d, e, ff, g) } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I>(f : (A, B, C, D, E, F, G, H) -> I) -> A -> B -> C -> D -> E -> F -> G -> H -> I {
    return { a in { b in { c in { d in { e in { ff in { g in { h in f(a, b, c, d, e, ff, g, h) } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J>(f : (A, B, C, D, E, F, G, H, I) -> J) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in f(a, b, c, d, e, ff, g, h, i) } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K>(f : (A, B, C, D, E, F, G, H, I, J) -> K) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in f(a, b, c, d, e, ff, g, h, i, j) } } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K, L>(f : (A, B, C, D, E, F, G, H, I, J, K) -> L) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K -> L {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in { k in f(a, b, c, d, e, ff, g, h, i, j, k) } } } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K, L, M>(f : (A, B, C, D, E, F, G, H, I, J, K, L) -> M) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K -> L -> M {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in { k in { l in f(a, b, c, d, e, ff, g, h, i, j, k, l) } } } } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(f : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> N) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K -> L -> M -> N {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in { k in { l in { m in f(a, b, c, d, e, ff, g, h, i, j, k, l, m) } } } } } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(f : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> O) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K -> L -> M -> N -> O {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in { k in { l in { m in { n in f(a, b, c, d, e, ff, g, h, i, j, k, l, m, n) } } } } } } } } } } } } } }
}

public func curry<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(f : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> P) -> A -> B -> C -> D -> E -> F -> G -> H -> I -> J -> K -> L -> M -> N -> O -> P {
    return { a in { b in { c in { d in { e in { ff in { g in { h in { i in { j in { k in { l in { m in { n in { o in f(a, b, c, d, e, ff, g, h, i, j, k, l, m, n, o) } } } } } } } } } } } } } } }
}

// Applicative
infix operator <*> { associativity left }

func <*><T, U>(lhs: (T -> U), rhs: T) -> U {
    return lhs(rhs)
}

