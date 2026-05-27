# Global Agent Instructions

### Commit Checkpoints

After completing a logical unit of work (migration + model, controller + views, or all tests passing for a feature), prompt: "N files changed, tests pass — commit before continuing?" At session start, run `git status`; if uncommitted changes exist from prior work, ask about them. Do not auto-commit, but proactively remind when 10+ files accumulate uncommitted.
