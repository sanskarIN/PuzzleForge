# Progression

Completion events have stable IDs derived from puzzle type, seed, difficulty, and mode. Processing is idempotent: replaying or restoring an already-recorded event cannot award XP, stars, achievements, streak credit, or mission progress twice.

Scores consider difficulty, efficient moves, elapsed time, and successfully delivered hints. Hints reduce score but never block completion. Category mastery and difficulty mastery derive from recorded completion IDs rather than mutable counters alone. Daily streaks use local calendar dates and allow no more than one increment per date.
