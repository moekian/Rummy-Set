//
//  PlaynigCard.swift
//  PlayingCard
//
//  Created by Mohammad Kiani on 2021-08-31.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    
    var description: String { return "\(rank) \(suit.rawValue)"}
    
    
    var suit: Suit
    var rank: Rank
        
    enum Suit: String {
        case spades = "♠️"
        case hearts = "♥️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        static var all: [Suit] = [.spades, .hearts, .clubs, .diamonds]
    }
    
    enum Rank: CustomStringConvertible {
        
        var description: String {
            switch self {
            case .ace: return "A"
            case .numeric(let pips): return "\(pips)"
            case .face(let kind): return kind.rawValue
            }
        }
        
        case ace
        case face(Face)
        case numeric(pipsCount: Int)
        
        enum Face: String {
            case jack = "J"
            case king = "K"
            case queen = "Q"
        }
        
        var order: Int {
            switch self {
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == .jack: return 11
            case .face(let kind) where kind == .queen: return 12
            case .face(let kind) where kind == .king: return 13
            default: return 0
            }
        }
        
        static var all: [Rank] {
            var allRanks: [Rank] = [.ace]
            for pips in 2...10 {
                allRanks.append(.numeric(pipsCount: pips))
            }
            allRanks += [.face(.jack),
                         .face(.queen),
                         .face(.king)
            ]
            return allRanks
        }
    }
    
    
    
    
}
