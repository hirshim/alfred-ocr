# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Alfred Workflow でクリップボードの画像を OCR（光学文字認識）するツール。
Apple Vision Framework を使用し、日本語・英語に対応。
Swift 製のスタンドアロンバイナリとして動作（外部依存なし）。

## Commands

```bash
make build    # Swift コンパイル＆ .alfredworkflow パッケージをビルド
make install  # ビルドして Alfred にインストール
make clean    # ビルドディレクトリを削除
make help     # ヘルプ表示
```

## Architecture

### 処理フロー

```
Alfred で "ocr" 入力
    ↓
Script Filter (./ocr バイナリ実行)
    ↓
OCR 結果をプレビュー表示
    ↓ Enter
Copy to Clipboard + Large Type 同時発火
```

### Project Structure

```
alfred-ocr/
├── Sources/
│   └── ocr.swift          # メイン Swift ソース
├── info.plist              # Alfred Workflow 定義
├── icon.png                # ワークフローアイコン
├── Makefile                # ビルドシステム
├── CLAUDE.md               # このファイル
├── README.md               # プロジェクト説明
├── .gitignore
├── build/                  # ビルド成果物（git 管理外）
│   ├── ocr                 # コンパイル済みバイナリ
│   ├── info.plist
│   └── icon.png
└── dist/                   # パッケージ出力（git 管理外）
    └── Clipboard-OCR.alfredworkflow
```

### Core Components

- `Sources/ocr.swift`: メイン Swift ソース。NSPasteboard → Vision OCR → Alfred JSON 出力
- `info.plist`: Alfred Workflow 定義（Script Filter → Copy to Clipboard + Large Type）
- `Makefile`: ビルドシステム（`swiftc` コンパイル → ZIP パッケージング）

### OCR 処理フロー

1. `NSPasteboard.general` から画像データ取得（`.tiff` → `.png` の順に試行）
2. `NSImage` 経由で `CGImage` に変換
3. `VNImageRequestHandler` + `VNRecognizeTextRequest` で OCR 実行
4. `recognitionLanguages`: `["ja", "en"]`, `recognitionLevel`: `.accurate`
5. 結果を Alfred Script Filter JSON 形式で標準出力

### Alfred Script Filter JSON 出力形式

```json
{
  "items": [{
    "title": "OCR結果の1行目...",
    "subtitle": "Enter: コピー＆Large Type表示 (N行)",
    "arg": "全OCRテキスト",
    "valid": true,
    "text": {
      "copy": "全OCRテキスト",
      "largetype": "全OCRテキスト"
    }
  }]
}
```

## Dependencies

- Swift 6.2+（Xcode Command Line Tools に含まれる）
- macOS 12.0 以降（Vision Framework の日本語 OCR 対応）
- 外部ライブラリ不要

## Alfred Script Filter Configuration

### info.plist の設定

| キー | 値 | 説明 |
|------|-----|------|
| `scriptargtype` | `0` | argv mode |
| `argumenttype` | `1` | Argument Optional（0=Required, 1=Optional, 2=None） |
| `escaping` | `0` | エスケープ無効 |
| `type` | `0` | bash |
| `withspace` | `false` | キーワード後にスペース不要 |
| `script` | `./ocr` | コンパイル済みバイナリを直接実行 |
| `keyword` | `ocr` | トリガーキーワード |

### 重要なポイント

1. **バイナリ直接実行**: Python ではなく Swift コンパイル済みバイナリ `./ocr` を実行
2. **引数不要**: クリップボードから画像を読むため `{query}` は使用しない
3. **`withspace=false`**: `ocr` 入力で即座に Script Filter が起動

## Swift Vision Framework Notes

- `VNImageRequestHandler.perform([request])` は同期実行（非同期パターン不要）
- `recognitionLanguages` の順序が優先度に影響（`ja` を先に指定）
- `.accurate` は `.fast` より高精度だが処理時間が長い
- `CGImage` 変換には `NSImage` の `cgImage(forProposedRect:context:hints:)` を使用
- クリップボード画像は通常 TIFF 形式（macOS スクリーンショット）

## Troubleshooting

- **OCR 結果が空**: クリップボードに画像がない場合、エラーメッセージが表示される
- **日本語が認識されない**: `recognitionLanguages` に `"ja"` が含まれていることを確認
- **バイナリが実行できない**: `make build` でコンパイルエラーがないか確認
- **Alfred に結果が表示されない**: Alfred Preferences のデバッグログで出力を確認
- **ワークフロー更新が反映されない**: Alfred Preferences で既存ワークフローを削除してから再インストール

## TODO

- [x] アイコンを OCR 専用のものに変更する
- [x] 作者名を設定する
- [ ] GitHub Releases に .alfredworkflow を公開する
