// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct AlbumsPage: View {
  let library: Library

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation

    NavigationRoot(path: $navigation.path) {
      SortedResults(
        library.albums,
        sort: navigation.albumSort,
        naturalSort: SortSetting(.title),
        matching: { $0.matches($1) }
      ) { albums in
        AlbumTable(albums: albums)
      }
      .navigationTitle("Albums")
      .searchable(text: $navigation.searchText, prompt: "Search Albums")
      .toolbar {
        SortMenu(sort: $navigation.albumSort)
      }
    }
  }
}
