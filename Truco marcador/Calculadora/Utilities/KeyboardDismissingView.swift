//
//  KeyboardDismissingView.swift
//  CampusSelvagem
//
//  Created by Joao Flores on 21/08/19.
//  Copyright © 2019 Felipe Semissatto. All rights reserved.
//

import Foundation
import UIKit

@objc public class KeyboardDismissingView: UIView {
    
    public var dismissingBlock: (() -> Void)?
    public var touchEndedBlock: (() -> Void)?
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let isDismissing = KeyboardDismissingView.resignAnyFirstResponder(self)
        
        if isDismissing {
            self.dismissingBlock?()
        }
        self.touchEndedBlock?()
    }
    
    @discardableResult public class func resignAnyFirstResponder(_ view: UIView) -> Bool {
        var hasResigned = false
        for subView in view.subviews {
            if subView.isFirstResponder {
                subView.resignFirstResponder()
                hasResigned = true
                if let searchBar = subView as? UISearchBar {
                    searchBar.setShowsCancelButton(false, animated: true)
                }
            }
            else {
                hasResigned = KeyboardDismissingView.resignAnyFirstResponder(subView) || hasResigned
            }
        }
        return hasResigned
    }
}
