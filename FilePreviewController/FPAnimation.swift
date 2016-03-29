//
//  FPAnimation.swift
//  FilePreviewController
//
//  Created by WangWei on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

let PresentDuration = 0.3
let DismissDuration = 0.2
var AssociatedObjectHandle: UInt8 = 0

public extension UIViewController {
    public func showFilePreviewController(filePreviewController: UIViewController, fromView: UIView?) {
        if let fromView = fromView {
            let transitionDelegate = TransitionDelegate(fromView: fromView)
            filePreviewController.transitioningDelegate = transitionDelegate
            filePreviewController.transitionDelegate = transitionDelegate
        }
        presentViewController(filePreviewController, animated: true, completion: nil)
    }
    
    public func dismissViewController() {
        if let viewController = presentedViewController {
            viewController.transitioningDelegate = viewController.transitionDelegate
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    internal var transitionDelegate: TransitionDelegate {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var fromView: UIView?

    init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromView = fromView {
            return PresentAnimation(fromView: fromView)
        }
        return nil
    }

    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromView = fromView {
            return DismissAnimation(toView: fromView)
        }
        return nil
    }
}

public class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var fromView: UIView!
    public init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return PresentDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        container.addSubview(toVC.view)
        let fromFrame = fromView.frame
        let toFrame = transitionContext.finalFrameForViewController(toVC)
 
        let scale = CGAffineTransformMakeScale(fromFrame.width/toFrame.width, fromFrame.height/toFrame.height)
        let translation = CGAffineTransformMakeTranslation(fromFrame.midX - toFrame.midX, fromFrame.midY - toFrame.midY)
        toVC.view.transform = CGAffineTransformConcat(scale, translation)

        UIView.animateWithDuration(PresentDuration, animations: {
            toVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

public class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var toView: UIView!
    public init(toView: UIView) {
        super.init()
        self.toView = toView
    }

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DismissDuration
    }

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        container.addSubview(toVC.view)
        container.addSubview(fromVC.view)
        let toFrame = container.convertRect(toView.frame, fromView: toView.superview)
        let fromFrame = transitionContext.finalFrameForViewController(fromVC)

        let scale = CGAffineTransformMakeScale(toFrame.width/fromFrame.width, toFrame.height/fromFrame.height)
        let translation = CGAffineTransformMakeTranslation(toFrame.midX - fromFrame.midX, toFrame.midY - fromFrame.midY)

        UIView.animateWithDuration(DismissDuration, animations: {
            fromVC.view.transform = CGAffineTransformConcat(scale, translation)
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}










