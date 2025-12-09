//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// score_ppg_signal_fourier.h
//
// Code generation for function 'score_ppg_signal_fourier'
//

#ifndef SCORE_PPG_SIGNAL_FOURIER_H
#define SCORE_PPG_SIGNAL_FOURIER_H

// Include files
#include "rtwtypes.h"
#include "score_ppg_signal_fourier_types.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void average_pulse(const coder::array<double, 2U> &processed_ppg_signal,
                          double b_average_pulse[500]);

extern void
preprocess_ppg_signal(const coder::array<double, 2U> &ppg_signal,
                      const coder::array<int64m_T, 2U> &timestamps,
                      coder::array<double, 2U> &processed_ppg_signal);

extern void
score_ppg_signal_fourier(const coder::array<double, 2U> &processed_ppg_signal,
                         const int64m_T coefficient_count,
                         coder::array<double, 1U> &scores);

extern void score_ppg_signal_fourier_initialize();

extern void score_ppg_signal_fourier_terminate();

extern void score_ppg_signal_linear_slope(
    const coder::array<double, 2U> &processed_ppg_signal,
    coder::array<double, 1U> &scores);

extern void score_ppg_signal_peak_detection(
    const coder::array<double, 2U> &processed_ppg_signal,
    coder::array<double, 1U> &scores);

extern void score_ppg_signal_rising_edge_area(
    const coder::array<double, 2U> &processed_ppg_signal,
    coder::array<double, 1U> &scores);

extern void split_ppg_signal(const coder::array<double, 2U> &ppg_signal,
                             coder::array<double, 2U> &indices);

#endif
// End of code generation (score_ppg_signal_fourier.h)
