import SwiftUI

struct ContentView: View {
    @State private var inputMode: InputMode = .text
    @State private var inputText: String = ""
    @State private var isRecording = false
    @State private var showingResult = false
    
    enum InputMode {
        case text
        case voice
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 模式选择
                Picker("输入方式", selection: $inputMode) {
                    Text("文字输入").tag(InputMode.text)
                    Text("语音输入").tag(InputMode.voice)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 输入区域
                if inputMode == .text {
                    TextEditor(text: $inputText)
                        .frame(height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        .padding()
                } else {
                    VStack {
                        Image(systemName: isRecording ? "waveform" : "mic.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(isRecording ? .red : .blue)
                        
                        Button(action: {
                            isRecording.toggle()
                            // TODO: 实现语音录制功能
                        }) {
                            Text(isRecording ? "停止录音" : "开始录音")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(isRecording ? Color.red : Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                // 评估按钮
                Button(action: {
                    // TODO: 实现情绪评估逻辑
                    showingResult = true
                }) {
                    Text("开始评估")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(inputMode == .text ? inputText.isEmpty : !isRecording)
                
                Spacer()
            }
            .navigationTitle("心屿 - 情绪评估")
            .sheet(isPresented: $showingResult) {
                ResultView()
            }
        }
    }
}

struct ResultView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("评估结果")
                .font(.title)
                .padding()
            
            // TODO: 实现评估结果展示
            Text("正在开发中...")
                .foregroundColor(.gray)
            
            Button("关闭") {
                // TODO: 实现关闭逻辑
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}