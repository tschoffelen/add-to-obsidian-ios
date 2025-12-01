//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Thomas Schoffelen on 01/12/2025.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
   override func viewDidLoad() {
       super.viewDidLoad()
       handleSharedContent()
   }

   private func handleSharedContent() {
       guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
             let itemProviders = extensionItem.attachments else {
           closeExtension()
           return
       }

       // Try to get URL first
       if let urlProvider = itemProviders.first(where: {
$0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
           urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self]
(item, error) in
               if let url = item as? URL {
                   self?.processURL(url, title: extensionItem.attributedContentText?.string)
               } else {
                   self?.closeExtension()
               }
           }
       }
       // Try to get text
       else if let textProvider = itemProviders.first(where: {
$0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
           textProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self]
(item, error) in
               if let text = item as? String {
                   self?.processText(text)
               } else {
                   self?.closeExtension()
               }
           }
       }
       // Try to get plain text (fallback)
       else if let plainTextProvider = itemProviders.first(where: {
$0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
           plainTextProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) {
[weak self] (item, error) in
               if let text = item as? String {
                   self?.processText(text)
               } else {
                   self?.closeExtension()
               }
           }
       } else {
           closeExtension()
       }
   }

   private func processURL(_ url: URL, title: String?) {
       // If we have a title, use it directly
       if let title = title, !title.isEmpty {
           createMarkdownAndOpen(url: url, title: title)
           return
       }

       // Otherwise, try to fetch the title from the webpage
       WebPageTitleFetcher.fetchTitle(from: url) { [weak self] fetchedTitle in
           let finalTitle = fetchedTitle ?? url.host ?? "Link"
           self?.createMarkdownAndOpen(url: url, title: finalTitle)
       }
   }

   private func createMarkdownAndOpen(url: URL, title: String) {
       let urlString = url.absoluteString.replacingOccurrences(of: ")", with: "\\)")

       // Check if it's an Apple Music URL
       let isAppleMusic = urlString.contains("music.apple.com") ||
urlString.contains("itunes.apple.com")

       let markdown: String
       if isAppleMusic {
           markdown = "- Listening to 🎧 [\(title.replacingOccurrences(of: " – Apple Music", with: ""))](\(urlString))"
       } else {
           markdown = "- [\(title)](\(urlString))"
       }

       print("Markdown string: \(markdown)")

       openObsidian(with: markdown)
   }

   private func processText(_ text: String) {
       // Check if the text is a URL
       if let url = URL(string: text), url.scheme != nil {
           processURL(url, title: nil)
       } else {
           // If it's just text, create a simple markdown entry
           let markdown = "- \(text)"
           openObsidian(with: markdown)
       }
   }

   private func openObsidian(with content: String) {
       // URL encode the content
       guard let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .nonBaseCharacters) else {
           closeExtension()
           return
       }

       // Create the Obsidian URL
       let obsidianURLString =
"obsidian://adv-uri?daily=true&mode=append&heading=Explore&data=\(encodedContent)"
       
       print("URL: \(obsidianURLString)")

       guard let obsidianURL = URL(string: obsidianURLString) else {
           closeExtension()
           return
       }

       // Open the URL
       DispatchQueue.main.async { [weak self] in
           guard let self = self else { return }

           var responder = self as UIResponder?

           while responder != nil {
               if let application = responder as? UIApplication {
                   application.open(obsidianURL)
               }
               responder = responder!.next
           }

           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               self.closeExtension()
           }
       }
   }

   private func closeExtension() {
       DispatchQueue.main.async { [weak self] in
           self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
       }
   }
}

