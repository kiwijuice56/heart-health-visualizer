//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// preprocess_ppg_pulse.h
//
// Code generation for function 'preprocess_ppg_pulse'
//

#ifndef PREPROCESS_PPG_PULSE_H
#define PREPROCESS_PPG_PULSE_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void
preprocess_ppg_pulse(const coder::array<double, 2U> &ppg_signal,
                     coder::array<double, 2U> &processed_ppg_signal);

extern void preprocess_ppg_pulse_initialize();

extern void preprocess_ppg_pulse_terminate();

#endif
// End of code generation (preprocess_ppg_pulse.h)
