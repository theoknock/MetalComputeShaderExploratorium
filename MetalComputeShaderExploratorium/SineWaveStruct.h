#ifndef SineWaveStruct_h
#define SineWaveStruct_h

#include <metal_stdlib>
using namespace metal;

struct SineWaveParams {
    float sampleRate;
    uint arraySize;
    float randomValueLeft;
    float randomValueRight;
    device float *resultsLeft;
    device float *resultsRight;
};

#endif /* SineWaveStruct_h */
