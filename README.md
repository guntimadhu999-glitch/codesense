<div align="center">

# CodeSense 🔍⚡

### *Write better code, ship with confidence*

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini-1.5%20Flash-4285F4?style=for-the-badge&logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-22D3EE?style=for-the-badge)

</div>

---

## ✨ About

**CodeSense** is an AI-powered code review assistant built with Flutter and Google Gemini 1.5 Flash. Paste any code snippet, select your language (or let the AI auto-detect it), and get an instant quality score, bug report, best-practice suggestions, and a fully corrected version of your code — all in a sleek GitHub-dark inspired UI.

---

## 📱 Screenshots

> Screenshots coming soon

---

## 🚀 Features

- 🔍 **AI Code Review** — Paste any code and get an instant, detailed analysis powered by Gemini 1.5 Flash
- 📊 **Quality Score** — Animated circular gauge (0–100) with spring easing and color-coded bands (🟢 ≥75 / 🟡 50–74 / 🔴 <50)
- 🐛 **Bug Detection** — Severity-tagged bug cards (🔴 Critical / 🟡 Warning / 🔵 Minor) with line references and descriptions
- 💡 **Improvement Suggestions** — Numbered best-practice tips with staggered fade-in animations
- ✅ **Fixed Code** — Complete corrected code with `atom-one-dark` syntax highlighting via `flutter_highlight`
- 📋 **Copy to Clipboard** — One-tap copy with a 📋 → ✅ icon morph animation (reverts after 1.5s)
- 🌐 **Auto Language Detection** — AI identifies the language; manual override available via dropdown
- 💾 **Review History** — All reviews saved locally with Hive; browse, re-analyze, or delete past reviews
- 🗑️ **Soft Delete + Undo** — 7-second undo toast so you never lose a review by accident
- 📤 **Share Report** — Export the full review (score, bugs, suggestions, fixed code) as plain text
- 🔄 **Re-Analyze** — Go back to New Review with your original code pre-filled for quick edits
- 🎬 **Onboarding Flow** — 4-slide intro with animated dot-pill indicator (first launch only)
- 🌙 **Dark-First Design** — Midnight black + cyan accent color scheme built for developers
- 🔔 **Sound Toggle** — Optional sound effect on review complete

---

## 🛠️ Tech Stack

| Technology | Version / Package |
|---|---|
| **Flutter** | 3.41.9 |
| **Dart** | 3.11.5 |
| **AI Model** | Google Gemini 1.5 Flash |
| **Local Storage** | `hive` + `hive_flutter` |
| **Syntax Highlighting** | `flutter_highlight` (atom-one-dark theme) |
| **Share** | `share_plus` |
| **Fonts** | `google_fonts` — Poppins (UI) + JetBrains Mono (code) |
| **Networking** | `http` |
| **Date Formatting** | `intl` |
| **Audio** | `audioplayers` |

---

## 🌐 Supported Languages

Auto-Detect · JavaScript · TypeScript · Python · Java · Dart · C++ · C# · Go · Rust · PHP · Kotlin · Swift · Ruby · Bash

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK 3.41+ installed
- A [Google AI Studio](https://aistudio.google.com) API key for Gemini

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/codesense.git
cd codesense

# 2. Install dependencies
flutter pub get

# 3. Add your Gemini API key
#    Open lib/services/gemini_service.dart and replace the key:
#    const _apiKey = 'YOUR_GEMINI_API_KEY';

# 4. Run the app
flutter run
```

> **Supported targets:** Android, iOS, Web, Windows, macOS, Linux

---

## 📖 How to Use

1. **Launch** the app — watch the splash screen and complete the one-time onboarding
2. **Tap +** on the Home screen to open a new review
3. **Paste your code** into the dark editor area
4. **Select a language** from the dropdown, or leave it on *Auto-Detect*
5. **Tap "🔍 Review with AI"** — the button shimmers while Gemini analyzes your code
6. **View your results:**
   - Animated quality score ring at the top
   - Bug cards with severity badges, sliding in one by one
   - Numbered improvement suggestions
   - Full corrected code with syntax highlighting
   - Plain-English explanation of what was wrong and why the fix works
7. **Copy the fixed code** with one tap (📋 → ✅ animation)
8. **Share the report** via any app using the 📤 button
9. **Review saved automatically** — find it in History on the Home screen

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ using Flutter & Google Gemini AI

*CodeSense v1.0.0 — AI Code Review Assistant*

</div>
