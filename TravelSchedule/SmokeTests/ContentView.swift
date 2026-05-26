//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let runner = try APITestRunner(apikey: Constants.apiKey)
                    await runner.runAll()
                } catch {
                    print("[FAIL] APITestRunner init: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
