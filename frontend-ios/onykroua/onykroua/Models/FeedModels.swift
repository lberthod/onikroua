import Foundation

enum FeedItemType: String, CaseIterable {
    case vocabulary
    case conjugation
    case expression
    case culture
    case quiz
}

struct FeedItem: Identifiable {
    let id: String
    let type: FeedItemType
    let title: String
    let content: String
    let translation: String
    let example: String?
    let audioText: String?
    var liked: Bool
    var bookmarked: Bool
    var likeCount: Int
    
    init(id: String = UUID().uuidString,
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
