// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct ArtistsPage: View {
  let library: Library

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation

    AlbumBrowser(
      title: "Artists",
      placeholder: "No Artist Selected",
      systemImage: "music.microphone",
      items: library.artists,
      name: \.name,
      selection: $navigation.selectedArtistID,
      albumSort: $navigation.artistAlbumSort,
      showsArtist: false
    ) {
      library.albums(by: $0)
    }
  }
}
