//
//  ContentView.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/18/22.
//

import SwiftUI

struct ContentView: View {
    @State var bloodSugar = 0
    @State var trend = ""
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack {
            Image(systemName: "hand.wave")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Current glucose reading:")
                .font(.title)
            Text("\(bloodSugar)")
                .font(.largeTitle)
                .bold()
                .animation(.easeIn)
                Text("Trend: \(trend)")
                    .font(.title)
                    .animation(.easeIn)
        }
        .padding()
        .onAppear(perform: { onAppear() })
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                onAppear()
            }
        }
    }
    
    func onAppear() {
        DexcomService().onAppear(completion: { value, direction in
            trend = "\(direction.arrow), \(direction.trendDiscriptions.capitalized)"
            bloodSugar = value
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
