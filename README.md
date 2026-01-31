# alfred-ocr

クリップボードの画像を OCR でテキストに変換する Alfred ワークフローです。

Apple Vision Framework を使用し、日本語・英語に対応。Swift 製スタンドアロンバイナリで外部依存なし。

## インストール

### 方法1: .alfredworkflow パッケージ（推奨）

1. [Releases](https://github.com/hirshim/alfred-ocr/releases) から最新の `.alfredworkflow` ファイルをダウンロード
2. ダウンロードしたファイルをダブルクリック
3. Alfred が自動的にワークフローをインストール

### 方法2: ソースからビルド

```bash
git clone https://github.com/hirshim/alfred-ocr.git
cd alfred-ocr
make install
```

## 使い方

1. 画像をクリップボードにコピー（スクリーンショット等）
2. Alfred を起動し `ocr` と入力
3. OCR 結果がプレビュー表示される
4. Enter で**クリップボードにコピー＆ Large Type 表示**

## 対応言語

- 日本語
- 英語

## 要件

- macOS 12.0 以降
- Alfred 5 + Powerpack

## 開発

```bash
make build    # Swift コンパイル＆ .alfredworkflow パッケージをビルド
make install  # ビルドして Alfred にインストール
make clean    # ビルドディレクトリを削除
```

## ライセンス

MIT License
