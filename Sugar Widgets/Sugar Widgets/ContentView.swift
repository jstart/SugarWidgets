//
//  ContentView.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/18/22.
//

import SwiftUI

struct ContentView: View {
    @State var bloodSugar: Int?
    @State var trend: String?
    @State var dateString: String?
    @Environment(\.scenePhase) var scenePhase
    
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool> = .constant(false)) {
            _isPresented = isPresented
    }
    
    var body: some View {
        VStack {
//            Image(systemName:"hand.wave")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
            Text("Current glucose reading:")
                .multilineTextAlignment(.center)
                .font(.title)
                .minimumScaleFactor(0.25)
                .animation(.easeIn, value: bloodSugar)
            if let bloodSugar, let trend, let dateString {
                Text("\(bloodSugar)")
                    .font(.largeTitle)
                    .bold()
                    .animation(.easeIn, value: bloodSugar)
                Text("Trend: \(trend)")
                    .font(.title)
                    .animation(.easeIn, value: trend)
                    .minimumScaleFactor(0.25)
                Text(dateString)
                    .font(.callout)
                    .animation(.easeIn, value: trend)
                    .minimumScaleFactor(0.25)
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: { onAppear() })
        .popover(isPresented: $isPresented, content: {
            Text("Login")
        })
    }
    
    func onAppear() {
        DexcomService.shared.onAppear(completion: { value, direction, date in
            trend = "\(direction.arrow), \(direction.trendDiscriptions.capitalized)"
            bloodSugar = value
            
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            var relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
            if relativeDate.contains("in 0 seconds") {
                relativeDate = "Just now"
            }
            dateString = relativeDate
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
