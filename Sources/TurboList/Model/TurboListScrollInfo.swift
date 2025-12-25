//
//  TurboListScrollInfo.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//
import SwiftUI
import UIKit
public struct TurboListScrollInfo {
    public let contentOffset: CGPoint
    public let contentSize: CGSize
    public let bounds: CGRect
    public let insets: UIEdgeInsets
    public let isReversed: Bool

    public var distanceToTop: CGFloat {
        if isReversed {
            let maxScrollY = max(0, contentSize.height - bounds.height)
            return maxScrollY - contentOffset.y
        } else {
            return contentOffset.y + insets.top
        }
    }

    public var distanceToBottom: CGFloat {
        if isReversed {
            return contentOffset.y + insets.top
        } else {
            let maxScrollY = max(0, contentSize.height - bounds.height)
            return maxScrollY - contentOffset.y
        }
    }
}

public enum TurboListInitialScrollPosition: Sendable { case top, centered, bottom }

public enum TurboListScrollPosition: Sendable {
    case top, centered, bottom
    var uiKitPosition: UITableView.ScrollPosition {
        switch self {
        case .top: return .top
        case .centered: return .middle
        case .bottom: return .bottom
        }
    }
}
