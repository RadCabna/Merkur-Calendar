import Foundation

struct UserAccount: Codable {
    var username: String
    var password: String
    var photoData: Data?
}
