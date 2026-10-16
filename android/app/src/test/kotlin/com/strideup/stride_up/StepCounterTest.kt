package com.strideup.stride_up

import org.junit.Assert.assertEquals
import org.junit.Test

class StepCounterTest {
    @Test fun firstLaunchDoesNotImportStepsFromBeforeInstallation() {
        assertEquals(0, StepCounter.delta(-1, 80000, true))
    }
    @Test fun restartRecoversOnlyTheNewSteps() {
        assertEquals(25, StepCounter.delta(80000, 80025, true))
    }
    @Test fun duplicateSensorEventsDoNotDoubleCount() {
        assertEquals(0, StepCounter.delta(80025, 80025, true))
    }
    @Test fun pausedPeriodIsExcludedAfterBaselineCleared() {
        assertEquals(0, StepCounter.delta(-1, 90000, true))
        assertEquals(3, StepCounter.delta(90000, 90003, true))
    }
    @Test fun rebootCannotAddOldBootStepsEvenWhenNewCounterIsHigher() {
        assertEquals(0, StepCounter.delta(100, 1000, false))
    }
    @Test fun sensorResetDoesNotSubtractSteps() {
        assertEquals(0, StepCounter.delta(1000, 4, true))
    }
}
