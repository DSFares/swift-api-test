//
//  Snappy
//
//  Copyright (c) 2011-2014 Masonry Team - https://github.com/Masonry
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS)
    import UIKit
    public typealias View = UIView
    #else
    import AppKit
    public typealias View = NSView
#endif

public extension View {
    public var snp_left: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Left) }
    public var snp_top: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Top) }
    public var snp_right: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Right) }
    public var snp_bottom: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Bottom) }
    public var snp_leading: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Leading) }
    public var snp_trailing: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Trailing) }
    public var snp_width: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Width) }
    public var snp_height: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Height) }
    public var snp_centerX: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.CenterX) }
    public var snp_centerY: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.CenterY) }
    public var snp_baseline: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Baseline) }
    
    public var snp_firstBaseline: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.FirstBaseline) }
    
    public var snp_leftMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.LeftMargin) }
    public var snp_rightMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.RightMargin) }
    public var snp_topMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.TopMargin) }
    public var snp_bottomMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.BottomMargin) }
    public var snp_leadingMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.LeadingMargin) }
    public var snp_trailingMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.TrailingMargin) }
    public var snp_centerXWithinMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.CenterXWithinMargins) }
    public var snp_centerYWithinMargin: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.CenterYWithinMargins) }
    
    public var snp_edges: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Edges) }
    public var snp_size: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Size) }
    public var snp_center: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Center) }
    
    public var snp_margins: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.Margins) }
    public var snp_centerWithinMargins: ConstraintItem { return ConstraintItem(view: self, attributes: ConstraintAttributes.CenterWithinMargins) }
    
    public func snp_makeConstraints(block: (maker: ConstraintMaker) -> ()) {
        ConstraintMaker.makeConstraints(self, block: block)
    }
    
    public func snp_remakeConstraints(block: (maker: ConstraintMaker) -> ()) {
        ConstraintMaker.remakeConstraints(self, block: block)
    }
}

/**
* ConstraintMaker is the maker in snappy that gets all constraints kickstarted
*/
public class ConstraintMaker {
    public var left: Constraint { return addConstraint(ConstraintAttributes.Left) }
    public var top: Constraint { return addConstraint(ConstraintAttributes.Top) }
    public var right: Constraint { return addConstraint(ConstraintAttributes.Right) }
    public var bottom: Constraint { return addConstraint(ConstraintAttributes.Bottom) }
    public var leading: Constraint { return addConstraint(ConstraintAttributes.Leading) }
    public var trailing: Constraint { return addConstraint(ConstraintAttributes.Trailing) }
    public var width: Constraint { return addConstraint(ConstraintAttributes.Width) }
    public var height: Constraint { return addConstraint(ConstraintAttributes.Height) }
    public var centerX: Constraint { return addConstraint(ConstraintAttributes.CenterX) }
    public var centerY: Constraint { return addConstraint(ConstraintAttributes.CenterY) }
    public var baseline: Constraint { return addConstraint(ConstraintAttributes.Baseline) }
    
    public var edges: Constraint { return addConstraint(ConstraintAttributes.Edges) }
    public var size: Constraint { return addConstraint(ConstraintAttributes.Size) }
    public var center: Constraint { return addConstraint(ConstraintAttributes.Center) }
    
    init(view: View) {
        self.view = view
    }
    
    internal weak var view: View?
    internal var constraints = Array<Constraint>()
    
    internal func addConstraint(attributes: ConstraintAttributes) -> Constraint {
        let item = ConstraintItem(view: self.view, attributes: attributes)
        let constraint = Constraint(fromItem: item)
        self.constraints.append(constraint)
        return constraint
    }
    
    internal class func makeConstraints(view: View, block: (make: ConstraintMaker) -> ()) {
        #if os(iOS)
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            #else
            view.translatesAutoresizingMaskIntoConstraints = false
        #endif
        let maker = ConstraintMaker(view: view)
        block(make: maker)
        
        var layoutConstraints: Array<LayoutConstraint> = []
        for constraint in maker.constraints {
            layoutConstraints += constraint.install()
        }
        LayoutConstraint.setLayoutConstraints(layoutConstraints, installedOnView: view)
    }
    
    internal class func remakeConstraints(view: View, block: (make: ConstraintMaker) -> ()) {
        #if os(iOS)
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            #else
            view.translatesAutoresizingMaskIntoConstraints = false
        #endif
        let maker = ConstraintMaker(view: view)
        block(make: maker)
        
