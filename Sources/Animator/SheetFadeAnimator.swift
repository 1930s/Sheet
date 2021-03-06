//
//  SheetFadeAnimator.swift
//  Sheeeeeeeeet
//
//  Created by Gwangbeom on 2018. 9. 26..
//  Copyright © 2018년 GwangBeom. All rights reserved.
//

import UIKit

class SheetFadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPush: Bool = true
    var onReady: (() -> Void)?
    var onComplete: (() -> Void)?
    
    private var options: SheetOptions {
        return SheetManager.shared.options
    }
    
    private var animationOption: SheetAnimationOption {
        return SheetManager.shared.animationOption
    }
    
    private var toTopMargin: CGFloat = 0
    private var fromTopMargin: CGFloat = 0

    init(to: CGFloat, from: CGFloat) {
        super.init()
        toTopMargin = to
        fromTopMargin = from
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationOption.pushAnimationItem.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from) as? SheetContentsViewController
        let toViewController = transitionContext.viewController(forKey: .to) as? SheetContentsViewController

        let fromContainer = fromViewController?.collectionView
        let toContainer = toViewController?.collectionView
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = SheetManager.shared.options.sheetBackgroundColor
        
        backgroundView.layer.cornerRadius = options.cornerRadius
        backgroundView.frame = CGRect(x: 0, y: fromTopMargin, width: containerView.bounds.width, height: containerView.bounds.height)
        containerView.insertSubview(backgroundView, at: 0)
        
        let toView = transitionContext.view(forKey: .to) ?? UIView()
        toView.alpha = 0
        containerView.addSubview(toView)

        let diff = fromTopMargin - toTopMargin

        let toLayoutTopMargin = (toContainer?.collectionViewLayout as? SheetContentsLayout)?.settings.topMargin ?? 0
        toContainer?.contentOffset.y = isPush ? -diff : toLayoutTopMargin - fromTopMargin
        
        onReady?()
        
        UIView.animate(withDuration: animationOption.pushAnimationItem.duration, delay: 0, usingSpringWithDamping: animationOption.pushAnimationItem.springDumping, initialSpringVelocity: animationOption.pushAnimationItem.initialSpringVelocity, options: animationOption.pushAnimationItem.options, animations: {
            fromContainer?.alpha = 0
            fromContainer?.contentOffset.y += diff
            
            backgroundView.frame = CGRect(x: 0, y: self.toTopMargin, width: containerView.bounds.width, height: containerView.bounds.height)

            toView.alpha = 1
            toContainer?.contentOffset.y = self.isPush ? 0 : toLayoutTopMargin - self.toTopMargin
        }) { _ in
            self.onComplete?()
            backgroundView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
