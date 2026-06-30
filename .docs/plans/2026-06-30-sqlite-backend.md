# Implementation Plan: SQLite Backend

**Date:** 2026-06-30
**Design:** [.docs/specs/2026-06-30-sqlite-backend.md](../specs/2026-06-30-sqlite-backend.md)
**Stories:** [.docs/stories/sqlite-backend.md](../stories/sqlite-backend.md)
**Conflict check:** Skipped — Tier S

---

## Summary

Adds an Express + `better-sqlite3` backend to the simple-todo app and wires the React frontend
to call the API for all CRUD operations. 19 tasks covering infrastructure, four server endpoints
(each with happy and negative paths), and four React mutations.

---

## Technical Approach

- **`server/db.js`** — exports `createDb(path)` and four query helpers (`getAllTodos`,
  `createTodo`, `updateTodo`, `deleteTodo`). `createDb` accepts a path so tests pass
  `':memory:'` and production passes `'./todos.db'`. Schema creation uses
  `CREATE TABLE IF NOT EXISTS`.

- **`server/index.js`** — exports a `createApp(db)` factory that returns a configured Express
  app. The `require.main === module` guard boots the real server with a disk DB. This pattern
  allows `supertest(createApp(testDb))` without actually binding a port in tests.

- **React `App.js`** — `useEffect` replaces the empty-array `useState` initializer with a
  `GET /api/todos` fetch on mount. Each mutation (`add`, `toggle`, `delete`) calls the
  corresponding endpoint and updates state from the response. The existing client-side
  whitespace guard is preserved.

- **CRA proxy** — `"proxy": "http://localhost:3001"` in `package.json` forwards `/api/*` to
  Express in dev; no CORS config needed.

- **Test tooling:** Server tests use `supertest` (added as `devDependency`). React tests mock
  `global.fetch` via `jest.fn()` — no new libraries.

- **Sequencing:** DB layer → server endpoints (happy then negative) → React mutations (happy
  then negative) → integration/persistence.

---

## Prerequisites

- Node.js and npm available
- `npm install` run in project root before task 1

---

## Tasks

### Task 1: Add dependencies, proxy, and .gitignore entry
**Story:** FR-7, FR-12 (Story 5 — infrastructure)
**Type:** infrastructure

**Steps:**
1. No test needed for this task (pure config)
2. Run `npm install express better-sqlite3` and `npm install --save-dev supertest`
3. Add `"proxy": "http://localhost:3001"` to `package.json`
4. Append `todos.db` to `.gitignore`
5. Commit: `chore: add express, better-sqlite3, supertest; wire CRA proxy`

**Files likely touched:**
- `package.json` — add proxy field and new deps
- `.gitignore` — add todos.db

**Dependencies:** none

---

### Task 2: Create server/db.js — DB init and query helpers
**Story:** Story 5, FR-6
**Type:** infrastructure

**Steps:**
1. Write failing test in `server/db.test.js`: `createDb(':memory:')` returns an object;
   `getAllTodos(db)` returns `[]` on a fresh DB
2. Verify RED
3. Create `server/db.js` with `createDb(path)`, `getAllTodos`, `createTodo`, `updateTodo`,
   `deleteTodo`. Schema: `CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0)`
4. Verify GREEN
5. Commit: `feat: add server/db.js with sqlite schema init and CRUD helpers`

**Files likely touched:**
- `server/db.js` — new
- `server/db.test.js` — new

**Dependencies:** Task 1

---

### Task 3: GET /api/todos — returns all todos
**Story:** Story 1, FR-1
**Type:** happy-path

**Steps:**
1. Write failing test in `server/index.test.js`: `GET /api/todos` with empty DB returns
   `200` and `[]`; seed two rows, `GET /api/todos` returns both as `[{id, text, completed}]`
2. Verify RED
3. Create `server/index.js` with `createApp(db)` factory; implement `GET /api/todos` handler
   calling `getAllTodos(db)` and responding `200` with the array
4. Verify GREEN
5. Commit: `feat: GET /api/todos returns all todos from sqlite`

**Files likely touched:**
- `server/index.js` — new
- `server/index.test.js` — new

**Dependencies:** Task 2

---

### Task 4: POST /api/todos — creates todo, responds 201
**Story:** Story 2, FR-2 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: `POST /api/todos` with `{ text: "Buy milk" }` returns `201` with
   `{ id: <number>, text: "Buy milk", completed: false }`; a subsequent `GET /api/todos`
   includes the new item
