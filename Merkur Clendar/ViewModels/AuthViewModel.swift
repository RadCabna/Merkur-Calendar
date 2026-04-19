import SwiftUI

@Observable
final class AuthViewModel {
    var isLoggedIn: Bool = false
    var currentUser: UserAccount? = nil

    private let accountKey  = "merkur_account"
    private let sessionKey  = "merkur_logged_in"

    init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: sessionKey)
        if let data    = UserDefaults.standard.data(forKey: accountKey),
           let decoded = try? JSONDecoder().decode(UserAccount.self, from: data) {
            currentUser = decoded
        }
    }

    var hasAccount: Bool { currentUser != nil }

    func register(username: String, password: String, photoData: Data? = nil) -> Bool {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else { return false }
        let account = UserAccount(username: username, password: password, photoData: photoData)
        if let data = try? JSONEncoder().encode(account) {
            UserDefaults.standard.set(data, forKey: accountKey)
        }
        currentUser = account
        return true
    }

    func login(username: String, password: String) -> Bool {
        guard let user = currentUser,
              user.username == username,
              user.password == password else { return false }
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: sessionKey)
        return true
    }

    func logout() {
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: sessionKey)
    }

    func updatePhoto(_ data: Data?) {
        guard var user = currentUser else { return }
        user.photoData = data
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: accountKey)
        }
    }

    func updateProfile(username: String, password: String) {
        guard var user = currentUser,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else { return }
        user.username = username
        user.password = password
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: accountKey)
        }
    }
}
