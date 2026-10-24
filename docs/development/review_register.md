# Continuation review register

Merge these PRs in order. Later PRs target the previous branch so their diffs stay focused. After merging a parent, retarget the child to main if GitHub has not done so. No PR has been merged automatically.

| Order | PR | Scope |
|---|---|---|
| 1 | [#2](https://github.com/sanskarIN/PuzzleForge/pull/2) | Android compatibility, upload signing, CI |
| 2 | [#3](https://github.com/sanskarIN/PuzzleForge/pull/3) | Compatible Puzzle Path rename |
| 3 | [#4](https://github.com/sanskarIN/PuzzleForge/pull/4) | Website, contacts, BMC/Razorpay/PayPal, fallback, tests |
| 4 | [#5](https://github.com/sanskarIN/PuzzleForge/pull/5) | Save ordering, completion snapshots, Continue/foreground, streaks |
| 5 | Final audit PR | Current status, roadmap, validation/build evidence |

All new commits use sanskarin@outlook.in. Historical commits/artifact evidence are preserved. The final stack passes 55 local tests and strict analysis; GitHub checks are separate evidence to review on each PR.
