#include <metal_stdlib>
using namespace metal;

// Random float generator in the range of -1.0 to 1.0
float randomFloat(thread const uint& seed) {
    uint state = seed;
    state = 1103515245 * state + 12345;
    return (float(state & 0x00FFFFFF) / float(0x00800000)) - 1.0;
}

// Normalized distribution function with inflection points at -1.0, 0.0 and 1.0, 0.0
float normalizedDistribution(float x) {
    // This is a placeholder for an actual distribution function.
    // For simplicity, we'll use a piecewise linear function here.
    // You can replace it with a more complex curve if needed.
    if (x < -1.0 || x > 1.0) {
        return 0.0;
    } else if (x < 0.0) {
        return x + 1.0;
    } else {
        return 1.0 - x;
    }
}

float calculateFrequency(float randomValue) {
    float normalizedValue = normalizedDistribution(randomValue);
    const float maxFrequency = 3000.0;
    return normalizedValue * maxFrequency;
}

kernel void sineWave(
    device float *resultsLeft [[ buffer(0) ]],
    device float *resultsRight [[ buffer(1) ]],
    constant float &sampleRate [[ buffer(2) ]],
    constant uint &arraySize [[ buffer(3) ]],
    constant uint &seed [[ buffer(4) ]],
    uint id [[ thread_position_in_grid ]]
) {
    float randomValues[8];
    for (uint i = 0; i < 8; i++) {
        randomValues[i] = randomFloat(seed + id + i);
    }

    float frequencies[8];
    for (uint i = 0; i < 8; i++) {
        frequencies[i] = calculateFrequency(randomValues[i]);
    }

    float time = float(id) / float(arraySize);
    float twoPi = 2.0 * M_PI_F;

    resultsLeft[id] = sin(twoPi * frequencies[0] * time);  // Left channel
    resultsRight[id] = sin(twoPi * frequencies[1] * time);  // Right channel
}
