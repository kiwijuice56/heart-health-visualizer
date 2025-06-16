//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// score_ppg_signal.h
//
// Code generation for function 'score_ppg_signal'
//

#ifndef SCORE_PPG_SIGNAL_H
#define SCORE_PPG_SIGNAL_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void score_ppg_signal(const coder::array<double, 2U> &ppg_signal,
                             coder::array<double, 1U> &scores);

extern void score_ppg_signal_initialize();

extern void score_ppg_signal_terminate();

#endif
// End of code generation (score_ppg_signal.h)
