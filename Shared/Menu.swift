//
//  Menu.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 24/02/2022.
//

import Foundation

enum MenuItem: Int, Equatable {
    case about
    case playIntro
    case shareScore
    case reset

    case reallyReset
    case cancelReset
}

extension MenuItem: Identifiable {
    var id: Int { rawValue }
}

let apeMenu =
ApeMenu {
    Row(.about)
    Row(.playIntro)
    Row(.shareScore)
    SubMenu(.reset) {
        Row(.reallyReset)
        Row(.cancelReset)
    }
}

typealias ApeMenu = [MenuEntry]

extension ApeMenu {
    init(@MenuBuilder _ content: () -> [MenuEntryLike]) {
        self = content().map(\.asMenuEntry)
    }

    func row(with item: MenuItem) -> Row {
        guard let selected = first(where: { $0.item == item }) else { return .error }
        if let rows = selected.rows {
            return .subMenu(rows)
        } else {
            return .action(item)
        }
    }

    enum Row {
        case action(MenuItem)
        case subMenu([MenuEntry])
        case error
    }
}

@resultBuilder
struct MenuBuilder {
    static func buildBlock() -> [MenuEntryLike] { [] }
    static func buildBlock(_ rows: MenuEntryLike...) -> [MenuEntryLike] { rows }
}

struct MenuEntry: Equatable {
    let item: MenuItem
    let rows: [MenuEntry]?
}

protocol MenuEntryLike {
    var item: MenuItem { get }
    var rows: [MenuEntryLike]? { get }
}

extension MenuEntryLike {
    var rows: [MenuEntryLike]? { nil }
}

extension MenuEntryLike {
    var asMenuEntry: MenuEntry {
        .init(item: item, rows: rows?.map(\.asMenuEntry))
    }
}

private struct SubMenu: MenuEntryLike {
    let item: MenuItem
    let rows: [MenuEntryLike]?

    init(_ item: MenuItem, @MenuBuilder builder: () -> [MenuEntryLike]) {
        self.item = item
        self.rows = builder()
    }
}

private struct Row: MenuEntryLike {
    let item: MenuItem

    init(_ item: MenuItem) {
        self.item = item
    }
}
