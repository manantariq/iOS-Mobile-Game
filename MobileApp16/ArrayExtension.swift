//
//  ArrayExtension.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 10/11/16.
//
//

import Foundation

extension Array where Element : Equatable {
    public var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
