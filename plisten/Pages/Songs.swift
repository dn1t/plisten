// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct SongsPage: View {
  let library: Library

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation

    NavigationRoot(path: $navigation.path) {
      SortedResults(
        library.songs,
        sort: navigation.songSort,
        naturalSort: SortSetting(.title),
        matching: { $0.matches($1) }
      ) { tracks in
        TrackTable(tracks: tracks) { track in
          if let album = library.album(containing: track) {
            navigation.showAlbum(album)
          }
        }
      }
      .navigationTitle("Songs")
      .searchable(text: $navigation.searchText, prompt: "Search Songs")
      .toolbar {
        SortMenu(
          sort: $navigation.songSort,
          fields: [.title, .artist, .album, .releaseDate, .dateAdded]
        )
      }
    }
  }
}
