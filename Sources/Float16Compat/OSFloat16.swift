import CFloat16Shim

#if (os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)

/// Drop-in replacement for the standard library's `Float16` on x86_64 macOS,
/// where that type is marked `@available(macOS, unavailable)`.
///
/// Layout is guaranteed identical to IEEE-754 binary16 (2 bytes, alignment 2),
/// so pointers obtained from `MLMultiArray.dataPointer` for `.float16` arrays
/// can be bound to this type exactly as they would be to `Float16`.
///
/// Conversions delegate to clang's `_Float16` (see CFloat16Shim.h) and are
/// therefore bit-exact with the arm64 behaviour, including round-to-nearest-even.
@frozen
public struct OSFloat16 {
    public var bitPattern: UInt16

    @inlinable public init(bitPattern: UInt16) { self.bitPattern = bitPattern }
    @inlinable public init(_ value: Float)  { self.bitPattern = cf16_from_float(value) }
    @inlinable public init(_ value: Double) { self.bitPattern = cf16_from_float(Float(value)) }
    @inlinable public init(_ value: Int)    { self.bitPattern = cf16_from_float(Float(value)) }

    @inlinable public var floatValue: Float { cf16_to_float(bitPattern) }
}

extension OSFloat16: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral value: Int) { self.init(value) }
}

extension OSFloat16: ExpressibleByFloatLiteral {
    @inlinable public init(floatLiteral value: Double) { self.init(value) }
}

extension OSFloat16: Equatable {
    // Compares numerically (not bitwise): -0 == +0, and NaN != NaN.
    @inlinable public static func == (a: OSFloat16, b: OSFloat16) -> Bool {
        a.floatValue == b.floatValue
    }
}

extension OSFloat16: Comparable {
    @inlinable public static func < (a: OSFloat16, b: OSFloat16) -> Bool {
        a.floatValue < b.floatValue
    }
}

extension OSFloat16: CustomStringConvertible {
    public var description: String { floatValue.description }
}

extension Float {
    @inlinable public init(_ value: OSFloat16) { self = value.floatValue }
}

extension Double {
    @inlinable public init(_ value: OSFloat16) { self = Double(value.floatValue) }
}

#else

/// On arm64 the standard library type is available and used verbatim.
public typealias OSFloat16 = Float16

#endif
