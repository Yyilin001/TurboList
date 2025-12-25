//
//  TurboListReversedKey.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//

import SwiftUI
struct TurboListReversedKey: EnvironmentKey { static let defaultValue: Bool = false }
struct TurboListOnScrollKey: EnvironmentKey {
    static let defaultValue: (@Sendable (TurboListScrollInfo) -> Void)? = nil
}

struct TurboListBouncesKey: EnvironmentKey { static let defaultValue: Bool = true }
struct TurboListInsertAnimationKey: EnvironmentKey { static let defaultValue: UITableView.RowAnimation = .top }
struct TurboListKeyboardDismissModeKey: EnvironmentKey { static let defaultValue: UIScrollView.KeyboardDismissMode = .onDrag }
struct TurboListShowIndicatorsKey: EnvironmentKey { static let defaultValue: Bool = true }
struct TurboListContentInsetKey: EnvironmentKey { static let defaultValue: UIEdgeInsets = .zero }
struct TurboListInitialPositionKey: EnvironmentKey { static let defaultValue: TurboListInitialScrollPosition? = nil }

extension EnvironmentValues {
    var isTurboListReversed: Bool { get { self[TurboListReversedKey.self] } set { self[TurboListReversedKey.self] = newValue } }

    var turboListOnScroll: (@Sendable (TurboListScrollInfo) -> Void)? {
        get { self[TurboListOnScrollKey.self] }
        set { self[TurboListOnScrollKey.self] = newValue }
    }

    var turboListBounces: Bool { get { self[TurboListBouncesKey.self] } set { self[TurboListBouncesKey.self] = newValue } }
    var turboListInsertAnimation: UITableView.RowAnimation { get { self[TurboListInsertAnimationKey.self] } set { self[TurboListInsertAnimationKey.self] = newValue } }
    var turboListKeyboardDismissMode: UIScrollView.KeyboardDismissMode { get { self[TurboListKeyboardDismissModeKey.self] } set { self[TurboListKeyboardDismissModeKey.self] = newValue } }
    var turboListShowIndicators: Bool { get { self[TurboListShowIndicatorsKey.self] } set { self[TurboListShowIndicatorsKey.self] = newValue } }
    var turboListContentInset: UIEdgeInsets { get { self[TurboListContentInsetKey.self] } set { self[TurboListContentInsetKey.self] = newValue } }
    var turboListInitialPosition: TurboListInitialScrollPosition? { get { self[TurboListInitialPositionKey.self] } set { self[TurboListInitialPositionKey.self] = newValue } }
}