2. Verify RED
3. Add `POST /api/todos` handler: trim `req.body.text`, call `createTodo(db, text)`, respond
   `201` with created row
4. Verify GREEN
5. Commit: `feat: POST /api/todos creates and persists a new todo`

**Files likely touched:**
- `server/index.js` — add POST handler
- `server/index.test.js` — add tests

**Dependencies:** Task 3

---

### Task 5: POST /api/todos — 400 for blank text
**Story:** Story 2, FR-2 (negative path — server-side guard)
**Type:** negative-path

**Steps:**
1. Add test: `POST /api/todos` with `{ text: "   " }` returns `400` with
   `{ error: "text is required" }`; `GET /api/todos` still returns `[]`
2. Verify RED
3. Add blank-text guard before `createTodo` call: `if (!text) return res.status(400).json(...)`
4. Verify GREEN
5. Commit: `feat: POST /api/todos returns 400 for blank text`

**Files likely touched:**
- `server/index.js` — add guard
- `server/index.test.js` — add test

**Dependencies:** Task 4

---

### Task 6: PATCH /api/todos/:id — updates completed, responds 200
**Story:** Story 3, FR-3 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: seed a todo, `PATCH /api/todos/:id` with `{ completed: true }` returns `200`
   with the updated row `{ id, text, completed: true }`
2. Verify RED
3. Add `PATCH /api/todos/:id` handler: parse `id`, call `updateTodo(db, id, completed)`, check
   row exists, respond `200` with updated row
4. Verify GREEN
5. Commit: `feat: PATCH /api/todos/:id updates completed status`

**Files likely touched:**
- `server/index.js` — add PATCH handler
- `server/db.js` — ensure updateTodo returns the updated row
- `server/index.test.js` — add tests

**Dependencies:** Task 4

---

### Task 7: PATCH /api/todos/:id — 404 for missing id
**Story:** Story 3, FR-5 (negative path)
**Type:** negative-path

**Steps:**
1. Add test: `PATCH /api/todos/9999` with `{ completed: true }` returns `404` with
   `{ error: "not found" }`
2. Verify RED
3. Add null-check after `updateTodo`; if row not found respond `404`
4. Verify GREEN
5. Commit: `feat: PATCH /api/todos/:id returns 404 for unknown id`

**Files likely touched:**
- `server/index.js` — add 404 guard
- `server/index.test.js` — add test

**Dependencies:** Task 6

---

### Task 8: DELETE /api/todos/:id — removes todo, responds 204
**Story:** Story 4, FR-4 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: seed a todo, `DELETE /api/todos/:id` returns `204` with empty body; subsequent
   `GET /api/todos` returns `[]`
2. Verify RED
3. Add `DELETE /api/todos/:id` handler: parse `id`, call `deleteTodo(db, id)`, check row
   existed, respond `204`
4. Verify GREEN
5. Commit: `feat: DELETE /api/todos/:id removes todo from sqlite`

**Files likely touched:**
- `server/index.js` — add DELETE handler
- `server/db.js` — ensure deleteTodo returns rows-changed count
- `server/index.test.js` — add tests

**Dependencies:** Task 4

---

### Task 9: DELETE /api/todos/:id — 404 for missing id
**Story:** Story 4, FR-5 (negative path)
**Type:** negative-path

**Steps:**
1. Add test: `DELETE /api/todos/9999` returns `404` with `{ error: "not found" }`
2. Verify RED
3. Add rows-changed check in DELETE handler; if 0 respond `404`
4. Verify GREEN
5. Commit: `feat: DELETE /api/todos/:id returns 404 for unknown id`

**Files likely touched:**
- `server/index.js` — add 404 guard
- `server/index.test.js` — add test

**Dependencies:** Task 8

---

### Task 10: React fetches todos on mount (happy path)
**Story:** Story 1, FR-8 (happy path)
**Type:** happy-path

**Steps:**
1. In `src/App.test.js`, add test: mock `global.fetch` to return
   `[{ id: 1, text: "Buy milk", completed: false }]`; render `<App />`; assert
   `"Buy milk"` appears in the document
2. Verify RED
3. In `App.js`, add `useEffect(() => { fetch('/api/todos').then(r => r.json()).then(setTodos) }, [])`
   replacing the initial empty-array default
4. Verify GREEN
5. Commit: `feat: React fetches todos from GET /api/todos on mount`

**Files likely touched:**
- `src/App.js` — add useEffect fetch
- `src/App.test.js` — add mount test

