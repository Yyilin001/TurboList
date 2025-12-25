//
//  File.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//
import SwiftUI

extension View {
    public func turboListReversed(_ isReversed: Bool = true) -> some View { environment(\.isTurboListReversed, isReversed) }
    public nonisolated func onTurboListScroll(_ action: @Sendable @escaping (TurboListScrollInfo) -> Void) -> some View { environment(\.turboListOnScroll, action) }
    public func turboListBounces(_ enabled: Bool) -> some View { environment(\.turboListBounces, enabled) }
    public func turboListInsertAnimation(_ animation: UITableView.RowAnimation) -> some View { environment(\.turboListInsertAnimation, animation) }
    public func turboListKeyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> some View { environment(\.turboListKeyboardDismissMode, mode) }
    public func turboListShowIndicators(_ show: Bool) -> some View { environment(\.turboListShowIndicators, show) }
    public func turboListContentInset(_ insets: EdgeInsets) -> some View {
        let uiInsets = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
        return environment(\.turboListContentInset, uiInsets)
    }

    public func turboListInitialPosition(_ position: TurboListInitialScrollPosition) -> some View { environment(\.turboListInitialPosition, position) }
}
