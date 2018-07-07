//
//  hashUtils.swift
//  MathLib
//
//  Created by Pavel Rytir on 6/30/18.
//


#if swift(>=4.2)
#else
extension Hashable {
    public func combineHashValue(with otherHash: Int) -> Int {
        let ownHash = self.hashValue
        return (ownHash << 5) &+ ownHash &+ otherHash
    }
}
#endif

