package com.strideup.stride_up

import kotlin.math.sqrt

/** Detects a walking sequence, rejecting isolated bumps and enforcing human cadence. */
internal class MotionStepDetector {
    private var gravity = 9.81f
    private var above = false
    private var candidateNs = 0L
    private var sequence = false

    fun sample(x: Float, y: Float, z: Float, timestampNs: Long, sensitivity: Double): List<Long> {
        val magnitude = sqrt(x * x + y * y + z * z)
        gravity = gravity * 0.9f + magnitude * 0.1f
        val motion = magnitude - gravity
        val high = (1.9 - sensitivity.coerceIn(0.35, 1.2) * 0.7).toFloat()
        val low = high * 0.35f
        if (!above && motion > high) {
            above = true
            if (candidateNs == 0L) {
                candidateNs = timestampNs
                sequence = false
                return emptyList()
            }
            val interval = timestampNs - candidateNs
            if (interval in 280_000_000L..2_000_000_000L) {
                val result = if (sequence) listOf(timestampNs) else listOf(candidateNs, timestampNs)
                candidateNs = timestampNs
                sequence = true
                return result
            }
            candidateNs = timestampNs
            sequence = false
        } else if (above && motion < low) {
            above = false
        }
        return emptyList()
    }
}
