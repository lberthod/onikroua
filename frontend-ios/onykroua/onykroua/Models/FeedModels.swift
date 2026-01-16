import Foundation

public enum FeedItemType: String, CaseIterable {
    case vocabulary
    case conjugation
    case expression
    case culture
    case quiz
}

public struct FeedItem: Identifiable {
    public let id: String
    public let type: FeedItemType
    public let title: String
    public let content: String
    public let translation: String
    public let example: String?
    public let audioText: String?
    public var liked: Bool
    public var bookmarked: Bool
    public var likeCount: Int
    
    public init(id: String = UUID().uuidString,
         type: FeedItemType,
         title: String,
         content: String,
         translation: String,
         example: String? = nil,
         audioText: String? = nil,
         liked: Bool = false,
         bookmarked: Bool = false,
         likeCount: Int = Int.random(in: 10...500)) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.translation = translation
        self.example = example
        self.audioText = audioText
        self.liked = liked
        self.bookmarked = bookmarked
        self.likeCount = likeCount
    }
}
