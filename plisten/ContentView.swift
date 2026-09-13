// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct ContentView: View {
  let document: LibraryDocument

  @State private var navigation = NavigationModel()

  var body: some View {
    NavigationSplitView {
      if let library = document.library {
        List(selection: $navigation.sidebarSelection) {
          Section("Library") {
            Label("Artists", systemImage: "music.microphone")
              .tag(SidebarItem.artists)
            Label("Albums", systemImage: "square.stack")
              .tag(SidebarItem.albums)
            Label("Songs", systemImage: "music.note")
              .tag(SidebarItem.songs)
            Label("Genres", systemImage: "guitars")
              .tag(SidebarItem.genres)
          }

          Section("Playlists") {
            ForEach(library.children(of: nil)) { playlist in
              PlaylistRow(playlist: playlist, library: library)
            }
          }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      }
    } detail: {
      detail
    }
    .environment(document)
    .environment(navigation)
  }

  @ViewBuilder
  private var detail: some View {
    if let library = document.library {
      switch navigation.sidebarSelection {
      case .artists:
        ArtistsPage(library: library)
      case .albums:
        AlbumsPage(library: library)
      case .songs:
        SongsPage(library: library)
      case .genres:
        GenresPage(library: library)
      case .playlist(let id):
        if let playlist = library.playlist(id: id) {
          PlaylistPage(playlist: playlist, library: library)
            .id(id)
        } else {
          ContentUnavailableView(
            "Playlist Not Found",
            systemImage: "music.note.list"
          )
        }
      }
    } else {
      ProgressView()
        .controlSize(.large)
    }
  }
}

private struct PlaylistRow: View {
  let playlist: Playlist
  let library: Library

  var body: some View {
    if playlist.folder {
      DisclosureGroup {
        ForEach(library.children(of: playlist)) { child in
          PlaylistRow(playlist: child, library: library)
        }
      } label: {
        label
      }
    } else {
      label
    }
  }

  var label: some View {
    Label(
      playlist.name,
      systemImage: playlist.folder ? "folder" : "music.note.list"
    )
    .tag(SidebarItem.playlist(id: playlist.id))
  }
}

#Preview {
  let document = LibraryDocument()
  document.library = try? Library.from(
    url: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
      "Downloads/Library.xml"
    )
  )

  return ContentView(document: document)
}
