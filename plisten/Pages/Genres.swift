// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct GenresPage: View {
  let library: Library

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation

    AlbumBrowser(
      title: "Genres",
      placeholder: "No Genre Selected",
      systemImage: "guitars",
      items: library.genres,
      name: \.name,
      selection: $navigation.selectedGenreID,
      albumSort: $navigation.genreAlbumSort
    ) {
      library.albums(in: $0)
    }
  }
}
