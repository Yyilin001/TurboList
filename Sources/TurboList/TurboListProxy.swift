//
//  TurboListProxy.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//


import SwiftUI
import UIKit

@MainActor
public class TurboListProxy {
     weak var tableView: UITableView?
     var idToIndexMap: [AnyHashable: Int] = [:]
    
    public init(){ }
    public func scrollToIndex(_ index: Int, anchor: TurboListScrollPosition = .bottom, animated: Bool = true) {
        guard let tv = tableView else { return }
        let rowCount = tv.numberOfRows(inSection: 0)
        guard index >= 0, index < rowCount else { return }
        tv.scrollToRow(at: IndexPath(row: index, section: 0), at: anchor.uiKitPosition, animated: animated)
    }

    public func scrollToID(_ id: AnyHashable, anchor: TurboListScrollPosition = .bottom, animated: Bool = true) {
        guard let index = idToIndexMap[id] else {
            print("TurboList: ScrollToID failed, ID not found")
            return
        }
        scrollToIndex(index, anchor: anchor, animated: animated)
    }
}
