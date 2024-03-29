//
//  TapStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

struct TapStack<Tag: Hashable & Startable, Content: View>: View {
    @Environment(\.animDefaultRamp) private var defaultRamp
    @State private var phases: [AnyHashable: Aneem.Phase] = [:]
    @State private var currentTag: Tag = .start
    private var onTapped: () -> Void
    private var onFinished: () -> Void
    private let order: [Tag]
    private let ramps: [Tag: Aneem.Ramp]
    private let content: (Tag) -> Content

    init<Order: Collection>(order: Order,
                            ramps: [Tag: Aneem.Ramp] = [:],
                            onTapped: @escaping () -> Void = { },
                            onFinished: @escaping () -> Void = { },
                            @ViewBuilder content: @escaping (Tag) -> Content) where Order.Element == Tag {
        self.onTapped = onTapped
        self.onFinished = onFinished
        self.order = Array(order)
        self.ramps = ramps
        self.content = content
    }

    var body: some View {
        let rampTimes = order.map { ($0, ramps[$0] ?? defaultRamp) }
        ZStack {
            TapView(perform: onTap)
            content(currentTag)
                .environment(\.animPhases, phases)
        }
        .environment(\.animRamps, .init(rampTimes) { $1 })
        .onAppear(perform: setupTags)
    }

    func defaultRamp(_ ramp: Aneem.Ramp) -> some View {
        self.environment(\.animDefaultRamp, ramp)
    }

    private func setupTags() {
        let first = order.first ?? .start
        currentTag = first
        phases = .init(order.map { (.init($0), $0 == first ? .during : .before) }) { $1 }
    }

    private func onTap() {
        phases[currentTag] = .after
        let current = order.firstIndex(of: currentTag) ?? 0
        onTapped()

        guard order.indices.contains(current + 1) else {
            let delay = (ramps[currentTag] ?? defaultRamp).rampOut
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                onFinished()
            }
            return
        }

        currentTag = order[current + 1]
        phases[currentTag] = .during
    }
}

extension TapStack where Tag: StepEnum {
    init(stepped: Tag.Type,
         ramps: [Tag: Aneem.Ramp] = [:],
         onTapped: @escaping () -> Void = { },
         onFinished: @escaping () -> Void = { },
         @ViewBuilder content: @escaping (Tag) -> Content) {
        self.order = Array(Tag.allCases)
        self.ramps = ramps
        self.onTapped = onTapped
        self.onFinished = onFinished
        self.content = content
    }
}

extension TapStack {
    init<Tags: RandomAccessCollection, V: View, AnimatorType: Animator>(forEachTag tags: Tags,
                                                                        ramp: Aneem.Ramp = .standard,
                                                                        animator: AnimatorType.Type,
                                                                        onTapped: @escaping () -> Void = { },
                                                                        onFinished: @escaping () -> Void = { },
                                                                        @ViewBuilder content: @escaping (Tag) -> V)
    where Tags.Element == Tag, Content == ForEach<Tags, Tag, AnimatedView<AnimatorType, V>> {
        let ramps = Dictionary(uniqueKeysWithValues: tags.map { ($0, ramp.delayRampIn(by: $0 == tags.first ? 0 : ramp.rampOut)) })
        self.init(order: tags, ramps: ramps, onTapped: onTapped, onFinished: onFinished) { _ in
            ForEach(tags, id: \.self) { tag in
                AnimatedView(animator: AnimatorType.self, tag: tag, content: content(tag))
            }
        }
    }

    init<Data: RandomAccessCollection, V: View, AnimatorType: Animator>(forEach data: Data,
                                                                        ramp: Aneem.Ramp = .standard,
                                                                        animator: AnimatorType.Type,
                                                                        onFinished: @escaping () -> Void = { },
                                                                        @ViewBuilder content: @escaping (Data.Element) -> V)
    where Data.Element: Identifiable, Data.Element.ID: Startable, Data.Element.ID == Tag, Content == ForEach<Data, Tag, AnimatedView<AnimatorType, V>> {
        let ramps = Dictionary(uniqueKeysWithValues: data.map { ($0.id, ramp.delayRampIn(by: $0.id == data.first?.id ? 0 : ramp.rampOut)) })
        self.init(order: data.map(\.id), ramps: ramps, onFinished: onFinished) { currentTag in
            ForEach(data) { datum in
                AnimatedView(animator: AnimatorType.self, tag: datum.id, content: content(datum))
            }
        }
    }
}
