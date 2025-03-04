# XinYu 心屿

XinYu(心屿)是一款基于人工智能的情感分析应用，能够通过文本和语音识别用户的情感状态，提供情绪评估和建议。

## 功能特点

- 支持文本输入情感分析
- 支持语音输入情感分析
- 多维度情感评估（喜悦、悲伤、愤怒、恐惧、焦虑、平静）
- 情感分析可视化展示
- 本地优先的数据处理，保护用户隐私

## 技术架构

### 情感分析系统

XinYu采用多层次的情感分析系统，结合规则引擎和机器学习模型：

#### 1. 数据输入层
- 文本直接输入
- 语音通过Speech框架转换为文本

#### 2. 情感分析核心层
- **规则引擎**：基于关键词匹配的轻量级分析器
- **机器学习模型**：基于CoreML的情感分类器
- **混合增强**：结合规则引擎和ML模型优势，提高分析准确性

#### 3. 结果处理层
- 情感多维度评分
- 积极/消极指数计算
- 情感可视化展示

### 模型实现

XinYu的情感分析采用三种核心模型：

1. **NativeEmotionClassifier**：规则引擎，基于中文情感关键词匹配
2. **SimpleEmotionMLClassifier**：轻量级CoreML模型，适用于基础情感分类
3. **CreateMLEmotionClassifier**：高级情感分析模型，使用CreateML训练

系统设计具有故障弹性，当ML模型不可用时自动回退到规则引擎。

## 安装与使用

### 系统要求
- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

### 安装步骤
1. 克隆项目到本地
   ```
   git clone https://github.com/yourusername/XinYu.git
   ```
2. 打开XinYu.xcodeproj
3. 选择目标设备（真机或模拟器）
4. 点击运行按钮或按Cmd+R

### 使用方法
1. 在输入框中输入文本或点击录音按钮进行语音输入
2. 点击"分析情感"按钮
3. 查看分析结果和情感图表

## 开发者指南

### 添加新的情感关键词
在`NativeEmotionClassifier.swift`中添加新的关键词：

```swift
private let joyKeywords = ["开心", "高兴", ... 添加新词]
```


### 训练新的ML模型
使用`create_emotion_model.py`生成数据集，然后使用CreateML应用训练新模型。

### 调整混合策略
在`SimpleEmotionMLClassifier.swift`中修改ML和规则引擎的权重：

```swift
// 默认是70% ML, 30% 规则
scores.joyScore = scores.joyScore 0.7 + ruleBasedScores.joyScore 0.3
```

## 项目结构
- **Models/**: 数据模型和ML模型
- **Views/**: SwiftUI视图
- **ViewModels/**: 视图模型
- **Managers/**: 管理类（语音识别、CoreData等）
- **Services/**: 网络服务和API处理

## **未来计划 (V2.0 展望)**

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

**感谢您的关注和使用！**
