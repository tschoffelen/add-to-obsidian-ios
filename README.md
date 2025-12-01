# Add to Obsidian

A simple iOS share extension that lets you quickly save links, articles, and music from any app directly to your Obsidian vault.

## Features

- Share URLs from any iOS app to Obsidian
- Automatically fetches page titles for better context
- Special formatting for Apple Music links
- Appends to your daily note under an "Explore" heading
- Converts content to markdown format automatically

## Requirements

- iOS device
- [Obsidian](https://obsidian.md) app installed
- [Advanced URI plugin](https://github.com/Vinzent03/obsidian-advanced-uri) enabled in Obsidian

## How to Use

1. Open any app (Safari, Apple Music, etc.)
2. Tap the Share button
3. Select "Add to Obsidian"
4. The content will be automatically added to your daily note

## Installation

1. Clone this repository
2. Open `Add to Obsidian.xcodeproj` in Xcode
3. Build and run on your device
4. Enable the share extension in iOS Settings

## Configuration

The extension is configured to:
- Append to your daily note
- Add content under the "Explore" heading
- Format links as markdown list items

You can modify these settings in `ShareExtension/ShareViewController.swift:118`.

## License

MIT
