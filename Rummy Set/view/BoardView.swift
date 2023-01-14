//
//  BoardView.swift
//  Rummy Set
//
//  Created by Mohammad Kiani on 2021-09-12.
//

import UIKit

class BoardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
        
    var playingCardViews = [PlayingCardView]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSetCards()
    }
    
    private func layoutSetCards() {
        var grid = Grid(layout: .aspectRatio(Constant.cellAspectRatio), frame: bounds)
        grid.cellCount = playingCardViews.count
        var delay = 0.2
        for index in 0..<grid.cellCount {
            if let frame = grid[index] {
                let cellPadding = Constant.cellPaddingToBoundsWidth * frame.width
                let cardFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width - cellPadding, height: frame.height - cellPadding)
                let cardView = playingCardViews[index]
                switch cardView.animationState {
                case .flyingIn, .noAnimation:
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: delay, options: [.curveEaseInOut, .beginFromCurrentState]) {
                        cardView.frame = cardFrame
                        cardView.layoutIfNeeded()
                    }
                    completion: { _ in
                        if cardView.animationState == .flyingIn {
                        
                            UIView.transition(with: cardView, duration: 1, options: [.beginFromCurrentState, .transitionFlipFromLeft, .curveEaseInOut]) {
                                cardView.isFaceUp = true
                            } completion: { _ in
                                UIView.transition(with: cardView, duration: 5, options: .transitionFlipFromRight) {
                                    cardView.isFaceUp = false
                                } completion: { _ in
                                    cardView.animationState = .noAnimation
                                }
                            }
                        }
                    }
//                case .flyingOut:
//                    cardView.animationState = .discarded
//                    cardV
                default:
                    break
                }
                delay += 0.15
            }
        }
    }
}

extension BoardView {
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let cellPaddingToBoundsWidth: CGFloat  = 1/20
    }
}
