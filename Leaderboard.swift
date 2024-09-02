import Foundation
import GameKit
import SwiftUI

enum Leaderboard: String {
    var id: String { rawValue }

    case overall = "overall_leaderboard"

    case level3 = "level_3_leaderboard"
    case level4 = "level_4_leaderboard"
    case level5 = "level_5_leaderboard"
    case level6 = "level_6_leaderboard"
    case level7 = "level_7_leaderboard"
    case level8 = "level_8_leaderboard"
    case level9 = "level_9_leaderboard"
    case level10 = "level_10_leaderboard"
    case level11 = "level_11_leaderboard"
    case level12 = "level_12_leaderboard"

    static func level(_ level: Int) -> Self {
        Leaderboard(rawValue: "level_\(level)_leaderboard")!
    }

    static func reportTime( _ time: Double, level: Int) {
        let score = Int(ceil(100 * time))
        GKLeaderboard.submitScore(
            score,
            context: level,
            player: GKLocalPlayer.local,
            leaderboardIDs: [Leaderboard.level(level).id],
            completionHandler: { error in
                if let error {
                    print("Failed to report level \(level) score \(score) to gamecenter: \(error)")
                } else {
                    print("Reported level \(level) score \(score) to gamecenter")
                }
            }
        )
    }

    static func reportTotalScore(_ score: Int) {
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [Leaderboard.overall.id],
            completionHandler: { error in
                if let error {
                    print("Failed to report overall score \(score) to gamecenter: \(error)")
                } else {
                    print("Reported overall score \(score) to gamecenter")
                }
            }
        )
    }
}

//extension View {
//    func gameCenter(
//        show: Binding<Bool>,
//        leaderboard: Leaderboard
//    ) -> some View {
//        gameCenter(
//            isPresented: show,
//            launchOption: .leaderBoardID(
//                id: Leaderboard.overall.id,
//                playerScope: .global,
//                timeScope: .allTime
//            )
//        )
//    }
//}

extension View {
    public func gameCenter(
        leaderboard: Binding<Leaderboard?>,
    ) -> some View {
        modifier(GameCenterModifier(
            isPresented: isPresented,
            launchOption: launchOption))
    }
}

private struct GameCenterModifier: ViewModifier {
    @Binding var leaderboard: Leaderboard?

    @StateObject var controller = GameCenterController()

    func body(content: Content) -> some View {
        content
//        content.onChange(of: isPresented) { isPresented in
//            if isPresented {
//                GameCenterController.shared.present(launchOption: launchOption)
//                GameCenterController.shared.onDidFinish = onDidFinish
//            }
//        }
    }

    func onDidFinish() {
        leaderboard = nil
    }
}

private class GameCenterController:
    NSObject,
    GKGameCenterControllerDelegate,
    ObservableObject
{
    static let shared = GameCenterController()
    var onDidFinish: (() -> ())?
    var gamecenter: GKGameCenterViewController?

    func present(launchOption: GameCenterLaunchOption) {
        let gamecenter = createGameCenter(launchOption: launchOption)
        self.gamecenter = gamecenter
        gamecenter.gameCenterDelegate = self
        GameCenterController.shared.onDidFinish = onDidFinish
#if os(iOS)
        UIApplication.shared
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .present(gamecenter, animated: true)
#elseif os(macOS)
        NSApplication.shared
            .keyWindow?
            .contentViewController?
            .presentAsSheet(gamecenter)
#endif
    }

    func gameCenterViewControllerDidFinish(
        _ gameCenterViewController: GKGameCenterViewController
    ) {
#if os(iOS)
        let rootvc = UIApplication.shared
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController

        rootvc?.dismiss(animated: true)
#elseif os(macOS)
        NSApplication.shared
            .keyWindow?
            .contentViewController?
            .dismiss(gamecenter)
#endif

        onDidFinish?()
    }

    func createGameCenter(launchOption: GameCenterLaunchOption) -> GKGameCenterViewController {
        switch launchOption {
        case .default: return GKGameCenterViewController(state: .default)
        case .leaderboards: return GKGameCenterViewController(state: .leaderboards)
        case .achievements: return GKGameCenterViewController(state: .achievements)
        case .challenges: return GKGameCenterViewController(state: .challenges)
        case .localPlayerProfile: return GKGameCenterViewController(state: .localPlayerProfile)
        case .dashboard: return GKGameCenterViewController(state: .dashboard)
        case .localPlayerFriendsList: return GKGameCenterViewController(state: .localPlayerFriendsList)
        case .leaderBoardID(let id, let playerScope, let timeScope):
            return GKGameCenterViewController(leaderboardID: id, playerScope: playerScope, timeScope: timeScope)
        case .leaderBoard(let leaderboard, let playerScope):
            return GKGameCenterViewController(leaderboard: leaderboard, playerScope: playerScope)
        case .achievementID(let id):
            return GKGameCenterViewController(achievementID: id)
        }
    }
}
