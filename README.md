# CORDIC Algorithm in RISC-V
This repository contains implementation of the [CORDIC (COordinate Rotation DIgital Computer)](https://en.wikipedia.org/wiki/CORDIC) algorithm written entirely in standard RISC-V assembly. **Without using any floating-point instructions**, this code computes the sine and cosine of a user-specified angle using only fixed-point arithmetic.
The program prompts the user for an angle in degrees and computes both the sine and cosine of that angle using bit-shifts, additions, and a pre-computed Look-Up Table (LUT), **avoiding computationally expensive multiplications**.

#### Example output:

```
Enter degrees: 52
```

```
in_Q229:
cos: 330531997
sin: 423061683
Z = 0

Human readable:
cos: 0.61566382087767124176025390625
sin: 0.788013791665434837341308593750
-- program is finished running (0) --
```

#### Another example:
```
Enter degrees: 69
```
```
in_Q229:
cos: 192398051
sin: 501214106
Z = -1

Human readable:
cos: 0.35836929641664028167724609375
sin: 0.93358402326703071594238281250
-- program is finished running (0) --
```

## Key points and features

* **Precision:**
    Executes 30 iterations, achieving a precision of approximately 5 decimal places.
* **Fixed-Point Arithmetic:**
    Operates primarily in the `Q2.29` fixed-point format, allocating 2 bits for the integer component and 29 bits for the fractional component (may be suboptimal, Q1.30 could have yielded better precision because there is no number greater than 1)
* **Binary Angular Measurement (BAM):**
    Utilizes BAM for the internal representation of angles, greatly simplifying angle normalization and arithmetic.
* **Result Formatting:**
    Incorporates an integer-to-fractional printing routine that decodes the Q2.29 format into a float string without relying on floating-point hardware extensions.

## Prerequisites and environment

1. Install Java (Required to execute RARS):
   ```bash
   sudo apt update && sudo apt install default-jre
    ```
2. Download the latest rars.jar (at the time of writing, the latest version is 1.6) release from the official [GitHub repository](https://github.com/TheThirdOne/rars).
3. Run the `cordic.asm` file inside bash:
    ```bash
    java -jar rars1_6.jar sm cordic.asm
    ```

4. Alternatively, you can run it inside the RARS IDE:
   ```bash
   java -jar rars1_6.jar
   ```
   - then open the `cordic.asm` file, assemble (F3) and execute it (F5).


## Implementation Details
#### The Look-Up Table (LUT)
The atan_LUT array stores pre-calculated arctangent values for powers of 2 (from 2^-0 down to 2^-29). These values are scaled into Binary Angular Measure (BAM) where, given 32-bit registers, $1^\circ$ is represented as approximately `11930464.711`.

#### Data Flow
- Input & Normalization: The user's integer input (degrees) is multiplied by `11930465` to convert it into BAM format.
The system then evaluates the angle, normalizing it if it exceeds the standard quadrant boundaries as CORDIC is convergent on approx. `(-99.7, 99.7)` -- the sum (or difference) of all angles in the LUT.

- Iterative Rotation: The mainloop iterates 30 times. Each time, the angle at the current iteration index $i$ is added (or subtracted) from the pseudo-vector ($X$, $Y$) depending on the sign of the compass $Z$ (tells the difference between the current angle and the target angle).

- Output Decoding: After the mainloop, the raw Q2.29 coordinates are printed. Then the program isolates the integer portion via a right arithmetic shift (srai) and extracts the 29-bit mantissa using a bitmask. The mantissa is iteratively multiplied by 10 and printed as `CON_PUTINT` to simulate fractional decimal printing.

## Conclusion
This implementation of the CORDIC algorithm in RISC-V assembly demonstrates how to compute trigonometric functions using fixed-point arithmetic and a LUT, without relying on floating-point hardware. The code is structured to be educational, showcasing the core principles of CORDIC while also providing a practical example of how to handle fixed-point arithmetic and angle normalization in a low-level programming context.
