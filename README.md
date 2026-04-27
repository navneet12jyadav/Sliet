# Campus by APEX

A minimalist mobile application for college students to simplify daily campus life.

## Features

### Core Screens (Bottom Navigation)

| Tab | Description |
|-----|-------------|
| **Today** | Daily class timetable with cyclic day system. Swipe left/right to browse calendar days. |
| **Tomorrow** | Next-day class preview with summary card showing total class count. |
| **Mess** | Hostel-wise mess timetable showing Breakfast, Lunch, and Dinner menus with timing. |
| **Profile** | Digital student ID card + student details. Quick-link to bus schedule. |

### Additional Features
- **Bus Schedule** – College bus timings from the campus bus stop (accessible from Profile).
- **Official Notices** – Announcements, holidays, and exam notices (accessible from drawer).
- **Campus Directory** – Locations with Google Maps integration (accessible from drawer).

## Architecture

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | Riverpod (`flutter_riverpod`) |
| Backend / Database | Firebase Firestore (real-time) |
| Authentication | Firebase Auth (registration number login) |
| Fonts | Google Fonts (Poppins) |

## Firestore Collections

```
users/                          # Student profiles
  {uid}: { name, role, registrationNo, hostelNo, ... }

timetable_config/
  config: { startDate, totalDays, holidays[] }

timetable/
  day_1: { dayNumber: 1, classes: [{ subject, time, location, instructor, type }] }
  day_2: { ... }
  ...

mess_menus/
  monday / tuesday / ...:       # Global menu (fallback)
    { breakfast, lunch, dinner }
  BH-1_monday / BH-1_tuesday / ...:  # Hostel-specific menus
    { breakfast, lunch, dinner }

bus_schedules/
  {routeId}: { routeName, description, timings: [{ departureTime, destination }] }

notices/
  {noticeId}: { title, content, category, datePosted }

trending_issues/
  {issueId}: { authorName, content, timestamp }

placements/
  {id}: { alumniName, company, role, batch, advice }

valid_registrations/
  {regNo}: { isClaimed: bool }
```

## Authentication Flow

1. Student registers with their **Registration Number** (validated against `valid_registrations` collection).
2. Firebase Auth is used with a hidden email domain (`{regNo}@sliet.app`).
3. After first login, student is prompted to complete their profile (name, hostel, branch, etc.).
4. On subsequent logins, they land directly on the **Student Dashboard**.

## Cyclic Day System

The timetable uses a cyclic day system (Day 1, Day 2, ..., Day N):

- **Config** stored in `timetable_config/config` with `startDate` and `totalDays`.
- **Cyclic day** = `((currentDate - startDate).days % totalDays) + 1`
- **Holidays** are stored as ISO date strings in the `holidays` array.
- Students can swipe left/right in the Today tab to view any day.

## Getting Started

1. Set up a Firebase project and enable **Firestore** + **Firebase Auth**.
2. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
3. Seed Firestore with timetable config, class data, mess menus, and bus schedules.
4. Run `flutter pub get && flutter run`.

## Folder Structure

```
lib/
  controllers/
    auth_controller.dart    # Auth + user data Riverpod providers
    data_controller.dart    # Timetable, mess menu, bus schedule providers
  models/
    user_model.dart
    timetable_model.dart    # ClassEntry, TimetableDay, TimetableConfig
    mess_menu.dart
    bus_schedule_model.dart # BusRoute, BusTiming
    notice_model.dart
    placement_model.dart
    issue_model.dart
  screens/
    auth/                   # Login, Signup, CompleteProfile
    dashboards/             # StudentDashboard (4-tab navigation)
    timetable/              # TodayTab, TomorrowTab
    mess/                   # MessTab
    profile/                # ProfileTab (Digital ID Card)
    bus/                    # BusScheduleScreen
    notices/                # NoticeBoardScreen
    map/                    # CampusMapScreen
  services/
    auth_service.dart
  firebase_options.dart
  main.dart
```
