//
//  TurboDynamicCocoaCell.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//


import SwiftUI
import UIKit

@MainActor
class TurboDynamicCocoaCell<Content: View>: UITableViewCell {
    private var hostingController: UIHostingController<Content>?
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let bottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottom.priority = .defaultHigh

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottom,
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with content: Content, in parent: UIViewController, isReversed: Bool) {
        transform = isReversed ? CGAffineTransform(scaleX: 1, y: -1) : .identity

        if let hc = hostingController {
            hc.rootView = content
            hc.view.setNeedsLayout()
            hc.view.setNeedsUpdateConstraints()
        } else {
            let hc = UIHostingController(rootView: content)
            hc.view.backgroundColor = .clear
            parent.addChild(hc)
            containerView.addSubview(hc.view)
            hc.didMove(toParent: parent)
            hc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                hc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                hc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                hc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
            hostingController = hc
        }
    }
}
