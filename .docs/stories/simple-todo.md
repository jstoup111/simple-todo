**Status:** Accepted

---

## Story: Add a Todo Item

**Requirement:** FR-1, FR-7

As a user, I want to type a task into the input field and submit it so that it appears in my todo list.

### Acceptance Criteria

#### Happy Path
- Given the app is loaded and the input field is empty, when I type "Buy groceries" and press Enter, then a new todo item "Buy groceries" appears at the bottom of the list
- Given the app is loaded, when I type "Call dentist" and click the Add button, then a new todo item "Call dentist" appears in the list
- Given I have just submitted a todo, when the item is added, then the input field is cleared and ready for the next entry

#### Negative Paths
- Given the input field contains only whitespace (e.g., "   "), when I press Enter, then no todo is added and the list remains unchanged (FR-2)

### Done When
- [ ] Typing text and pressing Enter adds a new item to the rendered list
- [ ] Clicking the Add button also adds the item
- [ ] Input field value is empty string after a successful add
- [ ] List count increases by exactly 1 per valid submission

---

## Story: Ignore Empty or Whitespace-Only Submissions

**Requirement:** FR-2

As a user, I want the app to ignore blank submissions so that I don't accidentally create empty todo items.

### Acceptance Criteria

#### Happy Path
- Given the input contains only spaces, when I press Enter, then nothing is added to the list and the input is not cleared

#### Negative Paths
- Given the input is completely empty (""), when I press Enter, then the list is unchanged and no error is shown
- Given the input is `"\t\n  "` (only whitespace characters), when the form is submitted, then the list remains unchanged

### Done When
- [ ] Submitting an empty string leaves the todo list count unchanged
- [ ] Submitting a whitespace-only string leaves the todo list count unchanged
- [ ] No empty or blank items appear in the rendered list under any submission scenario

---

## Story: Mark a Todo as Complete

**Requirement:** FR-3

As a user, I want to check a todo's checkbox so that I can visually distinguish tasks I've finished.

### Acceptance Criteria

#### Happy Path
- Given a todo "Send invoice" exists in the list with an unchecked checkbox, when I click the checkbox, then the todo text is rendered with strikethrough styling and the checkbox is checked

#### Negative Paths
- Given no todos exist in the list, when the list renders, then no checkboxes are visible (nothing to interact with)

### Done When
- [ ] Clicking the checkbox toggles the item's `completed` state to `true`
- [ ] A completed item renders with visually distinct styling (e.g., `text-decoration: line-through`)
- [ ] The checkbox reflects the checked state after clicking

---

## Story: Uncheck a Completed Todo

**Requirement:** FR-4

As a user, I want to uncheck a completed todo so that I can restore it to incomplete if I made a mistake.

### Acceptance Criteria

#### Happy Path
- Given a todo is marked complete (checkbox checked, strikethrough visible), when I click the checkbox again, then the strikethrough is removed and the checkbox is unchecked

#### Negative Paths
- Given a todo is already incomplete, when I click the checkbox to complete it and then click again to uncomplete, then the final state is incomplete — toggling is idempotent across even numbers of clicks

### Done When
- [ ] Clicking a checked checkbox sets `completed` back to `false`
- [ ] Strikethrough styling is removed when the item is uncompleted
- [ ] The checkbox reflects the unchecked state after clicking

---

## Story: Delete a Todo Item

**Requirement:** FR-5

As a user, I want to click a delete button on a todo so that I can remove tasks I no longer need.

### Acceptance Criteria

#### Happy Path
- Given a list of three todos, when I click the delete button on the middle item, then that item is removed and the remaining two items are still displayed in their original order

#### Negative Paths
- Given only one todo exists, when I delete it, then the list is empty and no delete buttons are visible

### Done When
- [ ] Clicking delete removes exactly the targeted item (identified by its unique id/index)
- [ ] The remaining items are unaffected
- [ ] The list length decreases by exactly 1 after each delete

---

## Story: In-Memory State Resets on Page Refresh

**Requirement:** FR-6

As a user, I understand that refreshing the page clears my todo list, so I know not to rely on the app for persistence.

### Acceptance Criteria

#### Happy Path
- Given I have added three todos, when I refresh the browser page, then the todo list is empty

#### Negative Paths
- Given no localStorage or sessionStorage calls are made, when the app mounts, then the initial state is always an empty array (no stale data from a previous session can appear)

### Done When
- [ ] Initial `useState` value is an empty array `[]`
- [ ] No `localStorage` or `sessionStorage` reads or writes exist in the codebase
- [ ] After a hard refresh, the rendered list contains zero items
