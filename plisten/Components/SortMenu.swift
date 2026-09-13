// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct SortMenu<Field: SortOption>: View {
  @Binding var sort: SortSetting<Field>
  var fields = Array(Field.allCases)

  var body: some View {
    Menu {
      Picker("Sort By", selection: field) {
        ForEach(fields) { field in
          Text(field.title).tag(field)
        }
      }
      .pickerStyle(.inline)

      Picker("Order", selection: $sort.ascending) {
        Text("Ascending").tag(true)
        Text("Descending").tag(false)
      }
      .pickerStyle(.inline)
    } label: {
      Label("Sort By", systemImage: "arrow.up.arrow.down")
    }
    .help("Sort By")
  }

  private var field: Binding<Field> {
    Binding {
      sort.field
    } set: { field in
      if field != sort.field {
        sort = SortSetting(field)
      }
    }
  }
}
