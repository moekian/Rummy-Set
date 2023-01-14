//
//  ViewController.swift
//  Rummy Set
//
//  Created by Mohammad Kiani on 2021-09-12.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    var timer: Timer?
    var seconds = 0
    var tapTime = 0
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    var discardedCardViews = [PlayingCardView]()
    var discardedCards = [PlayingCard]()
    
    var selectedCardViews = [PlayingCardView]()
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var boardView: BoardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCard))
            swipe.direction = .up
            boardView.addGestureRecognizer(swipe)
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(dealMoreCard), userInfo: nil, repeats: false)
        }
    }
    
    @objc func dealMoreCard() {
        
        let _ = discardedCardViews.map {boardView.playingCardViews.remove(object: $0)}
        deal(numberOfCards: 30)
    }
    
    @IBAction func dealCard(_ sender: UITapGestureRecognizer) {
//        boardView.setNeedsDisplay()
        updateViewFromModel()
    }
    
    func updateViewFromModel() {
        deal(numberOfCards: 30)
    }
    
    @objc func runTimer() {
        seconds += 1
        if seconds > tapTime + 5 {
            findResultAndFlipOrDiscardCards()
        }
    }
    
    private func findResultAndFlipOrDiscardCards(including cardView: PlayingCardView? = nil) {
        if Brain.calculate14(for: selectedCardViews) {
            discardCardViews(selectedCardViews)
        }
        
        selectedCardViews.removeAll()
        timer?.invalidate(); timer = nil;
        seconds = 0; tapTime = 0
        let otherFaceUpCards = boardView.playingCardViews.filter { $0 != cardView && $0.isFaceUp == true }
        let _ = otherFaceUpCards.map { card in
            UIView.transition(with: card,
                              duration: 0.6,
                              options: .transitionFlipFromRight)
            { card.isFaceUp = false } completion: { _ in
                if let cardView = cardView {
                    self.flipCard(with: cardView)
                }
            }
            
        }
    }
    
    private func discardCardViews(_ cardViews: [PlayingCardView]) {
        cardViews.forEach { cardBehavior.addItem($0) }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            
            cardViews.forEach { cardView in
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.99, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
                    let cardFrame = cardView.frame
                    let discardedFrame = CGRect(origin: CGPoint(x: self.scoreLabel.frame.origin.x, y: self.scoreLabel.center.y - cardFrame.height), size: cardFrame.size)
                    cardView.frame = discardedFrame
                }, completion: {
                    _ in
                    UIView.transition(with: cardView, duration: 0.3, options: [.transitionFlipFromTop], animations: {
                        cardView.isFaceUp = true
                    }, completion:
                        {_ in
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [], animations: {
                                cardView.alpha = 0
                            }, completion: {
                                _ in
                                cardView.removeFromSuperview()
                                //                                self.boardView.playingCardViews.remove(object: cardView)
                                self.discardedCardViews.append(cardView)
                            })
                        })
                })
            }
        })
        cardViews.forEach { self.cardBehavior.remove($0) }
    }
    
    private func flipCard(with cardView: PlayingCardView) {
        tapTime = seconds
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(runTimer),
                                         userInfo: nil,
                                         repeats: true
            )
        }
        UIView.transition(with: cardView, duration: 0.6, options: .transitionFlipFromLeft) {
//            cardView.isFaceUp = cardView.isFaceUp ? false : true
            cardView.isFaceUp = true
        }
        cardView.isFaceUp ? selectedCardViews.append(cardView) : selectedCardViews.remove(object: cardView)
    }
    
    @objc func tapCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let cardView = sender.view as? PlayingCardView {
                guard seconds <= tapTime + 2 else {
                    findResultAndFlipOrDiscardCards(including: cardView)
                    return
                }
                flipCard(with: cardView)
            }
            
            
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6,
//                                                           delay: 0,
//                                                           options: []) {
//                cardView.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
//            }
            
            
//            cardBehavior.addItem(cardView)
//
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
//                self.cardBehavior.remove(cardView)
//                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.99, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
//                    let cardFrame = cardView.frame
//                    let discardedFrame = CGRect(origin: CGPoint(x: self.scoreLabel.frame.origin.x, y: self.scoreLabel.center.y - cardFrame.height), size: cardFrame.size)
//                    cardView.frame = discardedFrame
//                }, completion: {
//                    _ in
//                    UIView.transition(with: cardView, duration: 0.3, options: [.transitionFlipFromTop], animations: {
//                        cardView.isFaceUp = false
//                    }, completion:
//                        {_ in
//                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [], animations: {
//                                cardView.alpha = 0
//                            }, completion: {
//                                _ in
//                                cardView.removeFromSuperview()
////                                self.boardView.playingCardViews.remove(object: cardView)
//                                self.discardedCardViews.append(cardView)
//                            })
//                        })
//                })
//            })
        }
    }
    
    private func convertCard(from cardView: PlayingCardView) -> PlayingCard {
        var rank: PlayingCard.Rank {
            switch cardView.rank {
            case 1: return .ace
            case 2...10: return .numeric(pipsCount: cardView.rank)
            case 11: return .face(.jack)
            case 12: return .face(.queen)
            case 13: return .face(.king)
            default: break
            }
            return .ace
        }
        let suit = PlayingCard.Suit(rawValue: cardView.suit)!
        return PlayingCard(suit: suit , rank: rank)
    }
    
    @objc func selectCard(_ sender: UILongPressGestureRecognizer) {
//        discardedCards.removeAll()
        if sender.state == .began {
            if let cardView = sender.view as? PlayingCardView {
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6,
                                                               delay: 0,
                                                               options: []) {
                    self.boardView.bringSubviewToFront(cardView)
                    cardView.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                    cardView.isFaceUp = true
                }
                
            }
        }
        
        

    }
    
    func deal(numberOfCards number: Int = 3) {
        for _ in 1...number {
            guard !deck.cards.isEmpty else {return}
            let cardView = PlayingCardView()
            cardView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            cardView.isFaceUp = false
            self.boardView.playingCardViews.append(cardView)
            self.boardView.addSubview(cardView)
            if let card = self.deck.draw() {
                cardView.rank = card.rank.order
                cardView.suit = card.suit.rawValue
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapCard(_:)))
            cardView.addGestureRecognizer(tap)
            
            // long press
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            cardView.addGestureRecognizer(lp)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}

//extension ViewController: UIDynamicAnimatorDelegate {}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}
