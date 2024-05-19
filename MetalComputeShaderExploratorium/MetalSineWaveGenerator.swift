import MetalKit

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
        // Create buffers for both channels
        let resultBufferLeft = device.makeBuffer(length: arraySize * MemoryLayout<Float>.size, options: .storageModeShared)!
        let resultBufferRight = device.makeBuffer(length: arraySize * MemoryLayout<Float>.size, options: .storageModeShared)!
        var sampleRate = self.sampleRate
        var arraySize = Int(self.arraySize)
        var seed: UInt32 = UInt32.random(in: 0..<UInt32.max)

        // Create a command buffer and encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(resultBufferLeft, offset: 0, index: 0)
        computeEncoder.setBuffer(resultBufferRight, offset: 0, index: 1)
        computeEncoder.setBytes(&sampleRate, length: MemoryLayout<Float>.size, index: 2)
        computeEncoder.setBytes(&arraySize, length: MemoryLayout<UInt32>.size, index: 3)
        computeEncoder.setBytes(&seed, length: MemoryLayout<UInt32>.size, index: 4)

        // Dispatch the compute shader
        let threadGroupSize = MTLSize(width: 256, height: 1, depth: 1)
        let threadGroups = MTLSize(width: (arraySize + threadGroupSize.width - 1) / threadGroupSize.width, height: 1, depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)

        // End encoding and commit the command buffer
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Retrieve the results
        let leftChannelPointer = resultBufferLeft.contents().bindMemory(to: Float.self, capacity: arraySize)
        let rightChannelPointer = resultBufferRight.contents().bindMemory(to: Float.self, capacity: arraySize)
        let leftChannel = Array(UnsafeBufferPointer(start: leftChannelPointer, count: arraySize))
        let rightChannel = Array(UnsafeBufferPointer(start: rightChannelPointer, count: arraySize))
        return [leftChannel, rightChannel]
    }
}
