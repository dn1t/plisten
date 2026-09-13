// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

enum SidebarItem: Hashable {
  case artists
  case albums
  case songs
  case genres
  case playlist(id: Playlist.ID)
}

@Observable
final class NavigationModel {
  var sidebarSelection = SidebarItem.albums {
    didSet {
      if sidebarSelection != oldValue {
        path = []
        searchText = ""
      }
    }
  }

  var selectedArtistID: Artist.ID? {
    didSet {
      if selectedArtistID != oldValue { path = [] }
    }
  }

  var selectedGenreID: Genre.ID? {
    didSet {
      if selectedGenreID != oldValue { path = [] }
    }
  }

  var path: [Page] = []

  var searchText = ""

  var songSort = SortSetting(TrackSortField.title)
  var albumSort = SortSetting(AlbumSortField.title)
  var artistAlbumSort = SortSetting(AlbumSortField.title)
  var genreAlbumSort = SortSetting(AlbumSortField.title)
  var playlistSort = SortSetting(TrackSortField.playlistOrder)

  func showAlbum(_ album: Album) {
    path.append(.album(album: album))
  }

  func showArtist(_ artist: Artist) {
    sidebarSelection = .artists
    selectedArtistID = artist.id
    path = []
  }
}
