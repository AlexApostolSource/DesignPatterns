//
//  Kata6_SpaceX_Spaghetti.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//


//
//  Kata6_SpaceX_Spaghetti.swift
//  Anti-ejemplo para refactorizar (UI orquesta endpoints v4/v5 y mapea DTOs)
//

import SwiftUI

// La vista mezcla mapeos y reintentos rudimentarios (mal)
struct SpaceXBadView: View {
	@State var viewModel = Kata6Factory.makeViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
			Text("SpaceX Launches")
				.font(.largeTitle)
			List {
				Section(header: Text("Latest").font(.title)) {
					ForEach(viewModel.spaceXLaunchData.filter({ !($0.upcoming ?? false) })) { data in
						VStack(alignment: .leading, spacing: 10) {
							Text("Name: \(data.name)")
							Text("Date: \(data.dateUtc)")
							Text("WebCast: \(data.links.webcast)")

						}
					}
				}

				Section(header: Text("UpComing").font(.title)) {
					ForEach(viewModel.spaceXLaunchData.filter({ ($0.upcoming ?? false) })) { data in
						VStack(alignment: .leading, spacing: 10) {
							Text("Name: \(data.name)")
							Text("Date: \(data.dateUtc)")
						}
					}
				}
			}.refreshable {
				await viewModel.getData()
			}


        }
        .padding()
		.task {
			await viewModel.getData()
		}
    }
	private func loadAll() {}

//    private func loadAll() {
//        status = "loading"
//        fetchLatestV5 { l in
//            if l == nil {
//                // “Fallback” improvisado a v4 next aunque no sea equivalente (mal)
//                fetchNextV4 { n in
//                    DispatchQueue.main.async {
//                        self.next = n
//                        self.status = n == nil ? "error" : "fallback_to_v4_next"
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.latest = l
//                    self.status = "loaded_v5"
//                }
//                // Lanza también el “next” por curiosidad (UI orquesta múltiple, mal)
//                fetchNextV4 { n in
//                    DispatchQueue.main.async { self.next = n }
//                }
//            }
//        }
//    }
}
