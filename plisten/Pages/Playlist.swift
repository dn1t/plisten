// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct PlaylistPage: View {
  let playlist: Playlist
  let library: Library

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation
    let tracks = library.tracks(in: playlist)

    SortedResults(
      tracks,
      sort: navigation.playlistSort,
      naturalSort: SortSetting(.playlistOrder),
      matching: { $0.matches($1) }
    ) { results in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          PlaylistHeader(playlist: playlist, tracks: tracks)
            .padding(.bottom, 24)

          TrackList(tracks: results, showsTrackNumber: false, showsAlbum: true)
        }
        .padding(24)
      }
    }
    .navigationTitle(playlist.name)
    .searchable(text: $navigation.searchText, prompt: "Search Playlist")
    .toolbar {
      SortMenu(sort: $navigation.playlistSort)
    }
  }
}

private struct PlaylistHeader: View {
  let playlist: Playlist
  let tracks: [Track]

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(playlist.name)
        .font(.largeTitle)
        .fontWeight(.bold)
        .lineLimit(2)

      if let description = playlist.description, !description.isEmpty {
        Text(description)
          .font(.body)
          .foregroundStyle(.secondary)
      }

      Text(summary)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
    .textSelection(.enabled)
  }

  private var summary: String {
    let count = "\(tracks.count) song\(tracks.count == 1 ? "" : "s")"
    let totalTime = tracks.reduce(0) { $0 + $1.totalTime }
    guard totalTime > 0 else { return count }

    let duration = Duration.milliseconds(totalTime)
      .formatted(.units(allowed: [.hours, .minutes], width: .wide))
    return "\(count) · \(duration)"
  }
}
