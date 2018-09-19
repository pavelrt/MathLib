//
//  hashUtils.swift
//  MathLib
//
//  Created by Pavel Rytir on 6/30/18.
//


#if swift(>=4.2)
// Use hasher.combine
#else
extension Hashable {
    public func combineHashValue(with otherHash: Int) -> Int {
        let ownHash = self.hashValue
        return (ownHash << 5) &+ ownHash &+ otherHash
    }
}
#endif

#if swift(>=4.2)
// Array is hashable in swift 4.2
#else
extension Array : Hashable where Element : Hashable {
    public var hashValue: Int {
        var hash = 1.hashValue
        for e in self {
            hash = e.combineHashValue(with: hash)
        }
        return hash
    }
}
#endif

#if swift(>=4.2)
#else
extension Dictionary: Hashable where Value : Hashable {
    public var hashValue: Int {
        var hash = 0
        for (key, value) in self {
            hash = key.combineHashValue(with: hash)
            hash = value.combineHashValue(with: hash)
        }
        return hash
    }
}
#endif
