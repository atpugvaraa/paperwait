# paperwait

**Status:** *successfully defying planned obsolescence.*

paperwait turns any old iOS device into a low-latency, peer-to-peer digitizer and trackpad for macOS. Built entirely in Objective-C because we respect the runtime.

![Project Status](https://img.shields.io/badge/status-experimental-orange)
![Language](https://img.shields.io/badge/language-Objective--C-blue)

## The Reason
I had an iPad Mini 4 stuck on iPadOS 15.8.5. It was too slow for modern apps but the screen was perfect. Instead of letting it become e-waste, I wrote a custom protocol to bridge `UIKit` touches directly to `CoreGraphics` hardware events.

No servers, no subscriptions, no bloat. Just a raw UDP-like stream of coordinate data.

## Features
- **Zero-Config P2P:** Auto-discovery via `MultipeerConnectivity`.
- **Hybrid Input Modes:**
    - **Drawing Mode:** Absolute 1:1 mapping (Wacom style).
    - **Trackpad Mode:** Relative cursor movement with acceleration.
- **Gestures:**
    - **1-Finger:** Draw / Move Cursor.
    - **2-Finger Tap:** Left Click.
    - **2-Finger Pan:** Inertial Scrolling.
- **Headless Receiver:** Runs as a background agent (LSUIElement) with no dock icon or window.

## Architecture
This project uses a shared source pattern to keep the protocol in sync between iOS and macOS without dylib hell.

- **Sender (iOS):** Captures raw touch events and normalizes coordinates (0.0 - 1.0). Handles gesture conflict resolution between scrolling and drawing.
- **Receiver (macOS):** A purely programmatic `NSApplication` (no Storyboards). It acts as a virtual HID driver, injecting events directly into the system event tap.
- **Protocol:** Custom byte-packed strings sent via MCSession's `.unreliable` mode (UDP behavior) for maximum throughput.

## Build Instructions

### Prerequisites
- Xcode (Tested on 15+)
- An iPad and a Mac on the same network (or connected via USB).

### Setup
1. Clone the repo:
```bash
   git clone https://github.com/atpugvaraa/paperwait.git
   open paperwait.xcworkspace
```

2. Permission (Critical):
- Receiver: You must grant Accessibility permissions to the build artifact (or Xcode) in System Settings > Privacy & Security > Accessibility to allow cursor control.

- Sender: Allow "Local Network" access when prompted on the iPad.

3. Build:
- Select `Receiver` scheme -> Run (Mac). It runs in the menu bar.
- Select `Sender` scheme -> Run (iPad).

### Usage
1. Launch the Receiver on your Mac. You'll see a small iPad icon in the menu bar.
2. Launch the Sender on your iPad. It will auto-connect.
3. Toggle Mode: Use the switch on the iPad UI.
- Trackpad Mode: Use it like a giant MacBook trackpad.
- Cursor Mode (Off): The iPad screen maps 1:1 to your Mac screen.
