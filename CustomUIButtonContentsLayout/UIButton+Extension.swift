import UIKit

// MARK: - 调整 imageView 和 titleLabel 布局。
extension UIButton {

    struct ContentsLayout {
        enum layoutType: Int {
            case imageTop, imageLeft, imageBottom, imageRight
        }
        var type: layoutType = .imageLeft
        // The layout of the arrangedSubviews along the axis.
        var distribution: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
        // The layout of the arrangedSubviews transverse to the axis.
        var alignment: (CGFloat, CGFloat) = (0, 0)
    }
    
    func transform(layout: ContentsLayout = ContentsLayout(),
                   title: String,
                   iconName: String,
                   constraints: (NSLayoutConstraint?, NSLayoutConstraint?)) {
        setTitle(title, for: .normal)
        setTitle(title, for: .highlighted)
        setImage(UIImage(named: iconName), for: .normal)
        setImage(UIImage(named: iconName), for: .highlighted)
        
        guard let imageView = imageView else { return }
        let defaultFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let attributes = [ NSAttributedStringKey.font: (titleLabel?.font ?? defaultFont) ]
        let textSize = (title as NSString).size(withAttributes: attributes)
        
        let (distPre, distMid, distPost) = layout.distribution
        let (alignPre, alignPost) = layout.alignment
        let defaultMargin = (distPre + distMid + distPost) / 2
        
        let imageLength: CGFloat
        let textLength: CGFloat
        let totalWidth: CGFloat
        let totalHeight: CGFloat
        switch layout.type {
        case .imageTop, .imageBottom:
            imageLength = imageView.frame.height
            textLength = textSize.height
            totalWidth = max(imageView.frame.width, textSize.width) + alignPre + alignPost
            totalHeight = textLength + imageLength + distPre + distMid + distPost
            
            /*
             系统计算结果
             */
            let systemAlignMargin: CGFloat
            if totalWidth < imageView.frame.width + textSize.width {
                systemAlignMargin = 0
                print("WARNING: 给定的按钮宽度太小，导致视图没有按照想象的显示。")
            } else {
                systemAlignMargin = (totalWidth - imageView.frame.width - textSize.width) / 2
            }
            let systemDistributionMargin = (totalHeight - max(imageLength, textLength)) / 2
            let systemImageViewCenterX = systemAlignMargin + imageView.frame.width / 2
            let systemTitleCenterX = systemAlignMargin + imageView.frame.width + textLength / 2
            
            let centerX = totalWidth / 2
            let imageOffsetHorizontal = centerX - systemImageViewCenterX
            let titleOffsetHorizontal = systemTitleCenterX - centerX
            
            let imageOffsetVertical: CGFloat
            let titleOffsetVertical: CGFloat
            if layout.type == .imageTop {
                imageOffsetVertical = ((totalHeight - imageLength) / 2 - distPre)
                titleOffsetVertical = (systemDistributionMargin - distPost)
            } else {
                imageOffsetVertical = distPost - (totalHeight - imageLength) / 2
                titleOffsetVertical = distPre - systemDistributionMargin
            }
            imageEdgeInsets = UIEdgeInsets(top: -imageOffsetVertical,
                                           left: imageOffsetHorizontal,
                                           bottom: imageOffsetVertical,
                                           right: -imageOffsetHorizontal)
            titleEdgeInsets = UIEdgeInsets(top: titleOffsetVertical,
                                           left: -titleOffsetHorizontal,
                                           bottom: -titleOffsetVertical,
                                           right: titleOffsetHorizontal)
        case .imageLeft, .imageRight:
            imageLength = imageView.frame.width
            textLength = textSize.width
            totalWidth = textLength + imageLength + distPre + distMid + distPost
            totalHeight = max(imageView.frame.height, imageView.frame.width) + alignPre + alignPost
            
            let imageOffset: CGFloat
            let titleOffset: CGFloat
            if layout.type == .imageLeft {
                imageOffset = distPre - defaultMargin
                titleOffset = distPost - defaultMargin
            } else {
                imageOffset = totalWidth - imageLength - distPost - defaultMargin
                titleOffset = imageLength + defaultMargin - distPre
            }
            imageEdgeInsets = UIEdgeInsets(top: 0, left: imageOffset, bottom: 0, right: -imageOffset)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -titleOffset, bottom: 0, right: titleOffset)
        }
        let (width, height) = constraints
        if let width_ = width { width_.constant = totalWidth }
        if let height_ = height { height_.constant = totalHeight }
        layoutIfNeeded()
    }
}
