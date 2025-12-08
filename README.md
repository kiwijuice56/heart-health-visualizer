# heart-health-visualizer

## Code organization
Currently, the project is split into three different domains:
- Godot/GDscript code that handles the app interface
- Generated C++ code (first written in MATLAB, then converted to C++ with codegen) that handles PPG scoring
- Manual C++ code that handles heart rate and heart rate variability calculations

The manual C++ code was written first, which is why it has some overlapping functionality (for example, smoothening a PPG signal).
Only the heart rate and heart rate variability calculations still use this manually written C++ code.

## MATLAB compilation
The PPG scoring algorithm is developed in MATLAB in a [separate repository](https://github.com/kiwijuice56/ppg-algorithm-matlab).

Note that the .coderproj file in that repository is already correctly configured to generate C++ code, but you can recreate it using the following steps:

Use the following settings when converting the MATLAB code into C++:
```
- Entry functions: All four scoring functions, `preprocess_ppg_signal` and `split_ppg_signal`
- Language: C++
- Code Appearance: Generate all functions into a single file
- Hardware: None - Select device below -> ARM compatible -> ARM 10
- All Settings -> Advanced -> Enable OpenMP set to false
```