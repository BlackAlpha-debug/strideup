package com.strideup.stride_up

internal object StepCounter {
    // A missing baseline means a first launch or an explicit pause, not zero steps since boot.
    fun delta(previous: Int, current: Int, sameBoot: Boolean): Int =
        if (sameBoot && previous >= 0 && current >= previous) current - previous else 0
}
