import SwiftUI

@Observable
final class MainTabViewModel {
    var selectedTab: Tab = .home
    var showCreate: Bool = false
    var showEventList: Bool = false
}
