//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// preprocess_ppg_signal.h
//
// Code generation for function 'preprocess_ppg_signal'
//

#ifndef PREPROCESS_PPG_SIGNAL_H
#define PREPROCESS_PPG_SIGNAL_H

// Include files
#include "preprocess_ppg_signal_types.h"
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void
preprocess_ppg_signal(const coder::array<double, 2U> &ppg_signal,
                      const coder::array<int64m_T, 2U> &timestamps,
                      coder::array<double, 2U> &processed_ppg_signal);

extern void preprocess_ppg_signal_initialize();

extern void preprocess_ppg_signal_terminate();

extern void
score_ppg_signal(const coder::array<double, 2U> &processed_ppg_signal,
                 const int64m_T coefficient_count,
                 coder::array<double, 1U> &scores);

#endif
// End of code generation (preprocess_ppg_signal.h)
