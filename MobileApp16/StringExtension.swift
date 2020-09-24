//
//  StringExtension.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 04/11/16.
//
//

import Foundation

extension String {
    /// Returns a String with the character at the specified index
    subscript (charAt: Int) -> String {
        get {
            assert(charAt >= 0 && charAt < self.lengthOfBytes(using: .ascii), "Index out of bound")
            return self.substring(with: self.index(self.startIndex, offsetBy: charAt) ..< self.index(self.startIndex, offsetBy: charAt+1))
        }
    }
    
    
    /// Returns the substring included between the specified indexes (from: included, to: excluded)
    subscript (from: Int, to: Int) -> String {
        assert(from >= 0 && from <= to && to <= self.lengthOfBytes(using: .ascii), "Index out of bound")
        return self.substring(with: self.index(self.startIndex, offsetBy: from) ..< self.index(self.startIndex, offsetBy: to))
    }
}
