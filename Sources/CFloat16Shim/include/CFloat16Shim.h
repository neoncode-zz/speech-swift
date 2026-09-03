#ifndef CFLOAT16_SHIM_H
#define CFLOAT16_SHIM_H

#include <stdint.h>
#include <string.h>

/// IEEE-754 binary16 <-> binary32 conversion.
///
/// Swift's `Float16` is unavailable on x86_64 macOS because the x86 calling
/// convention for half-precision was never finalised (rdar://WWDC20). Clang,
/// however, fully supports `_Float16` as a storage/arithmetic type on x86_64
/// and lowers conversions to __truncsfhf2/__extendhfsf2, which implement
/// correct round-to-nearest-even. No `_Float16` value ever crosses a function
/// boundary here (only uint16_t/float do), so the unstable ABI is never hit.

static inline uint16_t cf16_from_float(float value) {
    _Float16 half = (_Float16)value;
    uint16_t bits;
    memcpy(&bits, &half, sizeof(bits));
    return bits;
}

static inline float cf16_to_float(uint16_t bits) {
    _Float16 half;
    memcpy(&half, &bits, sizeof(half));
    return (float)half;
}

#endif /* CFLOAT16_SHIM_H */
