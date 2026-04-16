# DeepFocus

A modern, distraction-free focus timer app built with SwiftUI, designed to help users maintain productivity and track their focus sessions effectively.

## Features

- **Focus Timer**: Customizable focus sessions with 15, 25, and 45-minute options
- **Task Management**: Add up to 3 core tasks per day and track their completion
- **Distraction Tracking**: Log distractions with categorized reasons for better self-awareness
- **Rest Mode**: Automatic 5-minute rest period after each focus session
- **Detailed Stats**: Weekly focus trends and insights to help improve productivity
- **Beautiful UI**: Modern, clean interface with smooth animations and transitions

## Screenshots

<img src="./docs/home.png" width="200"><img src="./docs/task.png" width="200"><img src="./docs/add_task.png" width="200"><img src="./docs/warning.png" width="200">

<img src="./docs/home_dark.png" width="200"><img src="./docs/task_dark.png" width="200"><img src="./docs/add_task_dark.png" width="200"><img src="./docs/warning_dark.png" width="200">


## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/deepfocus.git
cd deepfocus
```

2. Open the project in Xcode:

```bash
open deepfocus.xcodeproj
```

3. Build and run the app on a simulator or physical device.

## Usage

1. **Home Screen**: View daily stats and add core tasks
2. **Start Focus**: Select a duration and begin your focus session
3. **During Focus**: Track time remaining and mark distractions if needed
4. **Rest Period**: Take a 5-minute break after each focus session
5. **Stats View**: Review weekly trends and insights

## Project Structure

```
deepfocus/
├── Assets.xcassets/         # App icons and colors
├── Design/                  # Design system and styles
├── Models/                  # Data models
├── Store/                   # State management
├── Views/                   # UI views
│   ├── ContentView.swift    # Main navigation
│   ├── FocusTimerView.swift # Focus timer interface
│   ├── HomeView.swift       # Home screen
│   ├── RestView.swift       # Rest period interface
│   └── StatsView.swift      # Statistics and insights
└── deepfocusApp.swift       # App entry point
```

## Key Components

- **FocusStore**: Observable class managing app state and data persistence
- **Task Management**: Add, toggle, and delete daily tasks
- **Focus Sessions**: Track focus time and distractions
- **Statistics**: Generate daily and weekly focus data
- **UI Components**: Custom button styles and animations

## Technology Stack

- SwiftUI for UI development
- Observable for state management
- UserDefaults for data persistence
- Charts for data visualization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Inspired by the Pomodoro Technique
- Designed with a focus on user experience and productivity
- Built with SwiftUI's modern declarative syntax