**Dependencies:** Task 3

---

### Task 11: React mount fetch failure renders empty list without crash
**Story:** Story 1 (negative path — server unreachable)
**Type:** negative-path

**Steps:**
1. Add test: mock `global.fetch` to return a rejected promise; render `<App />`; assert the
   list container renders with zero items and no unhandled error is thrown
2. Verify RED
3. Add `.catch(() => {})` (or set state to `[]`) to the fetch chain in `useEffect`
4. Verify GREEN
5. Commit: `feat: React mount fetch failure leaves list empty without crash`

**Files likely touched:**
- `src/App.js` — add error handler to fetch chain
- `src/App.test.js` — add test

**Dependencies:** Task 10

---

### Task 12: React adds todo via POST /api/todos (happy path)
**Story:** Story 2, FR-9 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: mock `fetch` so `GET` returns `[]` and `POST` returns
   `{ id: 7, text: "Buy milk", completed: false }`; type "Buy milk" and click Add;
   assert "Buy milk" appears and the item's rendered key/id matches the server-assigned `7`
2. Verify RED
3. In `App.js`, replace `setTodos([...todos, { id: nextId, text, completed: false }])` with
   a `fetch('/api/todos', { method: 'POST', ... }).then(r => r.json()).then(todo => setTodos([...todos, todo]))`
4. Verify GREEN
5. Commit: `feat: React add todo calls POST /api/todos and uses server-assigned id`

**Files likely touched:**
- `src/App.js` — replace local add with POST fetch
- `src/App.test.js` — add test

**Dependencies:** Task 10

---

### Task 13: React whitespace guard blocks POST request
**Story:** Story 2 (negative path — client guard)
**Type:** negative-path

**Steps:**
1. Add test: mock `fetch` as `jest.fn()`; type "   " and click Add; assert `fetch` was
   never called and no item appears in the list
2. Verify RED (confirm guard exists but may not block fetch yet)
3. Ensure existing whitespace-trim guard fires before the `fetch` call
4. Verify GREEN
5. Commit: `test: whitespace guard prevents POST request for blank input`

**Files likely touched:**
- `src/App.js` — confirm guard order
- `src/App.test.js` — add test

**Dependencies:** Task 12

---

### Task 14: React toggles completion via PATCH /api/todos/:id (happy path)
**Story:** Story 3, FR-10 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: mock `fetch` so mount returns `[{ id: 3, text: "Task", completed: false }]`
   and `PATCH /api/todos/3` returns `{ id: 3, text: "Task", completed: true }`; click
   checkbox; assert strikethrough is applied
2. Verify RED
3. In `App.js`, replace `setTodos(todos.map(...completed toggle...))` with
   `fetch('/api/todos/:id', { method: 'PATCH', body: {completed: !todo.completed} }).then(r => r.json()).then(updated => setTodos(...))`
4. Verify GREEN
5. Commit: `feat: React toggle calls PATCH /api/todos/:id and updates from response`

**Files likely touched:**
- `src/App.js` — replace local toggle with PATCH fetch
- `src/App.test.js` — add test

**Dependencies:** Task 10

---

### Task 15: React PATCH 404 leaves checkbox unchanged
**Story:** Story 3 (negative path — stale id)
**Type:** negative-path

**Steps:**
1. Add test: mock `PATCH` to return `{ status: 404 }`; click checkbox; assert checkbox
   state is unchanged (item remains unchecked)
2. Verify RED
3. In the PATCH handler chain, check `response.ok`; if false, skip the `setTodos` update
4. Verify GREEN
5. Commit: `feat: React PATCH 404 leaves todo state unchanged`

**Files likely touched:**
- `src/App.js` — add response.ok guard in toggle
- `src/App.test.js` — add test

**Dependencies:** Task 14

---

### Task 16: React deletes todo via DELETE /api/todos/:id (happy path)
**Story:** Story 4, FR-11 (happy path)
**Type:** happy-path

**Steps:**
1. Add test: mock mount to return two todos; mock `DELETE /api/todos/1` to return 204;
   click delete on item 1; assert only item 2 remains
2. Verify RED
3. In `App.js`, replace `setTodos(todos.filter(...))` with
   `fetch('/api/todos/:id', { method: 'DELETE' }).then(() => setTodos(...))`
4. Verify GREEN
5. Commit: `feat: React delete calls DELETE /api/todos/:id and removes from state`

