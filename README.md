# Calculator App: Phase 3

## Project Overview
The Calculator App is a Flutter project developed as part of Phase 3 of my internship at GeniuSoft. This project focuses on State Management and Forms in Flutter.

## Features
- Simple and user-friendly calculator interface.
- Basic arithmetic operations: addition, subtraction, multiplication, and division.
- Input form for entering numbers and selecting operations.
- Input validation.
- Handling division by zero.
- Splash screen.
- Custom calculator app icon configuration.
- Light purple, white, and pink colour theme.

## What I Learned
- State Management using StatefulWidget and setState().
- Creating forms and validating user input.
- Performing arithmetic calculations using Dart.
- Organizing code into separate files and reusable widgets.
- Configuring a custom Android launcher icon.

## Problems Faced and Solutions
- **Project Structure:** Organized the code into separate screens and reusable widgets.
- **State Management:** Used setState() to update the interface in response to user actions.
- **Input Validation:** Added validation to check numerical input before calculations.
- **App Icon:** Configured the flutter_launcher_icons package to generate a custom Android launcher icon.
- **Calculation Result Formatting:** Whole-number operands were displaying unnecessary decimal points, such as 5.0 + 3.0 =. Updated the formatting logic to display 5 + 3 = and the result as 8, while preserving decimal values when needed.
- **Live Calculation Result:**
Problem: The calculator displayed the final answer only after the user pressed the equals (=) button. The mentor suggested improving the calculator so that the result would be visible before pressing equals, similar to professional calculators.
Solution: A live calculation preview is being implemented to display the result as the user enters the second operand. Further testing is required to confirm that the feature works correctly for addition, subtraction, multiplication, and division.

## Conclusion
This project helped me practise State Management, Forms, input validation, and basic calculations in Flutter. It also improved my understanding of Flutter project organization and reusable widgets.
