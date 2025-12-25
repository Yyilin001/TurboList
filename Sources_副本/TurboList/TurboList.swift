// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import UIKit

public struct TurboList<Data, Content>: View
    where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    let items: Data
    let proxy: TurboListProxy?
    let rowContent: (Data.Element) -> Content

    public init(_ items: Data, proxy: TurboListProxy? = nil, @ViewBuilder rowContent: @escaping (Data.Element) -> Content) {
        self.items = items
        self.proxy = proxy
        self.rowContent = rowContent
    }

    public var body: some View {
        TurboDynamicListBridge(items: items, proxy: proxy, rowContent: rowContent)
    }
}
