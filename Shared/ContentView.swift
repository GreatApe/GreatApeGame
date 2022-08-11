//
//  ContentView.swift
//  GreatApeGame
//
//  Created by Gustaf Kugelberg on 17/02/2022.
//

import SwiftUI
import CoreData

func printAll() {
    print("P1: \(p1), P2: \(p2), P3: \(p3), P4: \(p4)")
}

struct DebugView: View {
    @State var s1: Double = 0.2
    @State var s2: Double = 0.7
    @State var s3: Double = 0.7
    @State var s4: Double = 0.5
    @State var s5: Double = 0.12
    @State var s6: Double = 0.3

    var body: some View {
        VStack {
            Slider(value: $s1, in: 0...1)
            Slider(value: $s2, in: 0...1)
            Slider(value: $s3, in: 0...1)
            Slider(value: $s4, in: 0...1)
//            Slider(value: $s5, in: 0...0.1)
//            Slider(value: $s6, in: 0...0.5)
        }
        .padding(.horizontal, 200)
        .onChange(of: s1) { value in
            p1 = value
            printAll()
        }
        .onChange(of: s2) { value in
            p2 = value
            printAll()
        }
        .onChange(of: s3) { value in
            p3 = value
            printAll()
        }
        .onChange(of: s4) { value in
            p4 = value
            printAll()
        }
        .onChange(of: s5) { value in
            p5 = value
            printAll()
        }
        .onChange(of: s6) { value in
            p6 = value
            printAll()
        }
    }
}

public var p1: Double = 0.2
public var p2: Double = 0.7
public var p3: Double = 0.7
public var p4: Double = 0.5
public var p5: Double = 0.12
public var p6: Double = 0.3

struct ContentView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                let size = boardSize * proxy.size
                Image("OS-Background")
                    .resizable(resizingMode: .stretch)
//                    .overlay(DebugView())
                MainView(size: size)
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(1 / scaleFactor)
                Image("OS-Foreground-wide")
                    .resizable(resizingMode: .stretch)
                    .allowsHitTesting(false)
            }
        }
        .scaleEffect(scale)
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: scale)
        .onAppear {
            store.send(.startup)
        }
        .onDisappear {
            store.send(.finish)
        }
    }

    private var scale: CGFloat {
        switch store.state.screen {
            case .splash, .welcome:
                return 1
            default:
                return scaleFactor
        }
    }

    private let boardSize: CGSize = .init(width: 0.75, height: 0.9)

    private let scaleFactor: CGFloat = 1.22
}

/*
struct ContentView_Old: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlayResultItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<PlayResultItem>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = PlayResultItem(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
