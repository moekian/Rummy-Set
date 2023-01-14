//
//  File.swift
//  Rummy Set
//
//  Created by Mohammad Kiani on 2021-09-15.
//

import Foundation

struct Brain {
    static func calculate14(for cards: [PlayingCard]) -> Bool {
        let orders = cards.map { $0.rank.order }
        print(orders.reduce(0) { $0 + $1 })
        return orders.reduce(0) { $0 + $1 } == 14
    }
    
    static func calculate14(for cardViews: [PlayingCardView]) -> Bool {
        let orders = cardViews.map { $0.rank }
        return orders.reduce(0) { $0 + $1 } == 14
    }
}
