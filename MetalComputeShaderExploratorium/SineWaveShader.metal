#include <metal_stdlib>
using namespace metal;

struct SineWaveParams {
    float frequencyL;
    float frequencyR;
    float sampleRate;
    uint  arraySize;
};

kernel void sineWave(
    device float *results [[ buffer(0) ]],
    device float *channelL [[ buffer(1) ]],
    device float *channelR [[ buffer(2) ]],
    constant SineWaveParams &params [[ buffer(3) ]],
    uint id [[ thread_position_in_grid ]]
) {
    float twoPi = 2.0 * M_2_PI_F;
    float time = float(id) / float(params.arraySize);

    float sampleL = sin(twoPi * params.frequencyL * time);
    channelL[id] = sampleL;

    float sampleR = sin(twoPi * params.frequencyR * time);
    channelR[id] = sampleR;
    
//    results[id] = params.sampleRate; //sin(twoPi * frequencyL * time);  // Left channel
//    results[id] = params.arraySize; //sin(twoPi * frequencyR * time);  // Right channel
}
