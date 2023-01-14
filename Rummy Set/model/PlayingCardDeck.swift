//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Mohammad Kiani on 2021-08-31.
//

import Foundation

struct PlayingCardDeck {
    
    private(set) var cards = [PlayingCard]()
    
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.randonmFrom0ToSelf)
        } else {
            return nil
        }
    }
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
}

//MARK: - Int extention for choosing a random number
extension Int {
    
    /// property returning a random number from zero included up to the number itself
    var randonmFrom0ToSelf: Int {
        if self > 0 {
            return Int.random(in: 0..<self)
        } else if self < 0 {
            return -Int.random(in: 0..<abs(self))
        } else {
            return 0
        }
    }
}
