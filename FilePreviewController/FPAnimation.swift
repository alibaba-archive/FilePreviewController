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
    func presentFilePreviewController(viewControllerToPresent controller: UIViewController, fromView: UIView?) {
        let transitionDelegate = TransitionDelegate(fromView: fromView)
        controller.transitioningDelegate = transitionDelegate
        controller.fp_transitionDelegate = transitionDelegate
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    func dismissFilePreviewController() {
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

    init(fromView: UIView?) {
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
    var fromView: UIView?
    public init(fromView: UIView?) {
        super.init()
        self.fromView = fromView
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PresentDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        if let fromView = fromView {
            container.addSubview(toViewController.view)
            let fromFrame = container.convert(fromView.frame, from: fromView.superview)
            let toFrame = transitionContext.finalFrame(for: toViewController)
            
            let scale = CGAffineTransform(scaleX: fromFrame.width/toFrame.width, y: fromFrame.height/toFrame.height)
            let translation = CGAffineTransform(translationX: fromFrame.midX - toFrame.midX, y: fromFrame.midY - toFrame.midY)
            toViewController.view.transform = scale.concatenating(translation)
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: PresentDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
                toViewController.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                toViewController.view.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            var frame = fromViewController.view.frame
            frame.origin.y = frame.size.height
            toViewController.view.frame = frame
            container.addSubview(toViewController.view)
            UIView.animate(withDuration: PresentDuration, delay: 0, options: .curveEaseIn, animations: {
                toViewController.view.frame = fromViewController.view.frame
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

open class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var toView: UIView?
    public init(toView: UIView?) {
        super.init()
        self.toView = toView
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DismissDuration
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
                return
        }
        
        func willDismiss() {
            if let navigationViewController = fromViewController as? UINavigationController,
                let filePreviewController = navigationViewController.viewControllers.last as? FilePreviewController {
                filePreviewController.willDismiss()
            } else {
                (fromViewController as? FilePreviewController)?.willDismiss()
            }
        }
        
        if let toView = toView {
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            if #available(iOS 13.0, *), toViewController.presentingViewController != nil {
                let toVCSuperView = toViewController.view.superview
                let destinationView: UIView! = transitionContext.view(forKey: .to) ?? toViewController.view
                toVCSuperView?.addSubview(destinationView)
            } else {
                container.addSubview(toViewController.view)
            }
            container.addSubview(fromViewController.view)
            let toFrame = container.convert(toView.frame, from: toView.superview)
            let fromFrame = transitionContext.finalFrame(for: fromViewController)
            
            let scale = CGAffineTransform(scaleX: toFrame.width/fromFrame.width, y: toFrame.height/fromFrame.height)
            let translation = CGAffineTransform(translationX: toFrame.midX - fromFrame.midX, y: toFrame.midY - fromFrame.midY)
            UIView.animate(withDuration: DismissDuration, delay: 0, options: .curveEaseOut, animations: {
                fromViewController.view.alpha = 0
                fromViewController.view.transform = scale.concatenating(translation)
            }) { (_) in
                willDismiss()
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            var frame = fromViewController.view.frame
            frame.origin.y = frame.size.height
            UIView.animate(withDuration: DismissDuration, delay: 0, options: .curveEaseIn, animations: {
                fromViewController.view.frame = frame
            }) { (_) in
                willDismiss()
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
