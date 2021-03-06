//
//  CustomPresentationManager.swift
//  CleanArhitecture
//
//  Created by MSI on 05/09/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import UIKit

@objc
protocol PopoverPresentationDelegate: UIViewControllerTransitioningDelegate {
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect
    @objc optional func didDismiss()
}

typealias Presentation = PresentationUIConfigurationProvider & PresentationAnimatorProvider

final class PopoverPresentationDelegateImpl: NSObject {
    private var presentation: Presentation

    private var dismissCompletion: EmptyCompletion

    var presentInteractionController: UIPercentDrivenInteractiveTransition?
    var dismissInteractionController: UIPercentDrivenInteractiveTransition?
    weak var presentationController: PopoverPresentationControllerProtocol!
    private weak var presentedViewController: UIViewController!
    
    init(presentation: Presentation,
         dismissCompletion: EmptyCompletion = nil) {
        self.presentation = presentation
        self.dismissCompletion = dismissCompletion
        super.init()
    }
    
    func prepare(presentedViewController: UIViewController) {
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
        self.presentedViewController = presentedViewController
    }
}

extension PopoverPresentationDelegateImpl: PopoverPresentationDelegate {
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        if let expandableFrameProvider = presentation as? PresentationExpandableFrameProvider {
            return (try? expandableFrameProvider.frameOfExpandablePresentedViewClosure?(containerViewFrame, expandableFrameProvider.expandablePopoverFrameMeta.currentExpandStep)) ?? containerViewFrame
        } else if let frameProvider = presentation as? PresentationFrameProvider {
            return (try? frameProvider.frameOfPresentedViewClosure?(containerViewFrame)) ?? containerViewFrame
        } else {
            return containerViewFrame
        }
    }
    
    func didDismiss() {
        dismissCompletion?()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentation.showAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentation.dismissAnimator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentInteractionController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractionController
    }
}
