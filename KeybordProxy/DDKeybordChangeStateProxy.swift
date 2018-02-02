//
//  DDKeybordChangeStateProxy.swift
//  DaDaClass
//
//  Created by Kai on 25/01/2018.
//  Copyright © 2018 dadaabc. All rights reserved.
//

import UIKit

@objc
class DDKeyboardChangeStateProxy: NSObject {
    @objc
    public static let sharedInstance = DDKeyboardChangeStateProxy()
    private override init() {}
    
    /// 键盘不能遮盖的最底部视图。如果为空，默认以输入框为参考。
    /// 每次键盘收起后，清空此属性。
    weak var baseLineView: UIView?

    private let spaceToFirstResponder: CGFloat = 5
    
    // MARK:- Public
    @objc
    public func beginObserveKeyboardWillChangeFrame() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil
        )
    }
    
    @objc
    public func endObserveKeyboardWillChangeFrame() {
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil
        )
    }

    // MARK:- Notification callback

    @objc
    func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let spotViewController = visibleViewController() else { return }
        guard let spotView = spotViewController.view else { return }
        guard let firstResponder = spotView.findOutFirstResponder() else { return }
        guard firstResponder.isFollowKeyboard else { return }
        guard let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }

        let baseLineView = self.baseLineView ?? firstResponder
        let bounds = baseLineView.bounds
        let frameInWindow = baseLineView.convert(bounds, to: UIApplication.shared.keyWindow)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        
        let keyboardWillShow = keyboardFrameEnd.origin.y < UIScreen.main.bounds.height
        let baseLine: CGFloat = frameInWindow.origin.y + frameInWindow.size.height + spaceToFirstResponder
        let keyboardTopEnd = keyboardFrameEnd.origin.y
        
        if keyboardWillShow {
            // Keyboard covers first responder
            guard baseLine > keyboardTopEnd else { return }
            let translationY = keyboardTopEnd - baseLine
            
            var targetTransform = spotView.transform
            targetTransform.ty += translationY
            let animations = { spotView.transform = targetTransform }
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            let animations = { spotView.transform = CGAffineTransform.identity }
            UIView.animate(withDuration: duration, animations: animations)
            self.baseLineView = nil
        }
    }
    
    // MARK:- Private
    private func visibleViewController() -> UIViewController! {
        return UIApplication.shared.keyWindow?.visibleViewController
    }
    
}

extension UIView {
    func findOutFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        
        for subview in self.subviews {
            guard let firstResponder = subview.findOutFirstResponder()
                else { continue }
            return firstResponder
        }
        return nil
    }
}

private var isFollowKeyboardKey: Void?
extension UIView {
    var isFollowKeyboard: Bool {
        get {
            // Default is true
            let anyOptional = objc_getAssociatedObject(self, &isFollowKeyboardKey)
            guard let isFollowKeyboard = anyOptional as? Bool else { return true }
            return isFollowKeyboard
        }
        set {
            objc_setAssociatedObject(self, &isFollowKeyboardKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
