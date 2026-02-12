import Foundation

extension String {

    // MARK: - vCard Escaping (RFC 6350 §3.4)

    /// Escape special characters for vCard property values.
    /// Backslash, newline, semicolon, and comma must be escaped.
    var vCardEscaped: String {
        self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
    }

    // MARK: - vCard Generation

    /// Generate a vCard 3.0 string from card fields.
    static func vCard(
        fullName: String,
        title: String? = nil,
        company: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        socialLinks: [SocialLink] = []
    ) -> String {
        let escapedName = fullName.vCardEscaped
        var lines: [String] = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "FN:\(escapedName)",
            "N:\(vCardNameComponents(from: fullName))"
        ]

        if let title, !title.isEmpty {
            lines.append("TITLE:\(title.vCardEscaped)")
        }

        if let company, !company.isEmpty {
            lines.append("ORG:\(company.vCardEscaped)")
        }

        if let phone, !phone.isEmpty {
            lines.append("TEL;TYPE=WORK,VOICE:\(phone.vCardEscaped)")
        }

        if let email, !email.isEmpty {
            lines.append("EMAIL;TYPE=WORK:\(email.vCardEscaped)")
        }

        if let website, !website.isEmpty {
            lines.append("URL:\(website.vCardEscaped)")
        }

        for link in socialLinks {
            lines.append("X-SOCIALPROFILE;TYPE=\(link.platform.vCardEscaped):\(link.url.vCardEscaped)")
        }

        lines.append("END:VCARD")
        return lines.joined(separator: "\r\n")
    }

    private static func vCardNameComponents(from fullName: String) -> String {
        let parts = fullName.split(separator: " ", maxSplits: 1)
        if parts.count == 2 {
            return "\(String(parts[1]).vCardEscaped);\(String(parts[0]).vCardEscaped);;;"
        }
        return "\(fullName.vCardEscaped);;;;"
    }

    // MARK: - vCard Escaping Validation

    /// Validates that a string is properly vCard-escaped.
    static func validateVCardEscaping(_ input: String) -> Bool {
        let escaped = input.vCardEscaped
        // Backslashes should only appear as escape sequences
        let backslashPattern = try? NSRegularExpression(pattern: #"\\[^\\n;,]"#)
        let range = NSRange(escaped.startIndex..., in: escaped)
        let unexpectedEscapes = backslashPattern?.numberOfMatches(in: escaped, range: range) ?? 0
        // Raw semicolons, commas, and newlines should not remain
        let hasRawSemicolon = escaped.contains(";") && !escaped.contains("\\;")
        let hasRawNewline = escaped.contains("\n")
        return unexpectedEscapes == 0 && !hasRawSemicolon && !hasRawNewline
    }
}