**Files likely touched:**
- `src/App.js` — replace local delete with DELETE fetch
- `src/App.test.js` — add test

**Dependencies:** Task 10

---

### Task 17: React DELETE 404 still removes item from local state
**Story:** Story 4 (negative path — todo already gone)
**Type:** negative-path

**Steps:**
1. Add test: mock `DELETE` to return 404; click delete; assert item is removed from the
   rendered list (idempotent from user's perspective)
2. Verify RED
3. Remove the item from state regardless of response status in the DELETE handler
4. Verify GREEN
5. Commit: `feat: React delete removes item from state even on 404 response`

**Files likely touched:**
- `src/App.js` — ensure delete always removes from state
- `src/App.test.js` — add test

**Dependencies:** Task 16

---

### Task 18: DB auto-creates on fresh server start
**Story:** Story 5 (negative path — no existing todos.db)
**Type:** negative-path

**Steps:**
1. Add test in `server/db.test.js`: call `createDb(':memory:')`, insert a row, call
   `createDb(':memory:')` again on the same path — confirm `CREATE TABLE IF NOT EXISTS`
   does not drop existing rows (use a temp file path)
2. Verify RED
3. Confirm `CREATE TABLE IF NOT EXISTS` is used (not `CREATE TABLE`)
4. Verify GREEN
5. Commit: `test: createDb is idempotent — IF NOT EXISTS preserves existing data`

**Files likely touched:**
- `server/db.test.js` — add idempotency test

**Dependencies:** Task 2

---

### Task 19: Todos persist across simulated page refresh (integration)
**Story:** Story 5 (happy path — end-to-end persistence)
**Type:** happy-path

**Steps:**
1. Add integration test in `server/index.test.js`: use a shared in-memory DB, POST three
   todos, then call `GET /api/todos`; assert all three are returned with correct `text` and
   `completed` values
2. Verify RED (should pass already if prior tasks are correct — if so, note GREEN immediately)
3. No implementation needed — this is a verification pass
4. Verify GREEN
5. Commit: `test: integration — todos retrieved after add round-trip`

**Files likely touched:**
- `server/index.test.js` — add round-trip integration test

**Dependencies:** Task 4

---

## Task Dependency Graph

```
Task 1 (deps/proxy/.gitignore)
  └─ Task 2 (db.js)
       ├─ Task 3 (GET /api/todos)
       │    └─ Task 4 (POST /api/todos happy)
       │         ├─ Task 5 (POST 400 negative)
       │         ├─ Task 6 (PATCH happy)
       │         │    └─ Task 7 (PATCH 404 negative)
       │         ├─ Task 8 (DELETE happy)
       │         │    └─ Task 9 (DELETE 404 negative)
       │         └─ Task 19 (integration)
       │    └─ Task 10 (React mount fetch)
       │         ├─ Task 11 (mount fetch failure)
       │         ├─ Task 12 (React add via POST)
       │         │    └─ Task 13 (whitespace guard)
       │         ├─ Task 14 (React toggle via PATCH)
       │         │    └─ Task 15 (PATCH 404)
       │         └─ Task 16 (React delete via DELETE)
       │              └─ Task 17 (DELETE 404)
       └─ Task 18 (DB idempotency test)
```

---

## Integration Points

- After Task 9: full server API is tested independently with an in-memory DB
- After Task 17: full client + server interaction is covered; end-to-end manual test is viable
- After Task 19: persistence round-trip verified

---

## Coverage Mapping

| Story / Criterion | Tasks |
|---|---|
| Story 1 — happy: mount populates list from server | 10 |
| Story 1 — negative: fetch failure → empty list, no crash | 11 |
| Story 2 — happy: POST called, server id used | 4, 12 |
| Story 2 — negative: client guard blocks POST for whitespace | 5, 13 |
| Story 3 — happy: PATCH called, state from response | 6, 14 |
| Story 3 — negative: PATCH 404 leaves state unchanged | 7, 15 |
| Story 4 — happy: DELETE called, item removed | 8, 16 |
| Story 4 — negative: DELETE 404 still removes from state | 9, 17 |
| Story 5 — happy: todos survive page refresh | 19 |
| Story 5 — negative: fresh server start creates DB automatically | 2, 18 |
| Story 5 — infra: proxy + gitignore | 1 |

## Verification

- [x] All happy path criteria covered by at least one task
- [x] All negative path criteria covered by at least one task
- [x] No task exceeds 5 minutes of work
- [x] Dependencies are explicit and acyclic
