# Implementation Plan: Simple TODO List

**Date:** 2026-06-30
**Design:** .docs/specs/2026-06-30-simple-todo.md
**Stories:** .docs/stories/simple-todo.md
**Conflict check:** N/A — Tier S, skipped per complexity assessment

## Summary

Builds a single-page React TODO app (add, complete, delete) using Create React App and plain `useState`. 17 tasks covering all happy and negative paths across 6 stories.

## Technical Approach

- Run `npx create-react-app .` in the repo root to scaffold the project. Delete the CRA boilerplate (logo, default CSS content) and replace `App.js` with the todo implementation.
- State shape: `todos: Array<{ id: number, text: string, completed: boolean }>`. IDs assigned via an incrementing ref (`useRef`) to avoid `Date.now()` collisions during rapid adds.
- All state lives in `App`. No child components needed at MVP scale — one component, one file.
- Tests use React Testing Library (`@testing-library/react`) + Jest, both bundled with CRA. Each task's test goes in `src/App.test.js`.
- No `localStorage`, no `sessionStorage`, no external state library — verified by a lint/grep test task.

## Prerequisites

- Node.js ≥ 16 installed
- `npx` available
- The repo root (`/Users/james.stoup/code/test/simple-todo`) is the CRA target

## Tasks

### Task 1: Bootstrap CRA
**Story:** Infrastructure prerequisite for all stories
**Type:** infrastructure

**Steps:**
1. Run `npx create-react-app .` inside the repo root (or `npx create-react-app simple-todo` then move files)
2. Verify `npm start` launches without errors
3. Verify `npm test` runs the default smoke test green
4. Commit with message: `chore: bootstrap create-react-app`

**Files likely touched:**
- `src/` — created by CRA
- `public/` — created by CRA
- `package.json` — created by CRA

**Dependencies:** none

---

### Task 2: Strip CRA Boilerplate
**Story:** Infrastructure prerequisite for all stories
**Type:** infrastructure

