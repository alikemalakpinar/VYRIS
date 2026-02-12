import Foundation
import SwiftData
import UIKit

// MARK: - Social Link Model

struct SocialLink: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var platform: String
    var url: String

    static let platforms = [
        "LinkedIn", "Twitter", "Instagram", "GitHub", "Dribbble",
        "Behance", "YouTube", "TikTok", "Telegram", "WhatsApp",
        "Website", "Other"
    ]

    var iconName: String {
        switch platform.lowercased() {
        case "linkedin": return "link"
        case "twitter": return "at"
        case "instagram": return "camera"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "dribbble": return "circle.grid.3x3"
        case "behance": return "paintbrush"
        case "youtube": return "play.rectangle"
        case "tiktok": return "music.note"
        case "telegram": return "paperplane"
        case "whatsapp": return "phone.bubble"
        case "website": return "globe"
        default: return "link"
        }
    }
}

// MARK: - Custom Theme Data (Persisted per-card)

struct CustomThemeData: Codable, Hashable {
    var backgroundColorHex: String
    var secondaryBackgroundHex: String?
    var textColorHex: String
    var secondaryTextColorHex: String
    var accentColorHex: String
    var strokeColorHex: String
    var strokeWidth: Double
    var layoutStyle: String
    var decorationStyle: String
    var fontStyle: String
    var backgroundStyle: String

    static let `default` = CustomThemeData(
        backgroundColorHex: "F4F1EB",
        secondaryBackgroundHex: nil,
        textColorHex: "1C1C1E",
        secondaryTextColorHex: "6E6E73",
        accentColorHex: "C6A96B",
        strokeColorHex: "D6D2CB",
        strokeWidth: 0.5,
        layoutStyle: "classic",
        decorationStyle: "none",
        fontStyle: "serif",
        backgroundStyle: "solid"
    )
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
    var bio: String
    var location: String
    var socialLinksData: Data
    var themeId: String
    var customThemeJSON: Data?
    var photoData: Data?
    var logoData: Data?
    var coverPhotoData: Data?
    var isCustomTheme: Bool
    var materialVariantRaw: String = "obsidian"
    var tierRaw: String = "standard"
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

    var customTheme: CustomThemeData? {
        get {
            guard let data = customThemeJSON else { return nil }
            return try? JSONDecoder().decode(CustomThemeData.self, from: data)
        }
        set {
            customThemeJSON = try? JSONEncoder().encode(newValue)
        }
    }

    var materialVariant: MaterialVariant {
        get { MaterialVariant(rawValue: materialVariantRaw) ?? .obsidian }
        set { materialVariantRaw = newValue.rawValue }
    }

    var tier: CardTier {
        get { CardTier(rawValue: tierRaw) ?? .standard }
        set { tierRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        fullName: String = "",
        title: String = "",
        company: String = "",
        phone: String = "",
        email: String = "",
        website: String = "",
        bio: String = "",
        location: String = "",
        socialLinks: [SocialLink] = [],
        themeId: String = "ivory_classic",
        customTheme: CustomThemeData? = nil,
        photoData: Data? = nil,
        logoData: Data? = nil,
        coverPhotoData: Data? = nil,
        isCustomTheme: Bool = false,
        materialVariant: MaterialVariant = .obsidian,
        tier: CardTier = .standard
    ) {
        self.id = id
        self.fullName = fullName
        self.title = title
        self.company = company
        self.phone = phone
        self.email = email
        self.website = website
        self.bio = bio
        self.location = location
        self.socialLinksData = (try? JSONEncoder().encode(socialLinks)) ?? Data()
        self.themeId = themeId
        self.customThemeJSON = try? JSONEncoder().encode(customTheme)
        self.photoData = photoData
        self.logoData = logoData
        self.coverPhotoData = coverPhotoData
        self.isCustomTheme = isCustomTheme
        self.materialVariantRaw = materialVariant.rawValue
        self.tierRaw = tier.rawValue
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

    var photoImage: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }

    var logoImage: UIImage? {
        guard let data = logoData else { return nil }
        return UIImage(data: data)
    }

    var coverPhotoImage: UIImage? {
        guard let data = coverPhotoData else { return nil }
        return UIImage(data: data)
    }

    func resolvedTheme() -> CardTheme {
        if isCustomTheme, let custom = customTheme {
            return CardTheme.fromCustom(custom, id: "custom_\(id.uuidString)")
        }
        return ThemeRegistry.theme(for: themeId)
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
            bio: "Leading digital transformation with 20+ years in executive consulting.",
            location: "London, UK",
            socialLinks: [
                SocialLink(platform: "LinkedIn", url: "https://linkedin.com/in/awhitmore"),
                SocialLink(platform: "Twitter", url: "https://x.com/awhitmore")
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
                bio: "Private equity leader focused on European growth markets.",
                location: "Milan, Italy",
                socialLinks: [
                    SocialLink(platform: "LinkedIn", url: "https://linkedin.com/in/smarchetti"),
                    SocialLink(platform: "Instagram", url: "https://instagram.com/smarchetti")
                ],
                themeId: "midnight_gold"
            ),
            BusinessCard(
                fullName: "Kenji Tanaka",
                title: "Principal Architect",
                company: "Tanaka Design Studio",
                phone: "+81 3-1234-5678",
                email: "kenji@tanaka.studio",
                website: "https://tanaka.studio",
                bio: "Award-winning architect blending tradition with innovation.",
                location: "Tokyo, Japan",
                socialLinks: [
                    SocialLink(platform: "Dribbble", url: "https://dribbble.com/ktanaka"),
                    SocialLink(platform: "Behance", url: "https://behance.net/ktanaka")
                ],
                themeId: "neon_mint"
            )
        ]
    }
}
