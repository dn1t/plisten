// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct TrackTable: View {
  let tracks: [Track]

  var body: some View {
    Table(tracks) {
      TableColumn("Name", value: \.name)
      TableColumn("Artist") { Text($0.artist ?? "—") }
      TableColumn("Album") { Text($0.album ?? "—") }
      TableColumn("Genre") { Text($0.genre ?? "—") }
      TableColumn("Time") { Text(duration(milliseconds: $0.totalTime)) }
        .width(60)
    }
  }

  private func duration(milliseconds: Int) -> String {
    Duration.milliseconds(milliseconds)
      .formatted(.time(pattern: .minuteSecond))
  }
}
