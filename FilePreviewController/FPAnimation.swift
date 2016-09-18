//
//  FPAnimation.swift
//  FilePreviewController
//
//  Created by WangWei on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

let PresentDuration = 0.4
let DismissDuration = 0.3
var AssociatedObjectHandle: UInt8 = 0

public extension UIViewController {
    public func presentFilePreviewController(viewControllerToPresent controller: UIViewController, fromView: UIView?) {
        if let fromView = fromView {
            let transitionDelegate = TransitionDelegate(fromView: fromView)
            controller.transitioningDelegate = transitionDelegate
            controller.fp_transitionDelegate = transitionDelegate
        }
        present(controller, animated: true, completion: nil)
    }
    
    public func dismissFilePreviewController() {
        if let viewController = presentedViewController {
            viewController.transitioningDelegate = viewController.fp_transitionDelegate
        }
        dismiss(animated: true, completion: nil)
    }

    internal var fp_transitionDelegate: TransitionDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    open var fromView: UIView?

    init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromView = fromView {
            return PresentAnimation(fromView: fromView)
        }
        return nil
    }

    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromView = fromView {
            return DismissAnimation(toView: fromView)
        }
        return nil
    }
}

open class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var fromView: UIView!
    public init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PresentDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        container.addSubview(toVC.view)
        let fromFrame = container.convert(fromView.frame, from: fromView.superview)
        let toFrame = transitionContext.finalFrame(for: toVC)
 
        let scale = CGAffineTransform(scaleX: fromFrame.width/toFrame.width, y: fromFrame.height/toFrame.height)
        let translation = CGAffineTransform(translationX: fromFrame.midX - toFrame.midX, y: fromFrame.midY - toFrame.midY)
        toVC.view.transform = scale.concatenating(translation)
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: PresentDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            toVC.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toVC.view.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

open class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var toView: UIView!
    public init(toView: UIView) {
        super.init()
        self.toView = toView
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DismissDuration
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        container.addSubview(toVC.view)
        container.addSubview(fromVC.view)
        let toFrame = container.convert(toView.frame, from: toView.superview)
        let fromFrame = transitionContext.finalFrame(for: fromVC)

        let scale = CGAffineTransform(scaleX: toFrame.width/fromFrame.width, y: toFrame.height/fromFrame.height)
        let translation = CGAffineTransform(translationX: toFrame.midX - fromFrame.midX, y: toFrame.midY - fromFrame.midY)
        UIView.animate(withDuration: DismissDuration, delay: 0, options: .curveEaseOut, animations: {
            fromVC.view.alpha = 0
            fromVC.view.transform = scale.concatenating(translation)
            }) { (_) in
                fromVC.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
