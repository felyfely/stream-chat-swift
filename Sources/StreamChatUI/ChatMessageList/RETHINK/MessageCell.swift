//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

class MessageCell<ExtraData: ExtraDataTypes>: _CollectionViewCell, UIConfigProvider {
    static var reuseId: String { "message_cell" }

    var content: _ChatMessage<ExtraData>? {
        didSet {
            updateContentIfNeeded()
        }
    }

    private var layoutOptions: ChatMessageLayoutOptions!
    
    var bubbleView: BubbleView<ExtraData>?
    var textView: UITextView?

    lazy var mainContainer: ContainerView = ContainerView(axis: .horizontal)
        .withoutAutoresizingMaskConstraints
    
    func setUpLayoutIfNeeded(options: ChatMessageLayoutOptions) {
        guard layoutOptions == nil else {
            assert(layoutOptions == options, "Attempt to apply different layout")
            return
        }
        
        layoutOptions = options
        
        var constraintsToActivate: [NSLayoutConstraint] = []
        
        // Main container
        mainContainer.alignment = .axisTrailing
        mainContainer.isLayoutMarginsRelativeArrangement = true
        mainContainer.layoutMargins.top = 0
        
        contentView.addSubview(mainContainer)
        constraintsToActivate += [
            mainContainer.topAnchor.pin(equalTo: contentView.topAnchor),
            mainContainer.bottomAnchor.pin(equalTo: contentView.bottomAnchor),
            mainContainer.widthAnchor.pin(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ]
        
        if options.contains(.flipped) {
            mainContainer.ordering = .trailingToLeading
            constraintsToActivate += [mainContainer.trailingAnchor.pin(equalTo: contentView.trailingAnchor)]
        } else {
            constraintsToActivate += [mainContainer.leadingAnchor.pin(equalTo: contentView.leadingAnchor)]
        }

        // Bubble view
        let bubbleView = createBubbleView()
        mainContainer.addArrangedSubview(bubbleView)
        if options.contains(.continuousBubble) {
            bubbleView.roundedCorners = .all
            mainContainer.layoutMargins.bottom = 0

        } else if options.contains(.flipped) {
            bubbleView.roundedCorners = CACornerMask.all.subtracting(.layerMaxXMaxYCorner)

        } else {
            bubbleView.roundedCorners = CACornerMask.all.subtracting(.layerMinXMaxYCorner)
        }

        let bubbleContainer = ContainerView(axis: .vertical).withoutAutoresizingMaskConstraints
        bubbleView.embed(bubbleContainer)

        // Text
        if options.contains(.text) {
            let textView = createTextView()
            bubbleContainer.addArrangedSubview(textView, respectsLayoutMargins: true)
        }
        
        NSLayoutConstraint.activate(constraintsToActivate)
    }

    override func updateContent() {
        // Text
        textView?.text = content?.text
        
        // Bubble view
        if content?.type == .ephemeral {
            bubbleView?.backgroundColor = uiConfig.colorPalette.popoverBackground
            
        } else if layoutOptions?.contains(.linkPreview) == true {
            bubbleView?.backgroundColor = uiConfig.colorPalette.highlightedAccentBackground1
            
        } else {
            bubbleView?.backgroundColor = content?.isSentByCurrentUser == true ?
                uiConfig.colorPalette.background2 :
                uiConfig.colorPalette.popoverBackground
        }
    }
    
    override open func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let preferredAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(
            width: layoutAttributes.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        preferredAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return preferredAttributes
    }
}

// MARK: - Setups

private extension MessageCell {
    func createTextView() -> UITextView {
        if textView == nil {
            textView = OnlyLinkTappableTextView().withoutAutoresizingMaskConstraints
            textView?.isEditable = false
            textView?.dataDetectorTypes = .link
            textView?.isScrollEnabled = false
            textView?.backgroundColor = .clear
            textView?.adjustsFontForContentSizeCategory = true
            textView?.textContainerInset = .zero
            textView?.textContainer.lineFragmentPadding = 0
            textView?.translatesAutoresizingMaskIntoConstraints = false
            textView?.font = uiConfig.font.body
        }
        return textView!
    }

    func createBubbleView() -> BubbleView<ExtraData> {
        if bubbleView == nil {
            bubbleView = BubbleView<ExtraData>().withoutAutoresizingMaskConstraints
        }
        return bubbleView!
    }
}
