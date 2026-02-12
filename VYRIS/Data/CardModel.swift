import Foundation
import SwiftData

// MARK: - Social Link Model

struct SocialLink: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var platform: String
    var url: String

    static let platforms = [
        "LinkedIn", "Twitter", "Instagram", "GitHub", "Website", "Other"
    ]
}

// MARK: - Card Model (SwiftData)

@Model
final class BusinessCard {
    var id: UUID
    var fullName: String
    var title: String
    var company: String
    var phone: String
    var email: String
    var website: String
    var socialLinksData: Data
    var themeId: String
    var photoData: Data?
    var createdAt: Date
    var updatedAt: Date

    var socialLinks: [SocialLink] {
        get {
            (try? JSONDecoder().decode([SocialLink].self, from: socialLinksData)) ?? []
        }
        set {
            socialLinksData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        id: UUID = UUID(),
        fullName: String = "",
        title: String = "",
        company: String = "",
        phone: String = "",
        email: String = "",
        website: String = "",
        socialLinks: [SocialLink] = [],
        themeId: String = "ivory_classic",
        photoData: Data? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.title = title
        self.company = company
        self.phone = phone
        self.email = email
        self.website = website
        self.socialLinksData = (try? JSONEncoder().encode(socialLinks)) ?? Data()
        self.themeId = themeId
        self.photoData = photoData
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var vCardString: String {
        .vCard(
            fullName: fullName,
            title: title.isEmpty ? nil : title,
            company: company.isEmpty ? nil : company,
            phone: phone.isEmpty ? nil : phone,
            email: email.isEmpty ? nil : email,
            website: website.isEmpty ? nil : website,
            socialLinks: socialLinks
        )
    }
}

// MARK: - Sample Data

extension BusinessCard {

    static var sample: BusinessCard {
        BusinessCard(
            fullName: "Alexander Whitmore",
            title: "Chief Executive Officer",
            company: "Whitmore & Associates",
            phone: "+1 (555) 012-3456",
            email: "a.whitmore@whitmore.com",
            website: "https://whitmore.com",
            socialLinks: [
                SocialLink(platform: "LinkedIn", url: "https://linkedin.com/in/awhitmore")
            ],
            themeId: "ivory_classic"
        )
    }

    static var sampleCollection: [BusinessCard] {
        [
            sample,
            BusinessCard(
                fullName: "Sofia Marchetti",
                title: "Managing Director",
                company: "Marchetti Capital",
                phone: "+39 02 1234 5678",
                email: "sofia@marchetti.it",
                website: "https://marchetti.it",
                themeId: "midnight_gold"
            ),
            BusinessCard(
                fullName: "Kenji Tanaka",
                title: "Principal Architect",
                company: "Tanaka Design Studio",
                phone: "+81 3-1234-5678",
                email: "kenji@tanaka.studio",
                website: "https://tanaka.studio",
                themeId: "slate_silver"
            )
        ]
    }
}
