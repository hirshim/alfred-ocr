.PHONY: build clean install help

WORKFLOW_NAME = Clipboard-OCR
WORKFLOW_FILE = $(WORKFLOW_NAME).alfredworkflow
BUILD_DIR = build
DIST_DIR = dist
SWIFT_SRC = Sources/ocr.swift
BINARY = ocr

build: clean
	@echo "Building $(WORKFLOW_FILE)..."
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(DIST_DIR)
	@swiftc -O -o $(BUILD_DIR)/$(BINARY) $(SWIFT_SRC)
	@echo "Compiled: $(BUILD_DIR)/$(BINARY)"
	@cp info.plist $(BUILD_DIR)/
	@cp icon.png $(BUILD_DIR)/
	@cd $(BUILD_DIR) && zip -r ../$(DIST_DIR)/$(WORKFLOW_FILE) .
	@echo "Created: $(DIST_DIR)/$(WORKFLOW_FILE)"

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)

install: build
	@open $(DIST_DIR)/$(WORKFLOW_FILE)
	@echo "Opening workflow in Alfred..."

help:
	@echo "使用可能なターゲット:"
	@echo "  build   - Swift コンパイル＆ .alfredworkflow パッケージをビルド"
	@echo "  clean   - ビルドディレクトリを削除"
	@echo "  install - ビルドして Alfred にインストール"
	@echo "  help    - このヘルプを表示"
