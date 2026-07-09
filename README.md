# CodeSense - AI Code Review Assistant

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11.5-blue?logo=dart)
![Gemini AI](https://img.shields.io/badge/Gemini-1.5%20Flash-orange?logo=google)
![License](https://img.shields.io/badge/License-MIT-green)

> Write better code, ship with confidence

## About
CodeSense is an AI-powered Flutter app that reviews your code instantly, detecting bugs, suggesting improvements, and providing corrected code with explanations. Built for developers who want to ship better code faster.

## Screenshots
Screenshots coming soon

## Features
- Paste any code in any programming language
- Auto language detection by AI
- Manual language override with 15+ languages supported
- AI gives code quality score 0-100 with animated circle
- Bug detection with severity levels: critical, warning, minor
- Best practice improvement suggestions
- Complete fixed and corrected code with syntax highlighting
- Plain English explanation of all issues
- Copy fixed code to clipboard with animation
- Save full review history locally with Hive
- Share complete report as text
- Onboarding slides on first launch
- Cyan and Midnight premium dark UI

## Supported Languages
JavaScript, Python, Java, Dart, C++, C#, Go, Rust, PHP, TypeScript, Kotlin, Swift, Ruby, HTML, CSS

## Tech Stack
| Technology | Purpose |
|---|---|
| Flutter 3.41.9 | UI framework |
| Dart 3.11.5 | Programming language |
| Gemini AI 1.5 Flash | AI code analysis |
| Hive | Local storage |
| flutter_highlight | Syntax highlighting |
| share_plus | Export and share |
| google_fonts | Poppins and JetBrains Mono |

## Getting Started
git clone https://github.com/guntimadhu/codesense.git
cd codesense
flutter pub get

Add your Gemini API key in lib/services/gemini_service.dart

flutter run

## How to Use
1. Tap + to start a new review
2. Paste your code in the editor
3. Select language or let AI auto-detect
4. Tap Review with AI
5. View bugs, improvements, and fixed code
6. Copy fixed code and save review history

## Contributing
Contributions are welcome!

## License
MIT License
