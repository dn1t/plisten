// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct AlbumBrowser<Item: Identifiable & Sendable>: View {
  let title: String
  let placeholder: String
  let systemImage: String
  let items: [Item]
  let name: KeyPath<Item, String> & Sendable
  @Binding var selection: Item.ID?
  @Binding var albumSort: SortSetting<AlbumSortField>
  var showsArtist = true
  let albums: (Item) -> [Album]

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation

    HSplitView {
      SortedResults(items, matching: matches) { items in
        ScrollViewReader { proxy in
          List(items, selection: $selection) {
            Text($0[keyPath: name])
          }
          .onAppear {
            if let selection {
              proxy.scrollTo(selection, anchor: .center)
            }
          }
        }
      }
      .frame(
        minWidth: 160,
        idealWidth: 220,
        maxWidth: 400,
        maxHeight: .infinity
      )

      NavigationRoot(path: $navigation.path) {
        if let selection,
          let item = items.first(where: { $0.id == selection })
        {
          SortedResults(
            albums(item),
            sort: albumSort,
            naturalSort: SortSetting(.title)
          ) { albums in
            AlbumTable(albums: albums, showsArtist: showsArtist)
          }
          .id(item.id)
          .navigationTitle(item[keyPath: name])
          .toolbar {
            SortMenu(sort: $albumSort, fields: sortFields)
          }
        } else {
          ContentUnavailableView(placeholder, systemImage: systemImage)
            .navigationTitle(title)
        }
      }
      .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
    }
    .searchable(text: $navigation.searchText, prompt: "Search \(title)")
  }

  private var sortFields: [AlbumSortField] {
    AlbumSortField.allCases.filter { showsArtist || $0 != .artist }
  }

  private var matches: @Sendable (Item, String) -> Bool {
    { [name] item, query in
      item[keyPath: name].localizedStandardContains(query)
    }
  }
}
