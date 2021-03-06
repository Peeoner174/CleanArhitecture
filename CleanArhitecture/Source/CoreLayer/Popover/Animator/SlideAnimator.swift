//
//  SlideAnimator.swift
//  CleanArhitecture
//
//  Created by MSI on 06/09/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation
import UIKit

final class SlideAnimator: NSObject {
    private let transitionType: TransitionType
    private let presentation: SlidePresentation
    private var currentPropertyAnimator: UIViewPropertyAnimator?
    
    init(transitionType: TransitionType, presentation: SlidePresentation) {
        self.transitionType = transitionType
        self.presentation = presentation
        super.init()
    }
}

extension SlideAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentation.presentationTiming.duration.timeInterval
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let viewControllerKey: UITransitionContextViewControllerKey = transitionType == .dismissal ? .from : .to
        let viewControllerToAnimate = transitionContext.viewController(forKey: viewControllerKey)!
        
        let viewToAnimate = viewControllerToAnimate.view!
        viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
        
        let offsetFrame = presentation.showDirection.offsetFrameForView(view: viewToAnimate, containerView: transitionContext.containerView)
        
        if transitionType == .presentation {
            transitionContext.containerView.addSubview(viewToAnimate)
            viewToAnimate.frame = offsetFrame
        }
        
        let propertyAnimator = UIViewPropertyAnimator(
            duration: presentation.presentationTiming.duration.timeInterval,
            curve: presentation.presentationTiming.presentationCurve
        )
        
        propertyAnimator.addAnimations { [weak self] in
            guard let `self` = self else { return }
            
            if self.transitionType == .dismissal {
                viewToAnimate.frame = offsetFrame
            } else {
                viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
            }
        }
        
        propertyAnimator.addCompletion { animatedPosition in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        self.currentPropertyAnimator = propertyAnimator
        propertyAnimator.startAnimation()
    }
}


