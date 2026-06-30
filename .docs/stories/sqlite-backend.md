**Status:** Accepted

> **Note:** Story 6 in `simple-todo.md` ("In-Memory State Resets on Page Refresh", FR-6 of the
> base spec) is superseded by this feature. The new persistence behavior intentionally inverts
> that requirement. The original story remains in its file for historical traceability.

---

## Story: Load Todos from Database on Mount

**Requirement:** FR-1, FR-8

As a user, I want my previously saved todos to appear when I open the app so that I can
continue where I left off.

### Acceptance Criteria

#### Happy Path
- Given todos exist in SQLite, when the React app mounts, then `GET /api/todos` is called once
  and the returned array is rendered as the initial todo list
- Given the database is empty, when the app mounts, then `GET /api/todos` returns `[]` and an
  empty list is rendered

#### Negative Paths
- Given the Express server is not running, when the app mounts and `GET /api/todos` fails with a
  network error, then the list renders empty and the app does not crash or throw an unhandled
  exception

### Done When
- [ ] On mount, a `GET /api/todos` request is made before any user interaction
- [ ] The list is populated with the server response, not an empty `[]` default
- [ ] A failed fetch on mount leaves the list empty without a JavaScript error

---

## Story: Add Todo Persisted via API

**Requirement:** FR-2, FR-9

As a user, I want new todos I add to be saved to the database so that they survive a page
refresh.

### Acceptance Criteria

#### Happy Path
- Given I type "Buy milk" and click Add (or press Enter), when `POST /api/todos` is called with
  `{ text: "Buy milk" }`, then the server returns 201 with `{ id, text, completed: false }` and
  the new item appears in the list using the server-assigned `id`

#### Negative Paths
- Given I submit blank or whitespace-only text, when the client-side guard fires, then no
  `POST /api/todos` request is sent to the server
- Given text reaches the server and is blank after trimming, when `POST /api/todos` is called,
  then the server returns 400 with `{ "error": "text is required" }` and no record is created

### Done When
- [ ] Submitting a valid todo triggers `POST /api/todos` with the trimmed text
- [ ] The todo displayed in the list uses the `id` from the server response (not a client-generated id)
- [ ] Whitespace-only input results in zero network requests

---

## Story: Toggle Completion Persisted via API

**Requirement:** FR-3, FR-10

As a user, I want checking or unchecking a todo to be saved so that completion state survives
a page refresh.

### Acceptance Criteria

#### Happy Path
- Given a todo with `id: 3` and `completed: false` is in the list, when I click its checkbox,
  then `PATCH /api/todos/3` is called with `{ completed: true }` and the item renders with
  strikethrough using the server response
- Given a todo is already complete, when I uncheck it, then `PATCH /api/todos/:id` is called
  with `{ completed: false }` and the strikethrough is removed

#### Negative Paths
- Given the server returns 404 for a `PATCH` (stale `id` no longer in the DB), then the local
  state is not updated and the checkbox remains in its prior position

### Done When
- [ ] Clicking a checkbox triggers `PATCH /api/todos/:id` with the toggled `completed` value
- [ ] Local state is updated from the server response, not computed client-side
- [ ] A 404 response leaves the UI state unchanged

---

## Story: Delete Todo Removed from Database via API

**Requirement:** FR-4, FR-5, FR-11

As a user, I want deleting a todo to permanently remove it from the database so that it does
not reappear after a page refresh.

### Acceptance Criteria

#### Happy Path
- Given a todo with `id: 5` exists, when I click its delete button, then `DELETE /api/todos/5`
  is called, the server returns 204, and the item is removed from the list

#### Negative Paths
- Given the server returns 404 for a `DELETE` (todo already gone), then the item is removed
  from local state anyway (idempotent from the user's perspective)

### Done When
- [ ] Clicking delete triggers `DELETE /api/todos/:id`
- [ ] A successful 204 removes the item from local state
- [ ] A 404 response also removes the item from local state (graceful dedup)
- [ ] The remaining items are unaffected and retain their order

---

## Story: Todos Persist Across Page Refresh

**Requirement:** FR-6, FR-7, FR-8, FR-12

As a user, I want todos to still be present after I refresh the page so that I do not lose my
list between sessions.

### Acceptance Criteria

#### Happy Path
- Given I have added three todos and marked one complete, when I refresh the browser, then all
  three todos reappear with their correct `completed` states
- Given the server is freshly started with no `todos.db` file, when the server starts, then the
  database file and `todos` table are created automatically and the app loads without error

#### Negative Paths
- Given `todos.db` exists from a prior session, when the server starts, then existing data is
  preserved — the schema creation uses `CREATE TABLE IF NOT EXISTS` and does not drop or
  truncate the table

### Done When
- [ ] After a browser refresh, `GET /api/todos` returns the same todos that were in the list before refresh
- [ ] A completed todo retains its `completed: true` state after refresh
- [ ] Server startup with no existing DB file creates `todos.db` at the project root without manual steps
- [ ] `todos.db` is listed in `.gitignore`
- [ ] CRA `package.json` contains `"proxy": "http://localhost:3001"` so `/api/*` requests are
      forwarded to Express in development
