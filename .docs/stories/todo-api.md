# Stories: Todo API

**Feature:** Todo API  
**Design doc:** `docs/specs/2026-04-01-todo-api.md`  
**Status:** Draft

---

## Story 1: Create a Todo

As an API consumer, I want to POST a new todo so that it is persisted and I receive its id for
future use.

### Acceptance Criteria

#### Happy Path
- Given a valid request body `{ "todo": { "title": "Buy milk" } }`, when `POST /api/todos` is
  called, then the response is `201 Created` with JSON containing `id`, `title: "Buy milk"`,
  `done: false`, `created_at`, and `updated_at`
- Given the response includes an `id`, when no further requests are made, then a row exists in
  the `todos` table with the correct `title` and `done: false`

#### Negative Paths
- Given a request body with a blank title `{ "todo": { "title": "" } }`, when `POST /api/todos`
  is called, then the response is `422 Unprocessable Entity` with body
  `{ "errors": { "title": ["can't be blank"] } }` and no record is saved
- Given a request body with unexpected extra params `{ "todo": { "title": "ok", "done": true,
  "admin": true } }`, when `POST /api/todos` is called, then the response is `201 Created`,
  `done` is `false` (default), and `admin` is ignored (mass assignment protection)

### Done When
- [ ] `POST /api/todos` with valid title returns `201` with JSON matching
      `{ id: Integer, title: String, done: false, created_at: ISO8601, updated_at: ISO8601 }`
- [ ] A `todos` row is persisted in the database with the correct `title` and `done: false`
- [ ] `POST /api/todos` with blank title returns `422` with `{ "errors": { "title": [...] } }`
- [ ] No record is saved when title validation fails
- [ ] Extra params (`done`, arbitrary keys) are ignored — `done` stays `false` on create

---

## Story 2: Mark a Todo as Done

As an API consumer, I want to PATCH a todo's complete endpoint so that its `done` flag is set
to `true`.

### Acceptance Criteria

#### Happy Path
- Given a todo with `id: 1` and `done: false` exists, when
  `PATCH /api/todos/1/complete` is called (no body required), then the response is `200 OK`
  with JSON containing `id: 1`, `done: true`, and an updated `updated_at`
- Given `PATCH /api/todos/1/complete` is called on a todo that is already `done: true`,
  when the request completes, then the response is `200 OK` and `done` remains `true`
  (idempotent — no error)

#### Negative Paths
- Given no todo with `id: 9999` exists, when `PATCH /api/todos/9999/complete` is called,
  then the response is `404 Not Found` with body `{ "error": "Not found" }` and no database
  change occurs

### Done When
- [ ] `PATCH /api/todos/:id/complete` on an existing todo returns `200` with
      `{ id: Integer, title: String, done: true, created_at: ISO8601, updated_at: ISO8601 }`
- [ ] The `todos` row in the database has `done: true` after the request
- [ ] Calling complete on an already-done todo returns `200` (idempotent, no error)
- [ ] `PATCH /api/todos/9999/complete` (non-existent id) returns `404` with
      `{ "error": "Not found" }`
