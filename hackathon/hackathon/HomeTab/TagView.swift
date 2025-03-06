//
//  TagView.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation
import SwiftUI

struct TagsView<T: Hashable, V: View>: View {
    let items: [T] //Hashable items
    var lineLimit: Int //How many lines do you want
    var grouptedItems: [[T]] = [[T]]()
    let cloudTagView: (T) -> V

    init(items: [T], lineLimit: Int, cloudTagView: @escaping (T) -> V) {
        self.items = items
        self.cloudTagView = cloudTagView
        self.lineLimit = lineLimit
        self.grouptedItems = self.createGroupedItems(items, lineLimit:
            lineLimit)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(self.grouptedItems, id: \.self) { subItems in
                    HStack {
                        ForEach(subItems, id: \.self) { word in
                            cloudTagView(word)
                        }
                        Spacer()
                    }.padding(.horizontal, 16)
                }
            }
        }
    }

    private func createGroupedItems(_ items: [T], lineLimit: Int) -> [[T]]
    {
        var grouptedItems: [[T]] = [[T]]()
        var tempItems: [T] = [T]()

        let temp = items.count % lineLimit
        let count = (items.count - temp) / lineLimit

        for word in items {
            if tempItems.count < count + 1 {
                tempItems.append(word)
            } else {
                grouptedItems.append(tempItems)
                tempItems.removeAll()
                tempItems.append(word)
            }
        }

        grouptedItems.append(tempItems)
        return grouptedItems
    }
}

//MARK: Example
struct TestContentView: View {
    let items = ["Swift", "Java", "Python", "JavaScript",
                 "C++", "Ruby", "PHP", "Objective-C", "C#", "Perl", "Go", "R", "Kotlin",
                 "SwiftUI", "HTML", "CSS", "SQL", "TypeScript"]
    var body: some View {
        TagsView(items: items, lineLimit: 3) { item in
            Text(item)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(Capsule())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      TestContentView()
    }
}
