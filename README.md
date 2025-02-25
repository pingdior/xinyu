
# 心语 (XinYu) - 情绪健康智能助手 (V1.0 MVP)

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**项目简介**

心屿 (XinYu) 是一款注重隐私保护、本地部署的情绪健康智能评估与管理 App，旨在为用户提供快速、便捷、私密的情绪状态洞察和初步建议。V1.0 MVP 版本专注于核心的情绪状态快速评估功能，所有数据本地存储，极致保护用户隐私。

**核心特性 (V1.0 MVP)**

*   **情绪状态快速评估:**  支持语音和文本两种输入方式，用户可快速进行情绪自测。
*   **本地AI模型驱动:**  内置轻量级 NLP 和情感分析模型，无需联网即可进行评估。
*   **个性化评估报告:**  生成简洁明了的评估报告，包含情绪维度分析和初步建议。
*   **极致隐私保护:**  所有用户数据本地存储在设备上，无任何数据上传云端。
*   **本地部署:**  App 可在 iPad Pro 等设备上本地部署运行，无需网络连接。
*   **简洁易用:**  界面简洁直观，操作流程简单，用户快速上手。

**技术栈**

*   **开发语言:** Swift
*   **UI框架:** SwiftUI
*   **本地AI模型:** Core ML (或 Swift 实现的轻量级模型)
*   **本地数据存储:** Core Data 或 SQLite

**开发环境**

*   macOS (Apple M2 或更高处理器)
*   Xcode 最新版本

**本地部署设备**

*   iPad Pro 2018 (或更高版本)，iPadOS 12 或更高版本

**快速开始 (开发)**

1.  **克隆项目:**
    ```bash
    git clone [https://github.com/pingdior/xinyu.git]
    cd XinYu-App
    ```
2.  **打开 Xcode 工程:**
    打开 `XinYu.xcodeproj` 或 `XinYu.xcworkspace` 文件。
3.  **选择运行设备:**  在 Xcode 中选择你的 iPad Pro 2018 设备作为运行目标。
4.  **编译并运行:**  点击 "Play" 按钮 (或 Command + R) 编译并运行 App 到你的 iPad Pro 上。

**项目结构**
```Markdown
XinYu-App/
├── XinYu/ # Xcode 工程文件夹
│ ├── Assets.xcassets/ # 图片资源
│ ├── ContentView.swift # 主界面
│ ├── ... # 其他 SwiftUI 视图文件
│ ├── Models/ # 数据模型 (User, Assessment)
│ ├── ViewModels/ # 视图模型
│ ├── AI/ # 本地 AI 模型相关代码 (Core ML 模型文件，模型加载和调用代码)
│ ├── Data/ # 本地数据存储相关代码 (Core Data 或 SQLite 封装)
│ ├── Utils/ # 工具类
│ ├── XinYuApp.swift # App 入口
│ └── ...
├── README.md # 项目 README 文件
├── LICENSE # 开源许可证 (MIT)
└── ...
```

**未来计划 (V2.0 展望)**

*   **动态情绪追踪功能**
*   **初步生理指标融合 (iPad Pro 摄像头)**
*   **个性化建议优化**

**贡献**

欢迎任何形式的贡献，包括但不限于代码贡献、Bug 报告、功能建议、文档完善等。请提交 Issue 或 Pull Request。

**许可证**

本项目使用 MIT 开源许可证，详情请见 `LICENSE` 文件。

**联系方式**

[woodgaya@gmail.com ]
[https://github.com/pingdior]

---
**感谢您的关注和使用！**
