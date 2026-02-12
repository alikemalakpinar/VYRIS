import Foundation

extension String {

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
        var lines: [String] = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "FN:\(fullName)",
            "N:\(vCardNameComponents(from: fullName))"
        ]

        if let title, !title.isEmpty {
            lines.append("TITLE:\(title)")
        }

        if let company, !company.isEmpty {
            lines.append("ORG:\(company)")
        }

        if let phone, !phone.isEmpty {
            lines.append("TEL;TYPE=WORK,VOICE:\(phone)")
        }

        if let email, !email.isEmpty {
            lines.append("EMAIL;TYPE=WORK:\(email)")
        }

        if let website, !website.isEmpty {
            lines.append("URL:\(website)")
        }

        for link in socialLinks {
            lines.append("X-SOCIALPROFILE;TYPE=\(link.platform):\(link.url)")
        }

        lines.append("END:VCARD")
        return lines.joined(separator: "\r\n")
    }

    private static func vCardNameComponents(from fullName: String) -> String {
        let parts = fullName.split(separator: " ", maxSplits: 1)
        if parts.count == 2 {
            return "\(parts[1]);\(parts[0]);;;"
        }
        return "\(fullName);;;;"
    }
}
