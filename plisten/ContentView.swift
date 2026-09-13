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

struct ContentView: View {
  let document: LibraryDocument

  @State private var selection = SidebarItem.albums

  @State private var path: [Page] = []
  @State private var selectedAlbumID: Album.ID?

  private var playlists: [Playlist] { document.library?.playlists ?? [] }

  var body: some View {
    NavigationSplitView {
      if let library = document.library {
        List(selection: $selection) {
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
  }

  @ViewBuilder
  private var detail: some View {
    NavigationRoot(path: $path) {
      if let library = document.library {
        if selection == .artists {

        } else if selection == .albums {
          Table(library.albums, selection: $selectedAlbumID) {
            TableColumn("Name", value: \.name)
              .width(min: 60, ideal: 300)
            TableColumn("Artist") { Text($0.artist ?? "—") }
              .width(min: 60, ideal: 100)
            TableColumn("Tracks") { Text($0.trackIDs.count.description) }
              .width(min: 40, ideal: 60, max: 100)
          }
          .contextMenu(forSelectionType: Album.ID.self) { _ in
          } primaryAction: { ids in
            if ids.count == 1, let id = ids.first,
              let album = library.albums.first(where: { $0.id == id })
            {
              path.append(.album(album: album))
            }
          }
        }
      } else {
        ProgressView()
          .controlSize(.large)
      }
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
