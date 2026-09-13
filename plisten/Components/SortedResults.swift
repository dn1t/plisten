// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct SortedResults<Item: Sendable, Field: SortField, Content: View>: View
where Field.Item == Item {
  let items: [Item]
  let sort: SortSetting<Field>
  let naturalSort: SortSetting<Field>
  let matches: (@Sendable (Item, String) -> Bool)?
  @ViewBuilder let content: ([Item]) -> Content

  @Environment(NavigationModel.self) private var navigation

  @State private var results: (key: ResultsKey<Field>, items: [Item])?

  init(
    _ items: [Item],
    sort: SortSetting<Field>,
    naturalSort: SortSetting<Field>,
    matching matches: (@Sendable (Item, String) -> Bool)? = nil,
    @ViewBuilder content: @escaping ([Item]) -> Content
  ) {
    self.items = items
    self.sort = sort
    self.naturalSort = naturalSort
    self.matches = matches
    self.content = content
  }

  var body: some View {
    content(results?.items ?? items)
      .id(results?.key)
      .task(id: key) {
        let key = key
        guard !key.query.isEmpty || key.sort != naturalSort else {
          results = nil
          return
        }

        if !key.query.isEmpty && key.query != results?.key.query {
          do {
            try await Task.sleep(for: .milliseconds(150))
          } catch {
            return
          }
        }

        let items = await process(items, key: key, matches: matches)
        if !Task.isCancelled {
          results = (key, items)
        }
      }
  }

  private var key: ResultsKey<Field> {
    ResultsKey(query: matches == nil ? "" : navigation.searchText, sort: sort)
  }
}

nonisolated private struct ResultsKey<Field: SortField>: Hashable, Sendable {
  let query: String
  let sort: SortSetting<Field>
}

extension SortedResults where Field == Unsorted<Item> {
  init(
    _ items: [Item],
    matching matches: @escaping @Sendable (Item, String) -> Bool,
    @ViewBuilder content: @escaping ([Item]) -> Content
  ) {
    let unsorted = SortSetting(field: Unsorted<Item>(), ascending: true)
    self.init(
      items,
      sort: unsorted,
      naturalSort: unsorted,
      matching: matches,
      content: content
    )
  }
}

@concurrent
private func process<Field: SortField>(
  _ items: [Field.Item],
  key: ResultsKey<Field>,
  matches: (@Sendable (Field.Item, String) -> Bool)?
) async -> [Field.Item] where Field.Item: Sendable {
  var items = items
  if let matches, !key.query.isEmpty {
    items = items.filter { matches($0, key.query) }
  }
  return key.sort.apply(to: items)
}
