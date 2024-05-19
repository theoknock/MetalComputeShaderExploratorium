import SwiftUI

struct ContentView: View {
    @State private var sineWave: [[Float]] = [[Float](repeating: 0.0, count: 88200), [Float](repeating: 0.0, count: 88200)]
    private let generator = MetalSineWaveGenerator(arraySize: 88200, sampleRate: 44100.0)!

    var body: some View {
        VStack {
            Text("Sine Wave")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                self.sineWave = generator.generateSineWave()
            }) {
                Text("Generate Sine Wave")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            List {
                ForEach(0..<sineWave[0].count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Left Channel [\(index)]: \(sineWave[0][index])")
                        Text("Right Channel [\(index)]: \(sineWave[1][index])")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
