// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct AlbumTable: View {
  let albums: [Album]
  var showsArtist = true

  @Environment(NavigationModel.self) private var navigation

  @State private var selection: Album.ID?

  var body: some View {
    Table(albums, selection: $selection) {
      TableColumn("Name", value: \.name)
        .width(min: 60, ideal: 300)
      if showsArtist {
        TableColumn("Artist") { Text($0.artist ?? "—") }
          .width(min: 60, ideal: 100)
      }
      TableColumn("Tracks") { Text($0.trackIDs.count.description) }
        .width(min: 40, ideal: 60, max: 100)
    }
    .contextMenu(forSelectionType: Album.ID.self) { _ in
    } primaryAction: { ids in
      if ids.count == 1, let id = ids.first,
        let album = albums.first(where: { $0.id == id })
      {
        navigation.showAlbum(album)
      }
    }
  }
}
