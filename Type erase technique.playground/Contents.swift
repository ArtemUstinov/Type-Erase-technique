import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*
 Type erase technique with using 'Decorator pattern'
 */

// Liquid interface
public protocol LiquidInterface {
    var temperature: Float { get set }
    var viscosity: Float { get }
    var color: String { get }
}

// Liquid implementation
struct Coffee: LiquidInterface {
    var temperature: Float
    var viscosity: Float = 3.4
    var color: String = "Black"
}

//Cup interface
public protocol CupInterface: class {
    associatedtype LiquidType: LiquidInterface
    var liquid: LiquidType? { get }
    func fill(with liquid: LiquidType)
}

// Cup implementation
final class CeramicCup<L: LiquidInterface>: CupInterface {
    typealias LiquidType = L
    
    var liquid: L?
    
    func fill(with liquid: L) {
        self.liquid = liquid
        self.liquid?.temperature -= 1
    }
}

final class PlasticCup<L: LiquidInterface>: CupInterface {
    typealias LiquidType = L
    
    var liquid: L?
    
    func fill(with liquid: L) {
        self.liquid = liquid
        self.liquid?.temperature -= 10
    }
}

// We are creating 'Abstract' cup's implementation
class AbstractCup<L: LiquidInterface>: CupInterface {
    typealias LiquidType = L
    var liquid: L? {
        fatalError("Must implement")
    }
    func fill(with liquid: L) {
        fatalError("Must implement")
    }
}

final class CupWrapper<C: CupInterface>: AbstractCup<C.LiquidType> {
    
    private let cup: C
    
    override var liquid: C.LiquidType? { return self.cup.liquid }
    
    public init(with cup: C) {
        self.cup = cup
    }
    
    override func fill(with liquid: C.LiquidType) {
        self.cup.fill(with: liquid)
    }
    
}

// Current example
// var cupsOfCoffee = [CupInterface]() // This is line doesn't compile by reason of 'Opaque Type'
var cupsOfCoffee = [AbstractCup<Coffee>]()
cupsOfCoffee.append(CupWrapper(with: CeramicCup<Coffee>()))
cupsOfCoffee.append(CupWrapper(with: PlasticCup<Coffee>()))

// Create another 'Wrapper' over the existing 'Wrapper
final public class AnyCup<L: LiquidInterface>: CupInterface {
    public typealias LiquidType = L
    
    public var liquid: L? {
        self.abstractCup.liquid
    }
    
    private let abstractCup: AbstractCup<L>
    
    public init<C: CupInterface>(with cup: C) where C.LiquidType == L {
        self.abstractCup = CupWrapper(with: cup)
    }
    
    public func fill(with liquid: L) {
        self.abstractCup.fill(with: liquid)
    }
    
}

// Final example
var coffeeCups = [AnyCup<Coffee>]()
coffeeCups.append(AnyCup<Coffee>(with: CeramicCup<Coffee>()))
coffeeCups.append(AnyCup<Coffee>(with: PlasticCup<Coffee>()))
