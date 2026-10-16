package com.strideup.stride_up

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MotionStepDetectorTest {
    @Test fun isolatedBumpIsNotCounted() {
        val detector = MotionStepDetector()
        detector.sample(0f, 0f, 9.81f, 0L, .8)
        assertTrue(detector.sample(0f, 0f, 13f, 100_000_000L, .8).isEmpty())
        detector.sample(0f, 0f, 9.81f, 200_000_000L, .8)
        assertTrue(detector.sample(0f, 0f, 13f, 2_500_000_000L, .8).isEmpty())
    }

    @Test fun twoCadencedPeaksReleaseBothWalkingSteps() {
        val detector = MotionStepDetector()
        detector.sample(0f, 0f, 9.81f, 0L, .8)
        detector.sample(0f, 0f, 13f, 100_000_000L, .8)
        detector.sample(0f, 0f, 9.81f, 200_000_000L, .8)
        val steps = detector.sample(0f, 0f, 13f, 600_000_000L, .8)
        assertEquals(listOf(100_000_000L, 600_000_000L), steps)
    }

    @Test fun sensitivityLowersTheMotionThreshold() {
        val normal = MotionStepDetector()
        val sensitive = MotionStepDetector()
        normal.sample(0f, 0f, 9.81f, 0L, .35)
        sensitive.sample(0f, 0f, 9.81f, 0L, 1.2)
        assertTrue(normal.sample(0f, 0f, 11.3f, 100_000_000L, .35).isEmpty())
        sensitive.sample(0f, 0f, 11.3f, 100_000_000L, 1.2)
        sensitive.sample(0f, 0f, 9.81f, 200_000_000L, 1.2)
        val steps = sensitive.sample(0f, 0f, 11.3f, 600_000_000L, 1.2)
        assertEquals(2, steps.size)
    }
}
