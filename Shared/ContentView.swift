//
//  ContentView.swift
//  GreatApeGame
//
//  Created by Gustaf Kugelberg on 17/02/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                let size = boardSize * proxy.size
                Image("OS-Background")
                    .resizable(resizingMode: .stretch)
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
        .animation(.spring(), value: scale)
        .onAppear {
            store.send(.startup)
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
