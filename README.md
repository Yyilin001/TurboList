
# TurboList 

**TurboList** 是一个专为 SwiftUI 打造的高性能列表组件，底层基于 `UITableView` 封装。它专为 **聊天应用 (Chat Interfaces)** 和 **海量数据流** 场景设计，完美解决了 SwiftUI 原生 `List` 和 `ScrollView` 在处理翻转列表（Reversed List）和双向无限滚动时的性能瓶颈与跳动问题。

## ✨ 核心特性

* **极致性能**: 支持千万级数据源。
* **翻转列表支持**: 提供 `.turboListReversed(true)`，专为聊天场景设计，无需在处理视图翻转。
* **高度自适应**: 支持动态高度。

## 📦 引入方式 (Installation)

```swift
dependencies: [
    .package(url: "https://github.com/Yyilin001/TurboList.git", from: "1.0.0")
]

```

### 聊天场景完整示例 (Chat Scenario)

```swift

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = (1 ... 100).map { ChatMessage(text: "Old \($0)", isMe: false) }

    @State private var inputText: String = ""
    let scrollProxy = TurboListProxy()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TurboList(messages, proxy: scrollProxy) { msg in
                Text(msg.text)
                    .padding(12)
                    .background(msg.isMe ? Color.blue : Color(UIColor.systemGray5))
                    .foregroundColor(msg.isMe ? .white : .primary)
                    .cornerRadius(12)
                    .frame(
                        maxWidth: .infinity,
                        alignment: msg.isMe ? .trailing : .leading
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .id(msg.id)
            }
            .turboListReversed(true)
            .turboListKeyboardDismissMode(.interactive)
            .turboListInitialPosition(.top)
            .onTurboListScroll { info in
                if info.distanceToTop < 200 {
                    Task { @MainActor in
                        loadMoreHistory()
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }

            HStack {
                TextField(
                    "输入... (Total: \(messages.count))",
                    text: $inputText
                )
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)

                Button("发送") {
                    sendMessage()
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }

        let newMsg = ChatMessage(text: inputText, isMe: true)
        inputText = ""

        messages.insert(newMsg, at: 0)

        Task { @MainActor in
            scrollProxy.scrollToIndex(0, anchor: .bottom, animated: true)
        }
    }

    private func loadMoreHistory() {
        let more = (1 ... 20).map {
            ChatMessage(text: "Old more \($0)", isMe: false)
        }

        messages.append(contentsOf: more)
    }
}


```

## ⚙️ API 文档 (Modifiers)

TurboList 提供了丰富的一系列修饰符来配置列表行为：

| 修饰符 (Modifier) | 参数类型 | 说明 | 默认值 |
| --- | --- | --- | --- |
| `.turboListReversed(_:)` | `Bool` | 是否翻转列表）。开启后 Index 0 位于底部。 | `false` |
| `.onTurboListScroll(_:)` | `(TurboListScrollInfo) -> Void` | 滚动回调，包含偏移量、距离顶部/底部距离等信息。 | `nil` |
| `.turboListBounces(_:)` | `Bool` | 是否开启弹性效果。 | `true` |
| `.turboListShowIndicators(_:)` | `Bool` | 是否显示滚动条。 | `true` |
| `.turboListKeyboardDismissMode(_:)` | `UIScrollView.KeyboardDismissMode` | 键盘交互模式 (`.onDrag`, `.interactive` 等)。 | `.onDrag` |
| `.turboListContentInset(_:)` | `EdgeInsets` | 列表的内边距。 | `.zero` |
| `.turboListInitialPosition(_:)` | `TurboListInitialScrollPosition` | 初始滚动位置 (`.top`, `.bottom`, `.centered`)。 | `nil` |

## 🕹 控制器 (TurboListProxy)

使用 `TurboListProxy` 进行编程式滚动：

```swift
let proxy = TurboListProxy()

// 绑定到 View
TurboList(..., proxy: proxy)

// 滚动到指定 Index
proxy.scrollToIndex(0, anchor: .bottom, animated: true)

// 滚动到指定 ID (需要数据源遵循 Identifiable)
proxy.scrollToID(someUUID, anchor: .top, animated: true)

```

## 📝 License

本项目基于 MIT 许可证开源。

```text
MIT License

Copyright (c) 2024 TurboList Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