        var layoutConstraints: Array<LayoutConstraint> = LayoutConstraint.layoutConstraintsInstalledOnView(view)
        for existingLayoutConstraint in layoutConstraints {
            existingLayoutConstraint.constraint?.uninstall()
        }
        layoutConstraints = []
        
        for constraint in maker.constraints {
            layoutConstraints += constraint.install()
        }
        LayoutConstraint.setLayoutConstraints(layoutConstraints, installedOnView: view)
    }
}

/**
* Constraint is a single item that defines all the properties for a single ConstraintMaker chain
*/
public class Constraint {
    public var left: Constraint { return addConstraint(ConstraintAttributes.Left) }
    public var top: Constraint { return addConstraint(ConstraintAttributes.Top) }
    public var right: Constraint { return addConstraint(ConstraintAttributes.Right) }
    public var bottom: Constraint { return addConstraint(ConstraintAttributes.Bottom) }
    public var leading: Constraint { return addConstraint(ConstraintAttributes.Leading) }
    public var trailing: Constraint { return addConstraint(ConstraintAttributes.Trailing) }
    public var width: Constraint { return addConstraint(ConstraintAttributes.Width) }
    public var height: Constraint { return addConstraint(ConstraintAttributes.Height) }
    public var centerX: Constraint { return addConstraint(ConstraintAttributes.CenterX) }
    public var centerY: Constraint { return addConstraint(ConstraintAttributes.CenterY) }
    public var baseline: Constraint { return addConstraint(ConstraintAttributes.Baseline) }
    
    public var and: Constraint { return self }
    public var with: Constraint { return self }
    
    // MARK: initializer
    
    internal init(fromItem: ConstraintItem) {
        self.fromItem = fromItem
        self.toItem = ConstraintItem(view: nil, attributes: ConstraintAttributes.None)
    }
    
    // MARK: equalTo
    
    public func equalTo(other: ConstraintItem) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    public func equalTo(other: View) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    public func equalTo(other: Float) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    public func equalTo(other: Double) -> Constraint {
        return constrainTo(Float(other), relation: .Equal)
    }
    public func equalTo(other: CGFloat) -> Constraint {
        return constrainTo(Float(other), relation: .Equal)
    }
    public func equalTo(other: Int) -> Constraint {
        return constrainTo(Float(other), relation: .Equal)
    }
    public func equalTo(other: UInt) -> Constraint {
        return constrainTo(Float(other), relation: .Equal)
    }
    public func equalTo(other: CGSize) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    public func equalTo(other: CGPoint) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    public func equalTo(other: EdgeInsets) -> Constraint {
        return constrainTo(other, relation: .Equal)
    }
    
    // MARK: lessThanOrEqualTo
    
