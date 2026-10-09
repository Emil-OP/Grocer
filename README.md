# Grocer

A native iOS grocery list app for shoppers in the Dominican Republic, built with SwiftUI and a self-hosted Node.js/PostgreSQL backend.

> **Status: Work in progress.** This is my personal learning project. I started it right after finishing an online SwiftUI course, with no prior Swift experience — it's where I've been teaching myself iOS development, backend fundamentals, and how the two talk to each other. Expect rough edges, `TODO`s, and ongoing refactors; see [What's next](#whats-next) below.

## About

Grocer lets you build grocery lists from real product data scraped from local Dominican supermarkets (Jumbo, Nacional, PriceSmart, Sirena), then shop against them with live price totals and progress tracking. The idea came from wanting an easier way to compare prices across supermarkets while keeping a running shopping list — but the real goal of this repo is to document my growth as I go from "finished a SwiftUI course" to building something full-stack and production-shaped.

## Features

- **Account & auth** — register/login against a REST API, with JWT access + refresh tokens persisted securely in the iOS Keychain
- **Product catalog** — paginated, searchable product list pulled from a PostgreSQL database, grouped by supermarket with price and unit of measurement
- **Grocery lists** — create multiple named lists, add products with quantities, and toggle lists active/inactive
- **Master shopping view** — active lists are merged into a single list sorted by supermarket, so you can shop efficiently store by store
- **Purchase tracking** — mark items as purchased/unpurchased and see each list's completion as a percentage, with an animated progress ring
- **Modern SwiftUI UI** — built against iOS 26's SwiftUI, including the new Liquid Glass (`glassEffect`) styling
- **Unit tests** — Swift Testing coverage for model logic (e.g. completion-percentage math) and the repository layer

## What's next

Things I'm actively working through, in no particular order:

- Home tab is still a placeholder
- Keychain persistence for tokens is mid-refactor (see `AuthManager`)
- Debouncing search input instead of firing a request per keystroke
- Properly removing a list reference from a shared `GroceryListItem` when it's deleted from one list
- Tightening up API error handling and loading/empty states

## Tech stack

**iOS app**
- Swift 5 / SwiftUI, targeting iOS 26+
- `@Observable` (Observation framework) for state management
- Swift Testing for unit tests
- `URLSession` for networking, Keychain Services for token storage

**Backend (`grocerAPI/`)**
- Node.js + Express REST API
- PostgreSQL for persistence
- JWT access/refresh tokens, with passwords and refresh tokens hashed via `bcrypt`

## Architecture

The app follows a layered structure to keep SwiftUI views thin:

```
Views        — SwiftUI screens, no business logic
Repository   — @Observable in-memory store the views bind to
Service      — talks to the REST API, decodes responses into models
Models       — Codable domain types (Product, GroceryList, GroceryListItem)
Auth         — AuthManager + Keychain-backed token storage
```

`grocerAPI/` is a separate Express + PostgreSQL service that the app talks to over HTTP; see `grocerAPI/README.md` for its own setup notes.

## Running it locally

1. **Backend**
   ```bash
   cd grocerAPI
   npm install
   # configure a local PostgreSQL database and a .env with JWT_SECRET, JWT_REFRESH_SECRET, and DB credentials
   node api.js
   ```
2. **iOS app**
   - Open `Grocer.xcodeproj` in Xcode (26+)
   - `Development.xcconfig` points `BASE_URL` at `http://localhost:3300` by default
   - Build and run on the simulator

## Why this project is public as-is

This repo is intentionally left visible mid-progress rather than polished and hidden until "done." It's meant to show how I work, how I structure a SwiftUI app, and how my code has evolved — not just a finished product.
