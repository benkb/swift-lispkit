//
//  Procedure.swift
//  LispKit
//
//  Created by Matthias Zenger on 21/01/2016.
//  Copyright © 2016 ObjectHub. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

///
/// Procedures encapsulate functions that can be applied to arguments. Procedures have an
/// identity, a name, and a definition in the form of property `kind`. There are four kinds
/// of procedure definitions:
///    1. Primitives: Built-in procedures
///    2. Closures: User-defined procedures, e.g. via `lambda`
///    3. Continuations: Continuations generated by `call-with-current-continuation`
///    4. Parameters: Parameter objects, which can be mutated for the duration of a
///       dynamic extent
///    5. Transformers: User-defined macro transformers defined via `syntax-rules`
///
public final class Procedure: Reference, CustomStringConvertible {
  
  /// There are four kinds of procedures:
  ///    1. Primitives: Built-in procedures
  ///    2. Closures: User-defined procedures, e.g. via `lambda`
  ///    3. Continuations: Continuations generated by `call-with-current-continuation`
  ///    4. Parameters: Parameter objects, which can be mutated for the duration of a
  ///       dynamic extent
  ///    5. Transformers: User-defined macro transformers defined via `syntax-rules`
  public enum Kind {
    case primitive(String, Implementation, FormCompiler?)
    case closure(String?, [Expr], Code)
    case continuation(VirtualMachineState)
    case parameter(Tuple)
    case transformer(SyntaxRules)
  }
  
  /// There are three different types of primitive implementations:
  ///    1. Evaluators: They turn the arguments into code that the VM executes
  ///    2. Applicators: They map the arguments to a continuation procedure and an argument list
  ///    3. Native implementations: They map the arguments into a result value
  public enum Implementation {
    case eval((Arguments) throws -> Code)
    case apply((Arguments) throws -> (Procedure, [Expr]))
    case native0(() throws -> Expr)
    case native1((Expr) throws -> Expr)
    case native2((Expr, Expr) throws -> Expr)
    case native3((Expr, Expr, Expr) throws -> Expr)
    case native4((Expr, Expr, Expr, Expr) throws -> Expr)
    case native0O((Expr?) throws -> Expr)
    case native1O((Expr, Expr?) throws -> Expr)
    case native2O((Expr, Expr, Expr?) throws -> Expr)
    case native3O((Expr, Expr, Expr, Expr?) throws -> Expr)
    case native1OO((Expr, Expr?, Expr?) throws -> Expr)
    case native2OO((Expr, Expr, Expr?, Expr?) throws -> Expr)
    case native3OO((Expr, Expr, Expr, Expr?, Expr?) throws -> Expr)
    case native0R((Arguments) throws -> Expr)
    case native1R((Expr, Arguments) throws -> Expr)
    case native2R((Expr, Expr, Arguments) throws -> Expr)
    case native3R((Expr, Expr, Expr, Arguments) throws -> Expr)
  }
  
  /// Procedure kind
  public let kind: Kind
  
  /// Initializer for primitive evaluators
  public init(_ name: String,
              _ proc: @escaping (Arguments) throws -> Code,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .eval(proc), compiler)
  }
  
  /// Initializer for primitive evaluators
  public init(_ name: String,
              _ compiler: @escaping FormCompiler,
              in context: Context) {
    func indirect(_ args: Arguments) throws -> Code {
      let expr =
        Expr.pair(.symbol(Symbol(context.symbols.intern(name), .system)), .makeList(args))
      return try Compiler.compile(context,
                                  expr: .pair(expr, .null),
                                  in: .system,
                                  optimize: false)
    }
    self.kind = .primitive(name, .eval(indirect), compiler)
  }
  
  /// Initializer for primitive applicators
  public init(_ name: String,
              _ proc: @escaping (Arguments) throws -> (Procedure, [Expr]),
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .apply(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping () throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native0(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native1(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native2(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native3(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr, Expr) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native4(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native0O(proc), compiler)
  }

  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native1O(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native2O(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native3O(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr?, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native1OO(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr?, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native2OO(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr, Expr?, Expr?) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native3OO(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Arguments) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native0R(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Arguments) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native1R(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Arguments) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native2R(proc), compiler)
  }
  
  /// Initializer for primitive procedures
  public init(_ name: String,
              _ proc: @escaping (Expr, Expr, Expr, Arguments) throws -> Expr,
              _ compiler: FormCompiler? = nil) {
    self.kind = .primitive(name, .native3R(proc), compiler)
  }
  
  /// Initializer for closures
  public init(_ name: String?, _ captured: [Expr], _ code: Code) {
    self.kind = .closure(name, captured, code)
  }
  
  /// Initializer for closures
  public init(_ code: Code) {
    self.kind = .closure(nil, [], code)
  }
  
  /// Initializer for parameters
  public init(_ setter: Expr, _ initial: Expr) {
    self.kind = .parameter(Tuple(setter, initial))
  }
  
  /// Initializer for continuations
  public init(_ vmState: VirtualMachineState) {
    self.kind = .continuation(vmState)
  }
  
  /// Initializer for transformers
  public init(_ rules: SyntaxRules) {
    self.kind = .transformer(rules)
  }
  
  /// Returns the name of this procedure. This method either returns the name of a primitive
  /// procedure or the identity as a hex string.
  public var name: String {
    switch self.kind {
      case .primitive(let str, _, _):
        return str
      case .closure(.some(let str), _, _):
        return "\(str)@\(self.identityString)"
      default:
        return self.identityString
    }
  }
  
  public func mark(_ tag: UInt8) {
    switch self.kind {
      case .closure(_, let captures, let code):
        for capture in captures {
          capture.mark(tag)
        }
        code.mark(tag)
      default:
        break
    }
  }
  
  /// A textual description
  public var description: String {
    return "proc:" + self.name
  }
}

public typealias Arguments = ArraySlice<Expr>

public extension ArraySlice {
    
  public func optional(_ fst: Element, _ snd: Element) -> (Element, Element)? {
    switch self.count {
      case 0:
        return (fst, snd)
      case 1:
        return (self[self.startIndex], snd)
      case 2:
        return (self[self.startIndex], self[self.startIndex + 1])
      default:
        return nil
    }
  }
  
  public func optional(_ fst: Element,
                       _ snd: Element,
                       _ trd: Element) -> (Element, Element, Element)? {
    switch self.count {
      case 0:
        return (fst, snd, trd)
      case 1:
        return (self[self.startIndex], snd, trd)
      case 2:
        return (self[self.startIndex], self[self.startIndex + 1], trd)
      case 3:
        return (self[self.startIndex], self[self.startIndex + 1], self[self.startIndex + 2])
      default:
        return nil
    }
  }
}

///
/// A `FormCompiler` is a function that compiles an expression for a given compiler in a
/// given environment and tail position returning a boolean which indicates whether the
/// expression has resulted in a tail call.
///
public typealias FormCompiler = (Compiler, Expr, Env, Bool) throws -> Bool
