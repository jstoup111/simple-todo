# Simple TODO List — Design Document

**Status:** Approved
**Date:** 2026-06-30
**Author:** james.stoup@upstart.com

---

## Problem / Background

Developers and individuals need a lightweight, no-friction way to track tasks in a browser session. This is a minimal MVP to establish a working React project on GitHub with basic task management.

---

## Goals & Non-Goals

**Goals**
- Allow a user to add, complete, and delete todos in a single browser session
- Provide a clean, usable UI with no account or login required
- Establish a working Create React App project hosted on GitHub

**Non-Goals**
- Persistence across page refreshes (localStorage, database, or backend)
- User authentication
- Multiple lists or categories
- Due dates, priorities, or tags
- Drag-and-drop reordering

---

## Users / Personas

**Primary:** A single user (the repo owner) who wants a quick, personal task list during a work session. No multi-user or sharing requirements.

---

## Functional Requirements

- **FR-1:** A user can type text into an input field and submit it (Enter key or button click) to add a new todo item to the list.
- **FR-2:** Submitting an empty or whitespace-only input does nothing (no empty todo is added).
- **FR-3:** Each todo item displays its text and a checkbox. Checking the checkbox marks the item as complete (visually distinct — e.g., strikethrough).
- **FR-4:** A completed todo can be unchecked to restore it to incomplete.
- **FR-5:** Each todo item has a delete button. Clicking it removes the item from the list immediately.
- **FR-6:** The todo list is held entirely in React component state (`useState`). Refreshing the page resets the list to empty.
- **FR-7:** The input field is cleared after a successful todo submission.

---

## Non-Functional Requirements

- **NFR-1:** App loads and is interactive within 3 seconds on a standard laptop on localhost.
- **NFR-2:** No external state management library (Redux, Zustand, etc.) — plain `useState` only.
- **NFR-3:** Bootstrapped with Create React App (`npx create-react-app`).

---

## Acceptance Criteria / Success Metrics

- User can add a todo, see it appear in the list, mark it complete, and delete it — all without a page refresh.
- Empty submissions are silently ignored.
- The app runs locally via `npm start` and builds without errors via `npm run build`.

---

## Scope

**In:**
- Add todo (text input + submit)
- Complete/uncomplete todo (checkbox)
- Delete todo (button)
- In-memory state only

**Out:**
- Persistence, auth, categories, priorities, sharing, sorting, filtering

---

## Key Decisions & Rationale

| Decision | Choice | Rationale |
|---|---|---|
| Build tool | Create React App | Operator's explicit choice; familiar, well-documented |
| State | `useState` (local) | MVP — no persistence needed, no external lib overhead |
| Persistence | None (in-memory) | Explicit MVP decision; can be added in a future iteration |

---

## Dependencies

- Node.js (for CRA dev server and build)
- `create-react-app` (npx)
- GitHub for hosting the repo (already created: `jstoup111/simple-todo`)

---

## Open Questions

- None for this MVP scope.
