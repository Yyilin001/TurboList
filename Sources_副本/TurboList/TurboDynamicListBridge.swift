//
//  TurboDynamicListBridge.swift
//  TurboList
//
//  Created by yy on 2025/12/25.
//


import SwiftUI
import UIKit

struct TurboDynamicListBridge<Data, Content>: UIViewControllerRepresentable
    where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    let items: Data
    let proxy: TurboListProxy?
    let rowContent: (Data.Element) -> Content

    func makeUIViewController(context: Context) -> UITableViewController {
        let tvc = UITableViewController(style: .plain)
        tvc.tableView.register(TurboDynamicCocoaCell<Content>.self, forCellReuseIdentifier: "TurboCell")
        tvc.tableView.separatorStyle = .none
        tvc.tableView.backgroundColor = .clear

        tvc.tableView.estimatedRowHeight = 60
        tvc.tableView.rowHeight = UITableView.automaticDimension

        tvc.tableView.dataSource = context.coordinator
        tvc.tableView.delegate = context.coordinator
        proxy?.tableView = tvc.tableView
        return tvc
    }

    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
        let tableView = uiViewController.tableView!
        let coordinator = context.coordinator
        let env = context.environment

        if tableView.bounces != env.turboListBounces { tableView.bounces = env.turboListBounces }
        tableView.keyboardDismissMode = env.turboListKeyboardDismissMode
        if tableView.showsVerticalScrollIndicator != env.turboListShowIndicators { tableView.showsVerticalScrollIndicator = env.turboListShowIndicators }
        tableView.contentInset = env.turboListContentInset
        let targetTransform = env.isTurboListReversed ? CGAffineTransform(scaleX: 1, y: -1) : .identity
        if tableView.transform != targetTransform { tableView.transform = targetTransform }

        coordinator.rowContent = rowContent
        coordinator.parentVC = uiViewController
        coordinator.onScroll = env.turboListOnScroll
        coordinator.isReversed = env.isTurboListReversed
        coordinator.insertAnimation = env.turboListInsertAnimation
        coordinator.initialPosition = env.turboListInitialPosition
        coordinator.proxy = proxy

        coordinator.updateItems(items, in: tableView)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var items: Data?
        var rowContent: ((Data.Element) -> Content)?
        var onScroll: ((TurboListScrollInfo) -> Void)?
        var isReversed: Bool = false
        var insertAnimation: UITableView.RowAnimation = .top
        var initialPosition: TurboListInitialScrollPosition?
        var proxy: TurboListProxy?
        weak var parentVC: UIViewController?
        private var hasPerformedInitialScroll = false

        var heightCache: [AnyHashable: CGFloat] = [:]
        private var _sizingController: UIHostingController<Content>?

        func updateItems(_ newItems: Data, in tableView: UITableView) {
            let newCount = newItems.count
            let oldCount = items?.count ?? 0

            if newCount == oldCount && newItems.first?.id == items?.first?.id {
                if proxy?.tableView !== tableView { proxy?.tableView = tableView }
                return
            }

            let isInsertAtTop = (newCount > oldCount) && (newItems.first?.id != items?.first?.id)
            let insertedCount = newCount - oldCount

            var anchorPath: IndexPath?
            var anchorOffsetFromTop: CGFloat = 0

            let currentOffsetY = tableView.contentOffset.y
            let topEdge = -tableView.adjustedContentInset.top
            let isAtBottom = currentOffsetY <= (topEdge + 50)

            if isInsertAtTop && !isAtBottom {
                // 找到屏幕范围内物理最靠上的 Cell
                if let visiblePaths = tableView.indexPathsForVisibleRows, let firstPath = visiblePaths.first {
                    anchorPath = firstPath
                    let rect = tableView.rectForRow(at: firstPath)
                    anchorOffsetFromTop = rect.origin.y - currentOffsetY
                }
            }

            items = newItems
            rebuildMapAsync()

            if oldCount == 0 && newCount > 0 {
                tableView.reloadData()
                performInitialScroll(in: tableView)
                return
            }

            if isInsertAtTop {
                if isAtBottom {
                    tableView.beginUpdates()
                    let indexPaths = (0 ..< insertedCount).map { IndexPath(row: $0, section: 0) }
                    tableView.insertRows(at: indexPaths, with: .top)
                    tableView.endUpdates()

                    if tableView.contentOffset.y > topEdge + 1 {
                        let bottomIndex = IndexPath(row: 0, section: 0)
                        tableView.scrollToRow(at: bottomIndex, at: .top, animated: true)
                    }

                } else if let oldAnchor = anchorPath {
                    UIView.performWithoutAnimation {
                        tableView.reloadData()

                        tableView.layoutIfNeeded()

                        let newAnchorRow = oldAnchor.row + insertedCount
                        let newAnchorPath = IndexPath(row: newAnchorRow, section: oldAnchor.section)

                        let newRect = tableView.rectForRow(at: newAnchorPath)
                        let targetOffset = CGPoint(x: 0, y: newRect.origin.y - anchorOffsetFromTop)
                        tableView.setContentOffset(targetOffset, animated: false)
                    }
                }
            } else {
                UIView.performWithoutAnimation { tableView.reloadData() }
            }
        }

        private func calculateRowHeight(item: Data.Element, width: CGFloat) -> CGFloat {
            guard let contentBlock = rowContent else { return 44 }
            let view = contentBlock(item)
            let controller: UIHostingController<Content>
            if let existing = _sizingController {
                existing.rootView = view
                controller = existing
            } else {
                controller = UIHostingController(rootView: view)
                controller.view.backgroundColor = .clear
                _sizingController = controller
            }
            let size = controller.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
            return size.height
        }

        private func rebuildMapAsync() {
            guard let currentItems = items else { return }
            let count = currentItems.count

            Task { @MainActor in
                var newMap: [AnyHashable: Int] = [:]
                newMap.reserveCapacity(count)

                var currentIndex = currentItems.startIndex
                var intIndex = 0

                while currentIndex != currentItems.endIndex {
                    let item = currentItems[currentIndex]
                    newMap[item.id] = intIndex

                    currentItems.formIndex(after: &currentIndex)
                    intIndex += 1

                    if intIndex % 1000 == 0 {
                        await Task.yield()
                    }
                }

                self.proxy?.idToIndexMap = newMap
                self.proxy?.tableView = self.parentVC?.view as? UITableView
            }
        }

        private func performInitialScroll(in tableView: UITableView) {
            guard let pos = initialPosition, !hasPerformedInitialScroll else { return }
            Task { @MainActor in
                let rowCount = tableView.numberOfRows(inSection: 0)
                guard rowCount > 0 else { return }
                let idx: Int
                let uiPos: UITableView.ScrollPosition
                switch pos {
                case .top: idx = 0; uiPos = .top
                case .centered: idx = rowCount / 2; uiPos = .middle
                case .bottom: idx = rowCount - 1; uiPos = .bottom
                }
                tableView.scrollToRow(at: IndexPath(row: idx, section: 0), at: uiPos, animated: false)
                self.hasPerformedInitialScroll = true
            }
        }

        // MARK: - DataSource & Delegate

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items?.count ?? 0
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TurboCell", for: indexPath) as! TurboDynamicCocoaCell<Content>
            guard let currentItems = items, let rowContent = rowContent, let parentVC = parentVC else { return cell }
            if indexPath.row < currentItems.count {
                let index = currentItems.index(currentItems.startIndex, offsetBy: indexPath.row)
                let item = currentItems[index]
                cell.update(with: rowContent(item), in: parentVC, isReversed: isReversed)
            }
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let currentItems = items, indexPath.row < currentItems.count else { return UITableView.automaticDimension }
            let index = currentItems.index(currentItems.startIndex, offsetBy: indexPath.row)
            let item = currentItems[index]

            if let cached = heightCache[item.id] {
                return cached
            }
            return UITableView.automaticDimension
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let currentItems = items, indexPath.row < currentItems.count else { return }
            let index = currentItems.index(currentItems.startIndex, offsetBy: indexPath.row)
            let item = currentItems[index]
            heightCache[item.id] = cell.bounds.height
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let onScroll = onScroll else { return }
            let info = TurboListScrollInfo(
                contentOffset: scrollView.contentOffset,
                contentSize: scrollView.contentSize,
                bounds: scrollView.bounds,
                insets: scrollView.adjustedContentInset,
                isReversed: isReversed
            )
            onScroll(info)
        }
    }
}
