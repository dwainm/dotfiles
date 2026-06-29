# Global Agent Instructions

### Commit Checkpoints

- Do not run tests automatically. Always ask "Should I run the tests?" and wait for a yes/no response before running the test suite (or the relevant subset).
- Do not recommend or initiate commits automatically. Wait for the user to explicitly ask to commit, or ask "Should I commit these changes?" and wait for a yes/no response before proceeding.
- At session start, run `git status`; if uncommitted changes exist from prior work, ask about them.
- Do not auto-commit. Proactively remind when 10+ files accumulate uncommitted.
