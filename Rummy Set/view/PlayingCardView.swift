//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Mohammad Kiani on 2021-09-01.
//

import UIKit

class PlayingCardView: UIView {
    
//    private weak var behavior: CardBehavior?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//    }
    
//    convenience init(_ behavior: CardBehavior) {
//        self.init(frame: CGRect.zero)
//    }
    
//    convenience init() {
//        self.init(frame: CGRect.zero)
//    }
    
    enum AnimationState {
        case noAnimation
        case flyingIn
        case flyingOut
        case discarded
    }
    var animationState: AnimationState = .flyingIn
    
    var rank: Int = 12 {didSet {setNeedsDisplay(); setNeedsLayout()}}
    var suit: String = "♠️" {didSet {setNeedsDisplay(); setNeedsLayout()}}
    var isFaceUp: Bool = true {didSet {setNeedsDisplay(); setNeedsLayout()}}
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        //  scale font in accessibility setting
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let color = (suit == "♥️" || suit == "♦️") ? #colorLiteral(red: 0.6806162, green: 0.01010422967, blue: 0.02282325365, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        // center the font in the paragraph
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: color])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    private lazy var  upperLeftCornerLabel: UILabel = createCornerLabel()
    private lazy var lowerRightCornerLabel: UILabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        // use as many lines as you want "0"
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    // when bounds are changing we need to override this method to layout the subview
    /// this method will be called by setNeedsLayout function and automatically by the system
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        configureCornerLabel(lowerRightCornerLabel)
        
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
        
        lowerRightCornerLabel.transform = CGAffineTransform.identity
//            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)
            .rotated(by: CGFloat.pi)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay(); setNeedsLayout()
    }
    
    private func drawPips()
    {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,1,2,1,2],[2,2,1,2,2],[2,1,2,2,1,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
//            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
//            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
//            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
//            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
//                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
//            } else {
//                return probablyOkayPipString
//            }
            return attemptedPipString
        }
        
        func rotatePip(_ string: NSAttributedString, in rect: CGRect) {
            let textSize = string.size()
            let context = UIGraphicsGetCurrentContext()!
            context.saveGState()
            // Translate the origin to the drawing location and rotate the coordinate system.
            let point = CGPoint(x: rect.midX, y: rect.midY)
            context.translateBy(x: point.x, y: point.y)
            context.rotate(by: .pi)
//            string.draw(in: rect)
            string.draw(at: CGPoint(x: -textSize.width / 2, y: -textSize.height / 2))
            context.restoreGState()
        }
        
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset / 2, dy: cornerOffset / 2).insetBy(dx: cornerString.size().width / 2, dy: cornerString.size().height / 4)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pip in pipsPerRow.indices {
                switch pipsPerRow[pip] {
                case 1:
                    pip >= pipsPerRow.count/2 ? rotatePip(pipString, in: pipRect) : pipString.draw(in: pipRect)
                case 2:
                    pip >= pipsPerRow.count/2 ? rotatePip(pipString, in: pipRect.leftHalf) : pipString.draw(in: pipRect.leftHalf)
                    pip >= pipsPerRow.count/2 ? rotatePip(pipString, in: pipRect.rightHalf) : pipString.draw(in: pipRect.rightHalf)
//                    pipString.draw(in: pipRect.leftHalf)
//                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /// this method will be called by setNeedsDisplay function and automatically by the system
    /// - Parameter rect: view rectangle
    override func draw(_ rect: CGRect) {
       
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        isFaceUp ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill() : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).setFill()
        
//        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: SizeRatio.faceCardImageSizeToBoundsSize))
            } else {
                drawPips()
            }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds.zoom(by: SizeRatio.backImageSizeToBoundsSize))
            }
        }
        
    }
}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize:CGFloat = 0.75
        static let backImageSizeToBoundsSize:CGFloat = 1.1
        
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    static func rotateRect(_ rect: CGRect) -> CGRect {
        let x = rect.midX
        let y = rect.midY
        let transform = CGAffineTransform(translationX: x, y: y)
                                        .rotated(by: .pi)
                                        .translatedBy(x: -x, y: -y)
        return rect.applying(transform)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
