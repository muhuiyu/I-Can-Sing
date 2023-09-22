//
//  UITextView+Extensions.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/22/23.
//

import UIKit

extension UITextView {
    func convertToNSRange(from range: UITextRange) -> NSRange {
        let location = self.offset(from: self.beginningOfDocument, to: range.start)
        let length = self.offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
