//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Christopher Truman on 10/19/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var bloodSugar: Int
    @State var trend: String
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
        ContentView(bloodSugar: 120, trend: LatestGlucoseValues.TrendDirections.DoubleUp.arrow)
    }
}
