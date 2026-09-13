# Diary-Entry-System
A simple, quaint diary/journal system

### Why?
Work-In-Progress (but aren't we all)

### Requirements/Compatibility
The module manifest declares `PowerShellVersion = '7.0'` while also listing
`CompatiblePSEditions = @('Core', 'Desktop')`. Windows PowerShell (the
Desktop edition) never ships a version 7.x — it tops out at 5.1 — so the
`PowerShellVersion` requirement makes the Desktop edition claim
unreachable in practice. The interactive UI (`New-DiaryMenu.ps1`,
`Invoke-Diary.ps1`) also uses Unicode box-drawing characters and
`Console.OpenStandardInput` for raw input (`Read-String.ps1`), which
render/behave correctly on PowerShell 7+ Core hosts but are unverified on
Desktop edition consoles. **Recommendation:** run this module on
PowerShell 7.0 or later (Core edition). The `CompatiblePSEditions` entry
for `Desktop` should be reviewed/narrowed in the manifest.

### Diary File Format
Each diary is a JSON array of progress-event objects stored under the
diaries directory (see `Get-DiaryFilePath.ps1` / `Get-JSONPath.ps1`). Diary
entries created via `New-DiaryEntry` are progress events with
`Title -eq 'DIARY'`; other tooling may write progress events with different
`Title` values to the same file, and readers (e.g. `Get-DiaryEntry`) filter
on `Title -eq 'DIARY'` to show only diary entries. There is currently no
schema version field in the JSON — the format below reflects the fields
written today.

| Field            | Type              | Meaning                                                                 |
|------------------|-------------------|--------------------------------------------------------------------------|
| `Title`          | string            | Event category. Diary entries always use the literal value `DIARY`.     |
| `ShortDesc`       | string            | Short, one-line summary of the entry.                                    |
| `Desc`           | string (nullable) | Full/free-form entry content.                                            |
| `DateEntered`    | datetime          | Timestamp the record was written (set automatically).                   |
| `DateOfProgress` | string (`MM-dd-yyyy`) | Date the entry/progress applies to.                                 |
| `HoursWorked`    | number (nullable) | Optional hours logged against the entry; `null` when not provided.      |

Example entry:

```json
{
  "Title": "DIARY",
  "ShortDesc": "Refactored the menu loop",
  "Desc": "Cleaned up New-DiaryMenu and added tests.",
  "DateEntered": "2026-09-12T10:15:00",
  "DateOfProgress": "09-12-2026",
  "HoursWorked": 2.5
}
```

### To-Do
- Write a better README.md
- ~~Include more To-Dos~~
- Convert to PSModule
- Implement configuration file
  - Location of JSON
- Add $PSStyle?