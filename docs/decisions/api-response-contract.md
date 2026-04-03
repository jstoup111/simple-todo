# ADR: API Response Contract

**Date:** 2026-04-01  
**Status:** Approved

---

## Context

Rails API-only app. All responses are JSON. This contract defines the envelope, status codes,
and field formats all controllers must follow.

---

## Contract

### Success — single resource

```json
{
  "id": 1,
  "title": "Buy milk",
  "done": false,
  "created_at": "2026-04-01T12:00:00.000Z",
  "updated_at": "2026-04-01T12:00:00.000Z"
}
```

No wrapping envelope. Bare resource object.

### Error — validation failure (422)

```json
{
  "errors": {
    "title": ["can't be blank"]
  }
}
```

### Error — not found (404)

```json
{
  "error": "Not found"
}
```

---

## HTTP Status Conventions

| Situation | Status |
|-----------|--------|
| Resource created | `201 Created` |
| Resource updated | `200 OK` |
| Validation failed | `422 Unprocessable Entity` |
| Record not found | `404 Not Found` |

---

## Field Formats

- **Timestamps:** ISO 8601, UTC (`"2026-04-01T12:00:00.000Z"`)
- **Booleans:** JSON `true` / `false` (not `"true"`/`"false"`)
- **IDs:** Integer

---

## Deviations

Any controller that deviates from this contract must amend this document.
