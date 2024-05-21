import MetalKit

struct SineWaveParams {
    var frequencyL: Float
    var frequencyR: Float
    var sampleRate: Float
    var arraySize: UInt32
}

class MetalSineWaveGenerator {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let computePipelineState: MTLComputePipelineState
    let arraySize: Int
    let sampleRate: Float

    init?(arraySize: Int, sampleRate: Float) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "sineWave"),
              let computePipelineState = try? device.makeComputePipelineState(function: function) else {
            return nil
        }

        self.device = device
        self.commandQueue = commandQueue
        self.computePipelineState = computePipelineState
        self.arraySize = arraySize
        self.sampleRate = sampleRate
    }

    func generateSineWave() -> [[Float]] {
        let bufferSize = arraySize * MemoryLayout<Float>.size
        
        func normalize(data: [Double]) -> [Double] {
            let norm = sqrt(data.map { $0 * $0 }.reduce(0, +))
            guard norm != 0 else { return data }
            return data.map { $0 / norm }
        }
        
        
        // Create buffers for left and right channels and the result
        let resultBuffer = device.makeBuffer(length: bufferSize * 2, options: .storageModeShared)!
        let channelLBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)!
        let channelRBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)!
        
       
        // Fill buffers with initial data (e.g., random values for frequencies)
//        fillBufferWithRandomData(channelLBuffer)
//        fillBufferWithRandomData(channelRBuffer)

        var params = SineWaveParams(frequencyL: Float.random(in: 2000.0...3000.0), frequencyR: Float.random(in: 2000.0...3000.0), sampleRate: self.sampleRate, arraySize: UInt32(self.arraySize));

        // Create a command buffer and encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(resultBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(channelLBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(channelRBuffer, offset: 0, index: 2)
        computeEncoder.setBytes(&params, length: MemoryLayout<SineWaveParams>.size, index: 3)

        // Dispatch the compute shader
        let threadGroupSize = MTLSize(width: 256, height: 1, depth: 1)
        let threadGroups = MTLSize(width: (arraySize + threadGroupSize.width - 1) / threadGroupSize.width, height: 1, depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)

        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Retrieve results
        let channelLPointer = channelLBuffer.contents().bindMemory(to: Float.self, capacity: arraySize)
        let channelRPointer = channelRBuffer.contents().bindMemory(to: Float.self, capacity: arraySize)
        let leftChannel     = Array(UnsafeBufferPointer(start: channelLPointer, count: arraySize))
        let rightChannel    = Array(UnsafeBufferPointer(start: channelRPointer, count: arraySize))
        
        return [leftChannel, rightChannel]
    }

    private func fillBufferWithRandomData(_ buffer: MTLBuffer) {
        let pointer = buffer.contents().bindMemory(to: Float.self, capacity: arraySize)
        for i in 0..<arraySize {
            pointer[i] = Float.random(in: 0.0..<1.0)
        }
    }
}
