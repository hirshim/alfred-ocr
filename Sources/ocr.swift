import AppKit
import Vision
import Foundation

// MARK: - Alfred JSON Output

func outputJSON(_ items: [[String: Any]]) -> Never {
    let json: [String: Any] = ["items": items]
    guard let data = try? JSONSerialization.data(withJSONObject: json),
          let str = String(data: data, encoding: .utf8) else {
        print("""
        {"items":[{"title":"JSONシリアライズエラー","subtitle":"内部エラーが発生しました","valid":false}]}
        """)
        exit(1)
    }
    print(str)
    exit(0)
}

func outputError(_ message: String) -> Never {
    outputJSON([
        [
            "title": message,
            "subtitle": "クリップボードに画像をコピーしてから再実行してください",
            "valid": false,
            "icon": ["path": "icon.png"]
        ]
    ])
}

// MARK: - Clipboard Image

let pasteboard = NSPasteboard.general
guard let imageData = pasteboard.data(forType: .tiff)
    ?? pasteboard.data(forType: .png) else {
    outputError("クリップボードに画像がありません")
}

guard let nsImage = NSImage(data: imageData),
      let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    outputError("画像の変換に失敗しました")
}

// MARK: - Vision OCR

let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
let request = VNRecognizeTextRequest()
request.recognitionLanguages = ["ja", "en"]
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true

do {
    try requestHandler.perform([request])
} catch {
    outputError("OCR処理に失敗しました: \(error.localizedDescription)")
}

guard let observations = request.results, !observations.isEmpty else {
    outputError("テキストが検出されませんでした")
}

let recognizedText = observations
    .compactMap { $0.topCandidates(1).first?.string }
    .joined(separator: "\n")

// MARK: - Build Alfred JSON

let lines = recognizedText.components(separatedBy: "\n")
let firstLine = lines.first ?? ""
let titleText = firstLine.count > 80
    ? String(firstLine.prefix(80)) + "..."
    : firstLine
let lineCount = lines.count

let item: [String: Any] = [
    "title": titleText,
    "subtitle": "Enter: コピー＆Large Type表示 (\(lineCount)行)",
    "arg": recognizedText,
    "valid": true,
    "text": [
        "copy": recognizedText,
        "largetype": recognizedText
    ]
]

outputJSON([item])
