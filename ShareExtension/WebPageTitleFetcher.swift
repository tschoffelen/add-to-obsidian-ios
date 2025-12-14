//
//  WebPageTitleFetcher.swift
//  ShareExtension
//
//  Created by Thomas Schoffelen on 01/12/2025.
//

import Foundation

class WebPageTitleFetcher {
    static func fetchTitle(from url: URL, completion: @escaping (String?) -> Void) {
        // Don't try to fetch titles for non-HTTP(S) URLs
        guard url.scheme == "http" || url.scheme == "https" else {
            completion(nil)
            return
        }

        // Check if this is a YouTube URL and use oEmbed API
        if isYouTubeURL(url) {
            fetchYouTubeTitle(from: url, completion: completion)
            return
        }

        // Create a URL request with a timeout
        var request = URLRequest(url: url, timeoutInterval: 5.0)
        request.httpMethod = "GET"
        // Set a user agent to avoid being blocked
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // If there's an error or no data, fail gracefully
            guard error == nil,
                  let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }

            // Try to extract the title from the HTML
            let title = extractTitle(from: html)
            completion(title)
        }

        task.resume()
    }

    private static func isYouTubeURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        return urlString.contains("youtube.com") ||
               urlString.contains("youtu.be") ||
               urlString.contains("m.youtube.com")
    }

    private static func fetchYouTubeTitle(from url: URL, completion: @escaping (String?) -> Void) {
        // Use YouTube's oEmbed API to get the video title
        guard let encodedURL = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let oembedURL = URL(string: "https://www.youtube.com/oembed?url=\(encodedURL)&format=json") else {
            completion(nil)
            return
        }

        let request = URLRequest(url: oembedURL, timeoutInterval: 5.0)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let title = json["title"] as? String else {
                completion(nil)
                return
            }

            completion(title)
        }

        task.resume()
    }

    private static func extractTitle(from html: String) -> String? {
        // Try multiple patterns to find the title

        // Pattern 1: Standard <title> tag
        if let titleRange = html.range(of: "<title[^>]*>", options: [.regularExpression, .caseInsensitive]) {
            let startIndex = titleRange.upperBound
            if let endRange = html[startIndex...].range(of: "</title>", options: .caseInsensitive) {
                let title = String(html[startIndex..<endRange.lowerBound])
                let cleaned = cleanTitle(title)
                if !cleaned.isEmpty {
                    return cleaned
                }
            }
        }

        // Pattern 2: Open Graph title
        if let ogTitle = extractMetaProperty(from: html, property: "og:title") {
            return ogTitle
        }

        // Pattern 3: Twitter title
        if let twitterTitle = extractMetaProperty(from: html, property: "twitter:title") {
            return twitterTitle
        }

        return nil
    }

    private static func extractMetaProperty(from html: String, property: String) -> String? {
        // Look for meta tags with property or name attributes
        let patterns = [
            "<meta[^>]*property=[\"']\(property)[\"'][^>]*content=[\"']([^\"']*)[\"'][^>]*>",
            "<meta[^>]*content=[\"']([^\"']*)[\"'][^>]*property=[\"']\(property)[\"'][^>]*>",
            "<meta[^>]*name=[\"']\(property)[\"'][^>]*content=[\"']([^\"']*)[\"'][^>]*>",
            "<meta[^>]*content=[\"']([^\"']*)[\"'][^>]*name=[\"']\(property)[\"'][^>]*>"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let nsString = html as NSString
                if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) {
                    if match.numberOfRanges > 1 {
                        let titleRange = match.range(at: 1)
                        if titleRange.location != NSNotFound {
                            let title = nsString.substring(with: titleRange)
                            let cleaned = cleanTitle(title)
                            if !cleaned.isEmpty {
                                return cleaned
                            }
                        }
                    }
                }
            }
        }

        return nil
    }

    private static func cleanTitle(_ title: String) -> String {
        // Decode HTML entities and trim whitespace
        var cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")

        // Remove excessive whitespace
        cleaned = cleaned.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return cleaned
    }
}
