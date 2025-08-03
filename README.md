# 🎵 MusicPlayer

A code challenge developed for Music.AI as part of the hiring process.<br/> 
This app allows users to search for songs through the Apple iTunes API and play previews in a clean, responsive interface.

## 📌 Overview
The project was built following the given requirements:

✅ Usage of Swift 6<br/>
✅ MVVM architecture pattern<br/>
✅ Tests implementation<br/>
✅ API results pagination

Additionally, some optional features were implemented (see Extra Features).

## 📱 Screens & Features
* Splash Screen
* Songs Screen (Home) with search and pagination
* Song Details (Player) with mini-player integration
* More Options Menu
* Album Screen

## 🚀 How to Run
1. Clone this repository
1. Open the project in Xcode 16+
1. Run on a simulator or a physical device with iOS 18+

No additional dependencies are required

## 🎨 Design Differences
While the core design was followed, some adjustments were made for usability and technical feasibility:

* The mini-player was added for smoother user experience
* The `More Options` screen was turned into a menu, `Song Details` into the expandable mini-player, and `Album` into a navigation stack screen. These changes improved the user experience and addressed some technical challenges (see Challenges & Solutions).
* Some spacing, font sizes, and UI details were adapted to fit Apple’s Human Interface Guidelines

My initial idea was to create two branches, one with the expected design and another with the mini-player, but due to lack of time that was not possible.

## 📚 References & Inspiration
To implement certain parts of the app, I drew inspiration from external resources:

- Mini-player adapted from a YouTube tutorial by Kavsoft - 
[SwiftUI Bottom Sheet like Apple Music App](https://www.youtube.com/watch?v=vqPK8qFsoBg)

## 🛠 Challenges & Solutions
During development, I faced some challenges:

### API Limitations:

The iTunes Search API isn't consistent with the documentation.

### Album Screen:

- On the `lookup` request `limit` and `offset` don't work, also, even while sending the `entity` parameter as `song` and `media` as `music`, on some albums some music videos are present, something that could impose problems as they don't always have a preview URL.

✅ **Solution**: When looking up some albums where lookup request returns a music video like Panic! At the Disco - Pretty. Odd. (Deluxe Version), where the last song, Mad As Rabbits, does not have a preview URL, the song is not selectable on the album Screen and not present on the playlist while the album songs are playing.

### Pagination Handling:

- On the documentation, the `offset` parameter used for pagination is not mentioned. It doesn't seem reliable as well, using it for pagination sometimes results in duplicated songs.
- The `limit` parameter seems to only work as intended on really small values (1-3). When using other values, the API can return more than the chosen limit.

✅ **Solution**: Instead of relying on the consistency of the `limit` property value, the next page requests keep being made after the user scrolls to the bottom while the request returns results, only being stopped when a request returns 0 results.

### Mini-player Behavior

- When the mini-player is present, opening the keyboard or a bottom sheet overlapped the mini-player, making it a bad user experience.

✅ **Solution**: Added a notification observer for when the keyboard is opened and closed, so the windowLevel property of the mini-player can decrease while the keyboard is open, and then go back to the expected level after the keyboard is dismissed.

This was also my first experience with Apple’s Testing framework, which required me to quickly adapt and learn its differences compared to traditional XCTest unit tests.

## ➕ Extra Features
- Error/States handling
- Swipe to refresh
- Swift concurrency
- Repository organization
- Dark and light mode design
- On the player screen:
	- Forward/Backward actions
	- Slider action to seek a specific position
	- Shuffle and Repeat options

## 🔮 If I Had More Time
With additional time, I would have liked to implement:

- Increase song streaming speed while pressing the forward button, and reverse the song while pressing the backwards button
- Create more unit tests
- Offline caching for recently played tracks
- UI tests with XCTest and snapshot testing
- More detailed error handling with retry mechanisms
- Create playlists
- Share songs with deeplinks
- Create a tab for looking at a favorite songs list

## 🛠 Tech Stack
- Swift 6
- SwiftUI
- Combine / Concurrency (async/await)
- Swift Testing for Unit Testing

---
Thanks for taking the time to review this project!  
I’d be happy to discuss the implementation details and decisions further. 
