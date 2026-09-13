// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct TrackList: View {
  let tracks: [Track]
  var showsTrackNumber = true
  var showsArtist = true
  var showsAlbum = false
  var omittedArtist: String?

  var body: some View {
    ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
      TrackRow(
        track: track,
        showsTrackNumber: showsTrackNumber,
        artist: showsArtist
          ? Self.artist(of: track, omitting: omittedArtist) : nil,
        showsArtist: showsArtist,
        showsAlbum: showsAlbum
      )
      .background(
        index.isMultiple(of: 2) ? Color.primary.opacity(0.04) : Color.clear,
        in: .rect(cornerRadius: 4)
      )
    }
  }

  static func artist(of track: Track, omitting omitted: String?) -> String? {
    guard let artist = track.artist, !artist.isEmpty else { return nil }
    guard let omitted else { return artist }
    return artist.localizedCaseInsensitiveCompare(omitted) == .orderedSame
      ? nil : artist
  }
}

private struct TrackRow: View {
  let track: Track
  let showsTrackNumber: Bool
  let artist: String?
  let showsArtist: Bool
  let showsAlbum: Bool

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "heart.fill")
        .foregroundStyle(.pink)
        .opacity(track.loved ? 1 : 0)
        .accessibilityHidden(!track.loved)
        .frame(width: 16)

      if showsTrackNumber {
        Text(track.trackNumber.map(String.init) ?? "")
          .monospacedDigit()
          .foregroundStyle(.secondary)
          .frame(width: 28, alignment: .trailing)
      }

      TrackTitle(track: track)
        .frame(maxWidth: .infinity, alignment: .leading)

      if showsArtist {
        Text(artist ?? "")
          .lineLimit(1)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      if showsAlbum {
        Text(track.album ?? "")
          .lineLimit(1)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      Text(
        Duration.milliseconds(track.totalTime)
          .formatted(.time(pattern: .minuteSecond))
      )
      .monospacedDigit()
      .foregroundStyle(.secondary)
      .frame(minWidth: 44, alignment: .trailing)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
  }
}