    public func lessThanOrEqualTo(other: ConstraintItem) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: View) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: Float) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: Double) -> Constraint {
        return constrainTo(Float(other), relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: CGFloat) -> Constraint {
        return constrainTo(Float(other), relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: Int) -> Constraint {
        return constrainTo(Float(other), relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: UInt) -> Constraint {
        return constrainTo(Float(other), relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: CGSize) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: CGPoint) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    public func lessThanOrEqualTo(other: EdgeInsets) -> Constraint {
        return constrainTo(other, relation: .LessThanOrEqualTo)
    }
    
    // MARK: greaterThanOrEqualTo
    
    public func greaterThanOrEqualTo(other: ConstraintItem) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    func greaterThanOrEqualTo(other: View) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: Float) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: Double) -> Constraint {
        return constrainTo(Float(other), relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: CGFloat) -> Constraint {
        return constrainTo(Float(other), relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: Int) -> Constraint {
        return constrainTo(Float(other), relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: UInt) -> Constraint {
        return constrainTo(Float(other), relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: CGSize) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: CGPoint) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    public func greaterThanOrEqualTo(other: EdgeInsets) -> Constraint {
        return constrainTo(other, relation: .GreaterThanOrEqualTo)
    }
    
    // MARK: multiplier
    
    public func multipliedBy(amount: Float) -> Constraint {
        self.multiplier = amount
        return self
    }
    public func multipliedBy(amount: Double) -> Constraint {
        return self.multipliedBy(Float(amount))
    }
    public func multipliedBy(amount: CGFloat) -> Constraint {
        return self.multipliedBy(Float(amount))
    }
    public func multipliedBy(amount: Int) -> Constraint {
        return self.multipliedBy(Float(amount))
    }
    public func multipliedBy(amount: UInt) -> Constraint {
        return self.multipliedBy(Float(amount))
    }
    
    public func dividedBy(amount: Float) -> Constraint {
        self.multiplier = 1.0 / amount;
        return self
    }
    public func dividedBy(amount: Double) -> Constraint {
        return self.dividedBy(Float(amount))
    }
    public func dividedBy(amount: CGFloat) -> Constraint {
        return self.dividedBy(Float(amount))
    }
    public func dividedBy(amount: Int) -> Constraint {
        return self.dividedBy(Float(amount))
    }
    public func dividedBy(amount: UInt) -> Constraint {
        return self.dividedBy(Float(amount))
    }
    
    // MARK: priority
    
    public func priority(priority: Float) -> Constraint {
        self.priority = priority
        return self
    }
    public func priority(priority: Double) -> Constraint {
        return self.priority(Float(priority))
    }
    public func priority(priority: CGFloat) -> Constraint {
        return self.priority(Float(priority))
    }
    public func priority(priority: UInt) -> Constraint {
        return self.priority(Float(priority))
    }
    public func priority(priority: Int) -> Constraint {
        return self.priority(Float(priority))
    }
    public func priorityRequired() -> Constraint {
        return self.priority(1000.0)
    }
    public func priorityHigh() -> Constraint {
        return self.priority(750.0)
    }
    public func priorityLow() -> Constraint {
        return self.priority(250.0)
    }
    
    // MARK: offset
    
    public func offset(amount: Float) -> Constraint {
        self.offset = amount
        return self
    }
    public func offset(amount: Double) -> Constraint {
        return self.offset(Float(amount))
    }
    public func offset(amount: CGFloat) -> Constraint {
        return self.offset(Float(amount))
    }
    public func offset(amount: Int) -> Constraint {
        return self.offset(Float(amount))
    }
    public func offset(amount: UInt) -> Constraint {
        return self.offset(Float(amount))
    }
    public func offset(amount: CGPoint) -> Constraint {
        self.offset = amount
        return self
    }
    public func offset(amount: CGSize) -> Constraint {
        self.offset = amount
        return self
    }
    public func offset(amount: EdgeInsets) -> Constraint {
        self.offset = amount
        return self
    }
    
    // MARK: insets
    
    public func insets(amount: EdgeInsets) -> Constraint {
        self.offset = amount
        return self
    }
    
    // MARK: install
    
    public func install() -> Array<LayoutConstraint> {
        var installOnView: View? = nil
        if self.toItem.view != nil {
            installOnView = Constraint.closestCommonSuperviewFromView(self.fromItem.view, toView: self.toItem.view)
            if installOnView == nil {
                NSException(name: "Cannot Install Constraint", reason: "No common superview between views", userInfo: nil).raise()
                return []
            }
        } else {
            installOnView = self.fromItem.view?.superview
            if installOnView == nil {
                NSException(name: "Cannot Install Constraint", reason: "Missing superview", userInfo: nil).raise()
                return []
            }
        }
        
        var layoutConstraints: Array<LayoutConstraint> = []
        let layoutFromAttributes = self.fromItem.attributes.layoutAttributes
        let layoutToAttributes = self.toItem.attributes.layoutAttributes
        
        // get layout from
        let layoutFrom: View? = self.fromItem.view
        
        // get layout relation
        let layoutRelation: NSLayoutRelation = (self.relation != nil) ? self.relation!.layoutRelation : .Equal
        
        for layoutFromAttribute in layoutFromAttributes {
            // get layout to attribute
            let layoutToAttribute = (layoutToAttributes.count > 0) ? layoutToAttributes[0] : layoutFromAttribute
            
            // get layout constant
            var layoutConstant: CGFloat = layoutToAttribute.snp_constantForValue(self.constant)
            layoutConstant += layoutToAttribute.snp_offsetForValue(self.offset)
            
            // get layout to
            var layoutTo: View? = self.toItem.view
            if layoutTo == nil && layoutToAttribute != .Width && layoutToAttribute != .Height {
                layoutTo = installOnView
            }
            
            // create layout constraint
            let layoutConstraint = LayoutConstraint(
                item: layoutFrom!,
                attribute: layoutFromAttribute,
                relatedBy: layoutRelation,
                toItem: layoutTo,
                attribute: layoutToAttribute,
                multiplier: CGFloat(self.multiplier),
                constant: layoutConstant)
            
            // set priority
            layoutConstraint.priority = self.priority
            
            // set constraint
            layoutConstraint.constraint = self
            
            layoutConstraints.append(layoutConstraint)
        }
        
        installOnView?.addConstraints(layoutConstraints)
        
        self.installedOnView = installOnView
        return layoutConstraints
    }
    
    // MARK: uninstall
    
    public func uninstall() {
        if let view = self.installedOnView {
            #if os(iOS)
                var installedConstraints = view.constraints()
                #else
                var installedConstraints = view.constraints
            #endif
            var constraintsToRemove: Array<LayoutConstraint> = []
            for installedConstraint in installedConstraints {
                if let layoutConstraint = installedConstraint as? LayoutConstraint {
                    if layoutConstraint.constraint === self {
                        constraintsToRemove.append(layoutConstraint)
                    }
                }
            }
            if constraintsToRemove.count > 0 {
                view.removeConstraints(constraintsToRemove)
            }
        }
        self.installedOnView = nil
    }
    
    // MARK: private
    
    private let fromItem: ConstraintItem
    private var toItem: ConstraintItem
    private var relation: ConstraintRelation?
    private var constant: Any?
    private var multiplier: Float = 1.0
    private var priority: Float = 1000.0
    private var offset: Any?
    
    private weak var installedOnView: View?
    
    private func addConstraint(attributes: ConstraintAttributes) -> Constraint {
        if self.relation == nil {
            self.fromItem.attributes += attributes
        }
        return self
    }
    
    private func constrainTo(other: ConstraintItem, relation: ConstraintRelation) -> Constraint {
        if other.attributes != ConstraintAttributes.None {
            var toLayoutAttributes = other.attributes.layoutAttributes
            if toLayoutAttributes.count > 1 {
                var fromLayoutAttributes = self.fromItem.attributes.layoutAttributes
                if toLayoutAttributes != fromLayoutAttributes {
                    NSException(name: "Invalid Constraint", reason: "Cannot constrain to multiple non identical attributes", userInfo: nil).raise()
                    return self
                }
                other.attributes = ConstraintAttributes.None
            }
        }
        self.toItem = other
        self.relation = relation
        return self
    }
    private func constrainTo(other: View, relation: ConstraintRelation) -> Constraint {
        return constrainTo(ConstraintItem(view: other, attributes: ConstraintAttributes.None), relation: relation)
    }
    private func constrainTo(other: Float, relation: ConstraintRelation) -> Constraint {
        self.constant = other
        return constrainTo(ConstraintItem(view: nil, attributes: ConstraintAttributes.None), relation: relation)
    }
    private func constrainTo(other: Double, relation: ConstraintRelation) -> Constraint {
        self.constant = other
        return constrainTo(ConstraintItem(view: nil, attributes: ConstraintAttributes.None), relation: relation)
    }
    private func constrainTo(other: CGSize, relation: ConstraintRelation) -> Constraint {
        self.constant = other
        return constrainTo(ConstraintItem(view: nil, attributes: ConstraintAttributes.None), relation: relation)
    }
    private func constrainTo(other: CGPoint, relation: ConstraintRelation) -> Constraint {
        self.constant = other
        return constrainTo(ConstraintItem(view: nil, attributes: ConstraintAttributes.None), relation: relation)
    }
    private func constrainTo(other: EdgeInsets, relation: ConstraintRelation) -> Constraint {
        self.constant = other
        return constrainTo(ConstraintItem(view: nil, attributes: ConstraintAttributes.None), relation: relation)
    }
    
    private class func closestCommonSuperviewFromView(fromView: View?, toView: View?) -> View? {
        var closestCommonSuperview: View?
        var secondViewSuperview: View? = toView
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview = fromView
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
    }
}

private extension NSLayoutAttribute {
    
    private func snp_offsetForValue(value: Any?) -> CGFloat {
        // Float
        if let float = value as? Float {
            return CGFloat(float)
        }
            // Double
        else if let double = value as? Double {
            return CGFloat(double)
        }
            // UInt
        else if let int = value as? Int {
            return CGFloat(int)
        }
            // Int
        else if let uint = value as? UInt {
            return CGFloat(uint)
        }
            // CGFloat
        else if let float = value as? CGFloat {
            return float
        }
            // CGSize
        else if let size = value as? CGSize {
            if self == .Width {
                return size.width
            } else if self == .Height {
                return size.height
            }
        }
            // CGPoint
        else if let point = value as? CGPoint {
            if self == .Left || self == .CenterX {
                return point.x
            } else if self == .Top || self == .CenterY {
                return point.y
            } else if self == .Right {
                return -point.x
            } else if self == .Bottom {
                return -point.y
            }
        }
            // EdgeInsets
        else if let insets = value as? EdgeInsets {
            if self == .Left {
                return insets.left
            } else if self == .Top {
                return insets.top
            } else if self == .Right {
                return -insets.right
            } else if self == .Bottom {
                return -insets.bottom
            }
        }
        
        return CGFloat(0)
    }
    
    private func snp_constantForValue(value: Any?) -> CGFloat {
        // Float
        if let float = value as? Float {
            return CGFloat(float)
        }
            // Double
        else if let double = value as? Double {
            return CGFloat(double)
        }
            // UInt
        else if let int = value as? Int {
            return CGFloat(int)
        }
            // Int
        else if let uint = value as? UInt {
            return CGFloat(uint)
        }
            // CGFloat
        else if let float = value as? CGFloat {
            return float
        }
            // CGSize
        else if let size = value as? CGSize {
            if self == .Width {
                return size.width
            } else if self == .Height {
                return size.height
            }
        }
            // CGPoint
        else if let point = value as? CGPoint {
            if self == .Left || self == .CenterX {
                return point.x
            } else if self == .Top || self == .CenterY {
                return point.y
            } else if self == .Right {
                return point.x
            } else if self == .Bottom {
                return point.y
            }
        }
            // EdgeInsets
        else if let insets = value as? EdgeInsets {
            if self == .Left {
                return insets.left
            } else if self == .Top {
                return insets.top
            } else if self == .Right {
                return -insets.right
            } else if self == .Bottom {
                return -insets.bottom
            }
        }
        
        return CGFloat(0);
    }
}

/**
* ConstraintItem is a class that is used while building constraints.
*/
public class ConstraintItem {
    
    internal init(view: View?, attributes: ConstraintAttributes) {
        self.view = view
        self.attributes = attributes
    }
    
    internal weak var view: View?
    internal var attributes: ConstraintAttributes
}

/**
* ConstraintAttributes is an options set that maps to NSLayoutAttributes.
*/
internal struct ConstraintAttributes: RawOptionSetType, BooleanType {
    
    internal init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    internal init(_ rawValue: UInt) {
        self.init(rawValue: rawValue)
    }
    internal init(nilLiteral: ()) {
        self.rawValue = 0
    }
    
    internal private(set) var rawValue: UInt
    internal static var allZeros: ConstraintAttributes { return self(0) }
    internal static func convertFromNilLiteral() -> ConstraintAttributes { return self(0) }
    internal var boolValue: Bool { return self.rawValue != 0 }
    
    func toRaw() -> UInt { return self.rawValue }
    static func fromRaw(raw: UInt) -> ConstraintAttributes? { return self(raw) }
    static func fromMask(raw: UInt) -> ConstraintAttributes { return self(raw) }
    
    internal static var None: ConstraintAttributes { return self(0) }
    internal static var Left: ConstraintAttributes { return self(1) }
    internal static var Top: ConstraintAttributes {  return self(2) }
    internal static var Right: ConstraintAttributes { return self(4) }
    internal static var Bottom: ConstraintAttributes { return self(8) }
    internal static var Leading: ConstraintAttributes { return self(16) }
    internal static var Trailing: ConstraintAttributes { return self(32) }
    internal static var Width: ConstraintAttributes { return self(64) }
    internal static var Height: ConstraintAttributes { return self(128) }
    internal static var CenterX: ConstraintAttributes { return self(256) }
    internal static var CenterY: ConstraintAttributes { return self(512) }
    internal static var Baseline: ConstraintAttributes { return self(1024) }
    
    internal static var FirstBaseline: ConstraintAttributes { return self(2048) }
    
    internal static var LeftMargin: ConstraintAttributes { return self(4096) }
    internal static var RightMargin: ConstraintAttributes { return self(8192) }
    internal static var TopMargin: ConstraintAttributes { return self(16384) }
    internal static var BottomMargin: ConstraintAttributes { return self(32768) }
    internal static var LeadingMargin: ConstraintAttributes { return self(65536) }
    internal static var TrailingMargin: ConstraintAttributes { return self(131072) }
    internal static var CenterXWithinMargins: ConstraintAttributes { return self(262144) }
    internal static var CenterYWithinMargins: ConstraintAttributes { return self(524288) }
    
    internal static var Edges: ConstraintAttributes { return self(15) }
    internal static var Size: ConstraintAttributes { return self(192) }
    internal static var Center: ConstraintAttributes { return self(768) }
    internal static var Margins: ConstraintAttributes { return self(61440) }
    internal static var CenterWithinMargins: ConstraintAttributes { return self(786432) }
    
    internal var layoutAttributes:Array<NSLayoutAttribute> {
        var attrs: Array<NSLayoutAttribute> = []
        if (self & ConstraintAttributes.Left) {
            attrs.append(.Left)
        }
        if (self & ConstraintAttributes.Top) {
            attrs.append(.Top)
        }
        if (self & ConstraintAttributes.Right) {
            attrs.append(.Right)
        }
        if (self & ConstraintAttributes.Bottom) {
            attrs.append(.Bottom)
        }
        if (self & ConstraintAttributes.Leading) {
            attrs.append(.Leading)
        }
        if (self & ConstraintAttributes.Trailing) {
            attrs.append(.Trailing)
        }
        if (self & ConstraintAttributes.Width) {
            attrs.append(.Width)
        }
        if (self & ConstraintAttributes.Height) {
            attrs.append(.Height)
        }
        if (self & ConstraintAttributes.CenterX) {
            attrs.append(.CenterX)
        }
        if (self & ConstraintAttributes.CenterY) {
            attrs.append(.CenterY)
        }
        if (self & ConstraintAttributes.Baseline) {
            attrs.append(.Baseline)
        }
        if (self & ConstraintAttributes.FirstBaseline) {
            attrs.append(.FirstBaseline)
        }
        if (self & ConstraintAttributes.LeftMargin) {
            attrs.append(.LeftMargin)
        }
        if (self & ConstraintAttributes.RightMargin) {
            attrs.append(.RightMargin)
        }
        if (self & ConstraintAttributes.TopMargin) {
            attrs.append(.TopMargin)
        }
        if (self & ConstraintAttributes.BottomMargin) {
            attrs.append(.BottomMargin)
        }
        if (self & ConstraintAttributes.LeadingMargin) {
            attrs.append(.LeadingMargin)
        }
        if (self & ConstraintAttributes.TrailingMargin) {
            attrs.append(.TrailingMargin)
        }
        if (self & ConstraintAttributes.CenterXWithinMargins) {
            attrs.append(.CenterXWithinMargins)
        }
        if (self & ConstraintAttributes.CenterYWithinMargins) {
            attrs.append(.CenterYWithinMargins)
        }
        return attrs
    }
}
internal func += (inout left: ConstraintAttributes, right: ConstraintAttributes) {
    left = (left | right)
}
internal func -= (inout left: ConstraintAttributes, right: ConstraintAttributes) {
    left = left & ~right
}
internal func == (left: ConstraintAttributes, right: ConstraintAttributes) -> Bool {
    return left.rawValue == right.rawValue
}

/**
* ConstraintRelation is an Int enum that maps to NSLayoutRelation.
*/
internal enum ConstraintRelation: Int {
    case Equal = 1, LessThanOrEqualTo, GreaterThanOrEqualTo
    
    internal var layoutRelation: NSLayoutRelation {
        get {
            switch(self) {
            case .LessThanOrEqualTo:
                return .LessThanOrEqual
            case .GreaterThanOrEqualTo:
                return .GreaterThanOrEqual
            default:
                return .Equal
            }
        }
    }
}

/**
* LayoutConstraint is a subclass of NSLayoutConstraint to assist Snappy and also provide better debugging
*/
public class LayoutConstraint: NSLayoutConstraint {
    
    // internal
    
    internal var constraint: Constraint?
    
    internal class func layoutConstraintsInstalledOnView(view: View) -> Array<LayoutConstraint> {
        var constraints = objc_getAssociatedObject(view, &layoutConstraintsInstalledOnViewKey) as? Array<LayoutConstraint>
        if constraints != nil {
            return constraints!
        }
        return []
    }
    internal class func setLayoutConstraints(layoutConstraints: Array<LayoutConstraint>, installedOnView view: View) {
        objc_setAssociatedObject(view, &layoutConstraintsInstalledOnViewKey, layoutConstraints, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
}

private var layoutConstraintsInstalledOnViewKey = ""

#if os(iOS)
    import UIKit
    public typealias EdgeInsets = UIEdgeInsets
    public func EdgeInsetsMake(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    public let EdgeInsetsZero = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    #else
    import AppKit
    public struct EdgeInsets {
    public var top: CGFloat // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat
    }
    public func EdgeInsetsMake(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> EdgeInsets {
    return EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    public let EdgeInsetsZero = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
#endif
