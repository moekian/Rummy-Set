//
//  CardBehavior.swift
//  Rummy Set
//
//  Created by Mohammad Kiani on 2021-09-12.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    // collision behavior
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1
        behavior.resistance = 0
        behavior.friction = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
//        let angle = Double.random(in: 0...2*Double.pi)
//        push.setAngle(CGFloat(angle), magnitude: 15)
        push.angle = (2*CGFloat.pi).random
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            push.magnitude = referenceBounds.width * 4/375
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            push.angle = (CGFloat.pi/2).random
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -1 * push.angle
            case let (x, y) where x > center.x:
                push.angle = y < center.y ? CGFloat.pi-push.angle: CGFloat.pi+push.angle
            default:
                push.angle = (CGFloat.pi*2).random
            }
        }
        
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
//    var snapPoint = CGPoint()
    private func snap(_ item: UIDynamicItem, point snapPoint: CGPoint? = nil) {
        if let snap = snapPoint {
            let snapBehavior = UISnapBehavior(item: item, snapTo: snap)
            addChildBehavior(snapBehavior)
        }
    }
    
    func addItem(_ item: UIDynamicItem, point snapPoint: CGPoint? = nil) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
        snap(item, point: snapPoint)
    }
    
    func remove(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension CGFloat {
    var random: CGFloat {
        return self * CGFloat(drand48())
    }
}
