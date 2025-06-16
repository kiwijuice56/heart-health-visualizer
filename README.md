## MATLAB compilation
The PPG scoring algorithm is developed in MATLAB in a [separate repository](https://github.com/kiwijuice56/ppg-algorithm-matlab).

Use the following settings when converting the MATLAB code into C++:
```
- Entry Function: score_ppg_signal, with one parameter of type double (1 x :Inf)
- Language: C++
- Code Appearance: Generate all functions into a single file
- Hardware: None - Select device below -> ARM compatible -> ARM 10
- All Settings -> Advanced -> Enable OpenMP set to false
```