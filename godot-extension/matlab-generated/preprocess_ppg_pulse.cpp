//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// preprocess_ppg_pulse.cpp
//
// Code generation for function 'preprocess_ppg_pulse'
//

// Include files
#include "preprocess_ppg_pulse.h"
#include "coder_array.h"
#include <cmath>

// Function Declarations
namespace coder {
static void normalize(const array<double, 2U> &a, array<double, 2U> &n);

static void rescale(array<double, 2U> &A);

} // namespace coder

// Function Definitions
namespace coder {
static void normalize(const array<double, 2U> &a, array<double, 2U> &n)
{
  array<double, 2U> mu;
  double b;
  double bsum;
  double y;
  int counts;
  int firstBlockLength;
  int hi;
  int lastBlockLength;
  int nblocks;
  if (a.size(1) == 0) {
    y = 0.0;
    counts = 0;
  } else {
    if (a.size(1) <= 1024) {
      firstBlockLength = a.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(a.size(1)) >> 10);
      lastBlockLength = a.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y = a[0];
    counts = 1;
    for (int k{2}; k <= firstBlockLength; k++) {
      y += a[k - 1];
      counts++;
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      firstBlockLength = (ib - 1) << 10;
      bsum = a[firstBlockLength];
      counts++;
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k{2}; k <= hi; k++) {
        bsum += a[(firstBlockLength + k) - 1];
        counts++;
      }
      y += bsum;
    }
  }
  b = y / static_cast<double>(counts);
  counts = a.size(1);
  if (a.size(1) == 0) {
    y = 0.0;
  } else if (a.size(1) == 1) {
    y = 0.0;
  } else {
    double xbar;
    if (a.size(1) <= 1024) {
      firstBlockLength = a.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(a.size(1)) >> 10);
      lastBlockLength = a.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    xbar = a[0];
    for (int k{2}; k <= firstBlockLength; k++) {
      xbar += a[k - 1];
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      firstBlockLength = (ib - 1) << 10;
      bsum = a[firstBlockLength];
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k{2}; k <= hi; k++) {
        bsum += a[(firstBlockLength + k) - 1];
      }
      xbar += bsum;
    }
    xbar /= static_cast<double>(a.size(1));
    y = 0.0;
    bsum = 3.3121686421112381E-170;
    for (int k{0}; k < counts; k++) {
      double d;
      d = std::abs(a[k] - xbar);
      if (d > bsum) {
        double t;
        t = bsum / d;
        y = y * t * t + 1.0;
        bsum = d;
      } else {
        double t;
        t = d / bsum;
        y += t * t;
      }
    }
    y = bsum * std::sqrt(y);
    y /= std::sqrt(static_cast<double>(a.size(1)) - 1.0);
  }
  mu.set_size(1, a.size(1));
  if (a.size(1) != 0) {
    firstBlockLength = (a.size(1) != 1);
    for (int k{0}; k < counts; k++) {
      mu[k] = a[firstBlockLength * k] - b;
    }
  }
  n.set_size(1, a.size(1));
  if (mu.size(1) != 0) {
    firstBlockLength = (mu.size(1) != 1);
    for (int k{0}; k < counts; k++) {
      n[k] = mu[firstBlockLength * k] / y;
    }
  }
}

static void rescale(array<double, 2U> &A)
{
  double r1;
  double r3;
  double sigma;
  int eint;
  int last_tmp;
  last_tmp = A.size(1);
  if (A.size(1) <= 2) {
    if (A.size(1) == 1) {
      r1 = A[0];
    } else {
      sigma = A[A.size(1) - 1];
      if (A[0] > sigma) {
        r1 = sigma;
      } else {
        r1 = A[0];
      }
    }
  } else {
    r1 = A[0];
    for (int k{2}; k <= last_tmp; k++) {
      sigma = A[k - 1];
      if (r1 > sigma) {
        r1 = sigma;
      }
    }
  }
  if (A.size(1) <= 2) {
    if (A.size(1) == 1) {
      r3 = A[0];
    } else {
      sigma = A[A.size(1) - 1];
      if (A[0] < sigma) {
        r3 = sigma;
      } else {
        r3 = A[0];
      }
    }
  } else {
    r3 = A[0];
    for (int k{2}; k <= last_tmp; k++) {
      sigma = A[k - 1];
      if (r3 < sigma) {
        r3 = sigma;
      }
    }
  }
  if (A.size(1) != 0) {
    double iMin;
    sigma = std::fmax(std::fmin(0.0, r3), r1);
    A.set_size(1, A.size(1));
    for (int k{0}; k < last_tmp; k++) {
      A[k] = A[k] - sigma;
    }
    iMin = r1 - sigma;
    sigma = r3 - sigma;
    std::frexp(std::fmax(std::abs(sigma), std::abs(iMin)), &eint);
    r1 = std::pow(2.0, static_cast<double>(eint) - 1.0);
    r3 = std::pow(2.0,
                  std::trunc((static_cast<double>(eint) + 1.0) / 2.0) - 1.0);
    if (iMin == sigma) {
      for (int k{0}; k < last_tmp; k++) {
        A[k] = 0.0;
      }
    } else {
      double c2;
      c2 = iMin / r1;
      iMin = 1.0 / (sigma / r3 - iMin / r3) / r3;
      sigma = r3 * ((0.0 - c2 * (1.0 / r3)) / (sigma / r1 - c2));
      A.set_size(1, A.size(1));
      for (int k{0}; k < last_tmp; k++) {
        A[k] = iMin * A[k] + sigma;
      }
      for (int k{0}; k < last_tmp; k++) {
        if (A[k] < 0.0) {
          A[k] = 0.0;
        }
      }
      for (int k{0}; k < last_tmp; k++) {
        if (A[k] > 1.0) {
          A[k] = 1.0;
        }
      }
    }
  }
}

} // namespace coder
void preprocess_ppg_pulse(const coder::array<double, 2U> &ppg_signal,
                          coder::array<double, 2U> &processed_ppg_signal)
{
  // PREPROCESS_PPG_PULSE Returns a processed copy of a PPG signal
  //  Normalize and rescale to [0, 1] range
  coder::normalize(ppg_signal, processed_ppg_signal);
  coder::rescale(processed_ppg_signal);
}

void preprocess_ppg_pulse_initialize()
{
}

void preprocess_ppg_pulse_terminate()
{
}

// End of code generation (preprocess_ppg_pulse.cpp)
