# SQLite Backend — Design Document

**Status:** Approved
**Date:** 2026-06-30
**Author:** james.stoup@upstart.com
**Extends:** [2026-06-30-simple-todo.md](2026-06-30-simple-todo.md)

---

## Problem / Background

The existing simple-todo app stores all todos in React component state (`useState`). Every page
refresh wipes the list. The goal of this feature is to add a lightweight persistence layer —
an Express server backed by SQLite — so todos survive page refreshes and server restarts.

The existing add/complete/delete behavior (FR-1 through FR-7 in the base spec) is preserved
unchanged. This spec extends that behavior with a backend and replaces FR-6 (in-memory reset
on refresh) with durable persistence.

---

## Goals & Non-Goals

**Goals**
- Persist todos to a local SQLite database across page refreshes and server restarts
- Add a minimal Express REST API that the React frontend calls for all CRUD operations
- Keep the server code simple using synchronous `better-sqlite3`
- Zero disruption to the existing UI and interaction model

**Non-Goals**
- User authentication or multi-user support
- Database migrations beyond initial schema creation on first start
- Production deployment configuration (Docker, env-based DB URLs, etc.)
- Multi-device or real-time sync
- Full-text search or filtering on the server

---

## Users / Personas

Same as the base spec: a single user running the app locally. Persistence benefit is within a
single machine and browser; no sharing or cross-device requirements.

---

## Functional Requirements

### Server

- **FR-1:** The Express server exposes `GET /api/todos` and returns all todos as a JSON array
  `[{ id, text, completed }, ...]` (empty array `[]` when none exist). Responds 200.

- **FR-2:** `POST /api/todos` accepts `{ "text": "<string>" }`. If `text` is missing or
  blank after trimming, the server responds 400 with `{ "error": "text is required" }` and
  creates no record. On success, inserts the todo with `completed: false`, responds 201 with
  the created todo `{ id, text, completed }`.

- **FR-3:** `PATCH /api/todos/:id` accepts `{ "completed": true|false }`. Updates the
  `completed` field for the identified todo and responds 200 with the updated todo
  `{ id, text, completed }`.

- **FR-4:** `DELETE /api/todos/:id` removes the identified todo and responds 204 No Content.

- **FR-5:** `PATCH /api/todos/:id` and `DELETE /api/todos/:id` respond 404 with
  `{ "error": "not found" }` when no todo with the given `id` exists.

- **FR-6:** On server startup, if `todos.db` does not exist, the server creates it and runs
  the schema: `CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0)`. No manual migration step required.

- **FR-7:** The server listens on port `3001` by default. The port is overridable via the
  `PORT` environment variable.

### React Frontend

- **FR-8:** On component mount, the React app fetches `GET /api/todos` and initializes local
  state from the response. The list reflects the persisted server state, not an empty array.

- **FR-9:** When a user submits a new todo, the frontend calls `POST /api/todos` with the
  trimmed text and appends the returned todo object (with its server-assigned `id`) to local
  state. The existing client-side empty-input guard (original FR-2) remains in place.

- **FR-10:** When a user toggles a checkbox, the frontend calls `PATCH /api/todos/:id` with
  the new `completed` value and updates that item in local state from the response.

- **FR-11:** When a user clicks delete, the frontend calls `DELETE /api/todos/:id` and removes
  that item from local state on a successful response.

- **FR-12:** The CRA `package.json` sets `"proxy": "http://localhost:3001"` so `/api/*`
  requests are forwarded to Express in development without CORS configuration.

---

## Non-Functional Requirements

- **NFR-1:** Server startup (including DB file creation and schema init) completes in under 2
  seconds on a standard laptop.
- **NFR-2:** Use `better-sqlite3` (synchronous API) — no callback or Promise chains on the
  server for DB calls.
- **NFR-3:** `todos.db` is stored at the project root and listed in `.gitignore`.
- **NFR-4:** The React app must not regress existing interaction behavior — add, toggle, and
  delete all work as before; only the storage layer changes.

---

## Acceptance Criteria / Success Metrics

- Adding a todo, refreshing the page, and seeing it still in the list.
- Marking a todo complete, refreshing, and seeing it remain checked.
- Deleting a todo, refreshing, and confirming it is gone.
- Starting with an empty DB, adding todos, restarting the server, and seeing all todos reload.
- Submitting an empty todo still does nothing (client guard unchanged).

---

## Scope

**In:**
- `server/index.js` — Express app with four REST endpoints
- `server/db.js` — `better-sqlite3` setup, schema init, and query helpers
- React `App.js` — replace `useState([])` with API-driven state
- `.gitignore` entry for `todos.db`
- `package.json` proxy entry

**Out:**
- Authentication, multi-user, categories, priorities, sorting, filtering
- Production deployment config
- Database migrations / versioned schema changes
- Any change to existing UI components or CSS

---

## Key Decisions & Rationale

| Decision | Choice | Rationale |
|---|---|---|
| SQLite driver | `better-sqlite3` | Synchronous API keeps server code simple; no async overhead for a single-user local app |
| Server framework | Express | Minimal boilerplate; widely understood; avoids hand-rolling HTTP routing |
| Server port | 3001 | Avoids conflict with CRA dev server on 3000 |
| API prefix | `/api/todos` | Namespaced to avoid collision with CRA's static asset routes |
| DB location | project root `todos.db` | Simple, no config needed; gitignored |
| Proxy | CRA `"proxy"` field | Eliminates CORS config in dev; zero extra tooling |
| FR-6 replacement | Persistence replaces in-memory reset | This feature explicitly inverts original FR-6 by design |

---

## Dependencies

- `express` — HTTP server
- `better-sqlite3` — synchronous SQLite driver
- Existing: Node.js, Create React App, React

---

## Open Questions

- None.
