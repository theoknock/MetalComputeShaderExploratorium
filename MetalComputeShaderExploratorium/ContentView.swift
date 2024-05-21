import SwiftUI

struct ContentView: View {
    //    @State private var sineWave: [[Float]] = [[Float](repeating: 0.0, count: 88200), [Float](repeating: 0.0, count: 88200)]
    private let generator = MetalSineWaveGenerator(arraySize: 88200, sampleRate: 44100.0)!
    @State private var sineWave: [[Float]] = MetalSineWaveGenerator(arraySize: 88200, sampleRate: 44100.0)!.generateSineWave()
    
    var body: some View {
        VStack(alignment: .center, content: {
            HStack(alignment: .bottom, content: {
                Text("\nSine Wave\t ")
                    .font(.largeTitle)
                Button(action: {
                    self.sineWave = generator.generateSineWave()
                }) {
                    Text("Generate Sine Wave")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            })
            HStack {
                List {
                    ForEach(0..<sineWave[0].count, id: \.self) { index in
                        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom), content: {
                            VStack(alignment: .leading, content: {
                                HStack(alignment: .bottom, content: {
                                    Text("   \(sineWave[0][index])\n")
                                        .offset(x: 15, y: 10)
                                        .padding(.horizontal)
                                        .opacity(0.5)
                                        .font(.system(size: 27.0).monospacedDigit().weight(.heavy)).dynamicTypeSize(.xxxLarge)
                                    Text(" \(sineWave[1][index])\n")
                                        .offset(x: -30, y: 20)
                                        .font(.system(size: 25.0).monospacedDigit().weight(.heavy)).dynamicTypeSize(.xxxLarge)
                                })
                                .font(.system(size: 15.0).monospacedDigit().weight(.heavy)).dynamicTypeSize(.xxxLarge)
                            })
                            Text("\(index)")
                                .font(.system(size: 85.0).monospacedDigit().weight(.heavy)).dynamicTypeSize(.xxxLarge)
                                .opacity(0.09)
                                .offset(x: 17, y: -6)
//                            Spacer()
                        })
                    }
                }
            }
            .frame(width: 400)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
