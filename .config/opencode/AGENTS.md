# Global Agent Instructions

### Commit Checkpoints

- Do not run tests on every change. Run the test suite (or the relevant subset) only when about to recommend a commit.
- After completing a logical unit of work (migration + model, controller + views, or all tests passing for a feature), recommend committing by asking: "N files changed, tests pass — should I commit these changes?" Wait for a yes/no response before proceeding.
- At session start, run `git status`; if uncommitted changes exist from prior work, ask about them.
- Do not auto-commit. Proactively remind when 10+ files accumulate uncommitted.