**Steps:**
1. Delete `src/logo.svg`, `src/App.css` default content (keep file, clear it), `src/reportWebVitals.js` if unused
2. Replace `src/App.js` with a minimal shell: `function App() { return <div className="App"></div>; } export default App;`
3. Replace `src/App.test.js` with a single placeholder test: `test('app renders', () => { render(<App />); });`
4. Verify `npm test` still passes
5. Commit with message: `chore: strip CRA boilerplate`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`
- `src/App.css`

**Dependencies:** Task 1

---

### Task 3: Render Input Field and Add Button
**Story:** Story 1 (Add a Todo Item) — happy path setup
**Type:** happy-path

**Steps:**
1. Write failing test: `expect(screen.getByPlaceholderText(/add a todo/i)).toBeInTheDocument()` and `expect(screen.getByRole('button', { name: /add/i })).toBeInTheDocument()`
2. Verify tests fail (RED)
3. Add `<input placeholder="Add a todo" />` and `<button>Add</button>` to `App.js`
4. Verify tests pass (GREEN)
5. Commit with message: `feat: render todo input and add button`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 2

---

### Task 4: Add Todo on Enter Key Press
**Story:** Story 1 — FR-1 happy path (Enter key)
**Type:** happy-path

**Steps:**
1. Write failing test: type "Buy groceries" into input, press `{Enter}`, assert `screen.getByText('Buy groceries')` exists in the document
2. Verify test fails (RED)
3. Add `todos` state (`useState([])`), `idCounter` ref, `handleAdd` function; wire `onKeyDown` to call `handleAdd` on Enter; render `todos.map(...)` as list items
4. Verify test passes (GREEN)
5. Commit with message: `feat: add todo on Enter key press`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 3

---

### Task 5: Add Todo on Button Click
**Story:** Story 1 — FR-1 happy path (button click)
**Type:** happy-path

**Steps:**
1. Write failing test: type "Call dentist", click Add button, assert `screen.getByText('Call dentist')` is in the document
2. Verify test fails (RED)
3. Wire `onClick` on the Add button to call the same `handleAdd` function
4. Verify test passes (GREEN)
5. Commit with message: `feat: add todo on button click`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 4

---

### Task 6: Clear Input After Successful Submit
**Story:** Story 1 — FR-7 happy path
**Type:** happy-path

**Steps:**
1. Write failing test: type "Test task", press Enter, assert `screen.getByPlaceholderText(/add a todo/i)` has value `""`
2. Verify test fails (RED)
3. In `handleAdd`, set `inputValue` state to `""` after adding the todo
4. Verify test passes (GREEN)
5. Commit with message: `feat: clear input after todo is added`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 4

---

### Task 7: Ignore Empty String Submission
**Story:** Story 2 — FR-2 negative path (empty string)
**Type:** negative-path

**Steps:**
1. Write failing test: leave input empty, press Enter, assert no new list items appear (query `screen.queryAllByRole('listitem')` returns length 0)
2. Verify test fails (RED)
3. In `handleAdd`, guard with `if (!inputValue.trim()) return;`
4. Verify test passes (GREEN)
5. Commit with message: `fix: ignore empty string on submit`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 4

---

### Task 8: Ignore Whitespace-Only Submission
**Story:** Story 2 — FR-2 negative path (whitespace)
**Type:** negative-path

**Steps:**
1. Write failing test: type `"   "` (spaces) into input, press Enter, assert list item count is 0 and input value is still `"   "` (not cleared)
2. Verify test fails (RED)
3. The `.trim()` guard from Task 7 covers this — verify no code change needed
4. Verify test passes (GREEN)
5. Commit with message: `test: verify whitespace-only input is ignored`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 7

---

### Task 9: Render Todo List with Checkbox and Delete Button
**Story:** Story 3, 4, 5 — shared rendering infrastructure
**Type:** happy-path

**Steps:**
1. Write failing tests: after adding "Sample task", assert a checkbox (`getByRole('checkbox')`) and a delete button (`getByRole('button', { name: /delete/i }`) exist in the document
2. Verify tests fail (RED)
3. Update `todos.map(...)` to render `<li key={t.id}><input type="checkbox" />{t.text}<button>Delete</button></li>`
4. Verify tests pass (GREEN)
5. Commit with message: `feat: render todo items with checkbox and delete button`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 4

---

### Task 10: Checkbox Marks Todo Complete (Strikethrough)
**Story:** Story 3 — FR-3 happy path
**Type:** happy-path

**Steps:**
1. Write failing test: add "Send invoice", click its checkbox, assert the text element has `style` or `className` indicating `text-decoration: line-through` (e.g., `toHaveStyle('text-decoration: line-through')`)
2. Verify test fails (RED)
3. Add `completed` field to todo objects; wire checkbox `onChange` to toggle `completed`; render todo text in a `<span>` with `style={{ textDecoration: t.completed ? 'line-through' : 'none' }}`
4. Verify test passes (GREEN)
5. Commit with message: `feat: mark todo complete with strikethrough`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 9

---

### Task 11: Uncheck Completed Todo Restores Incomplete State
**Story:** Story 4 — FR-4 happy path
**Type:** happy-path

**Steps:**
1. Write failing test: add todo, click checkbox (complete), click checkbox again (uncomplete), assert text element no longer has `text-decoration: line-through` and checkbox is unchecked
2. Verify test fails (RED)
3. The toggle in Task 10 already handles this — verify the test passes without additional implementation
4. Verify test passes (GREEN)
5. Commit with message: `test: verify unchecking todo restores incomplete state`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 10

---

### Task 12: Toggle Idempotency (Even Clicks Return to Original State)
**Story:** Story 4 — FR-4 negative path
**Type:** negative-path

**Steps:**
1. Write failing test: add todo, click checkbox 4 times, assert `completed` is `false` (checkbox unchecked, no strikethrough)
2. Verify test fails (RED)
3. Toggle logic `t.completed = !t.completed` is inherently idempotent — verify no code change needed
4. Verify test passes (GREEN)
5. Commit with message: `test: verify checkbox toggle is idempotent`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 11

---

### Task 13: Delete Button Removes Targeted Todo
**Story:** Story 5 — FR-5 happy path
**Type:** happy-path

**Steps:**
1. Write failing test: add "First", "Second", "Third"; click delete on "Second"; assert "First" and "Third" still in document, "Second" is not
2. Verify test fails (RED)
3. Add `handleDelete(id)` that filters todos by id; wire delete button `onClick` to `handleDelete(t.id)`
4. Verify test passes (GREEN)
5. Commit with message: `feat: delete todo by id`

**Files likely touched:**
- `src/App.js`
- `src/App.test.js`

**Dependencies:** Task 9

---

### Task 14: Delete Only Todo Results in Empty List
**Story:** Story 5 — FR-5 negative path
**Type:** negative-path

**Steps:**
1. Write failing test: add one todo, delete it, assert `screen.queryAllByRole('listitem')` returns empty array and no delete buttons are visible
2. Verify test fails (RED)
3. Existing `handleDelete` filter covers this — verify no code change needed
4. Verify test passes (GREEN)
5. Commit with message: `test: verify deleting only todo empties the list`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 13

---

### Task 15: Empty List Renders No Checkboxes
**Story:** Story 3 — FR-3 negative path
**Type:** negative-path

**Steps:**
1. Write failing test: render `<App />` with no todos added, assert `screen.queryAllByRole('checkbox')` returns empty array
2. Verify test fails (RED)
3. Initial empty `useState([])` covers this — verify no code change needed
4. Verify test passes (GREEN)
5. Commit with message: `test: verify empty list renders no checkboxes`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 9

---

### Task 16: Verify No localStorage or sessionStorage Usage
**Story:** Story 6 — FR-6 negative path
**Type:** negative-path

**Steps:**
1. Write a test that spies on `window.localStorage.setItem` and `window.sessionStorage.setItem`, performs add/complete/delete actions, and asserts neither spy was called
2. Verify test fails (RED — spies may not be set up yet)
3. Confirm `App.js` has no storage calls; ensure test setup is correct
4. Verify test passes (GREEN)
5. Commit with message: `test: verify no localStorage or sessionStorage usage`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 4

---

### Task 17: Initial State Is Always Empty Array
**Story:** Story 6 — FR-6 happy path
**Type:** happy-path

**Steps:**
1. Write test: render `<App />`, assert `screen.queryAllByRole('listitem')` returns `[]` (no todos on mount)
2. Verify test fails (RED)
3. `useState([])` initial value covers this — verify no code change needed
4. Verify test passes (GREEN)
5. Commit with message: `test: verify app mounts with empty todo list`

**Files likely touched:**
- `src/App.test.js`

**Dependencies:** Task 2

---

## Task Dependency Graph

```
Task 1 (Bootstrap CRA)
  └─ Task 2 (Strip boilerplate)
       └─ Task 3 (Input + button)
            └─ Task 4 (Enter key adds todo)
                 ├─ Task 5 (Button click adds todo)
                 ├─ Task 6 (Clear input after add)
                 ├─ Task 7 (Ignore empty)
                 │    └─ Task 8 (Ignore whitespace)
                 ├─ Task 9 (Render list with checkbox + delete)
                 │    ├─ Task 10 (Complete with strikethrough)
                 │    │    └─ Task 11 (Uncheck restores)
                 │    │         └─ Task 12 (Toggle idempotency)
                 │    ├─ Task 13 (Delete by id)
                 │    │    └─ Task 14 (Delete only todo)
                 │    └─ Task 15 (Empty list: no checkboxes)
                 └─ Task 16 (No localStorage)
       └─ Task 17 (Empty initial state)
```

## Integration Points

- After Task 5: full add flow (Enter + button) testable end-to-end
- After Task 10: add + complete flow testable end-to-end
- After Task 13: full CRUD loop (add, complete, delete) testable end-to-end

## Coverage Mapping

| Story / Criterion | Task(s) |
|---|---|
| Story 1 happy: Enter adds todo | Task 4 |
| Story 1 happy: Button adds todo | Task 5 |
| Story 1 happy: Input clears after add | Task 6 |
| Story 1 negative: Whitespace adds nothing | Task 7, 8 |
| Story 2 happy: Spaces → list unchanged | Task 7 |
| Story 2 negative: Empty string → unchanged | Task 7 |
| Story 2 negative: Tab/newline-only → unchanged | Task 8 |
| Story 3 happy: Checkbox → strikethrough | Task 10 |
| Story 3 negative: Empty list → no checkboxes | Task 15 |
| Story 4 happy: Uncheck restores incomplete | Task 11 |
| Story 4 negative: Even toggles → original state | Task 12 |
| Story 5 happy: Delete middle of 3 | Task 13 |
| Story 5 negative: Delete only todo → empty | Task 14 |
| Story 6 happy: Refresh → empty list | Task 17 |
| Story 6 negative: No localStorage/sessionStorage | Task 16 |

## Verification

- [x] All happy path criteria covered by at least one task
- [x] All negative path criteria covered by at least one task
- [x] No task exceeds 5 minutes of work
- [x] Dependencies are explicit and acyclic
- [x] 17 tasks — within normal range (1–20)
