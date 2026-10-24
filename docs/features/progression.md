# Progression

Completion events have stable IDs derived from puzzle type, generator version, seed, difficulty, and mode. Processing is idempotent: replaying or restoring an already-recorded event cannot award XP, stars, achievements, or streak credit twice. Values are captured on the solving move so immediate replay cannot alter the queued record.

Scores consider difficulty, efficient moves, elapsed time, and successfully delivered hints. Hints reduce score but never block completion. Daily streaks compare local calendar dates with UTC civil-day boundaries, advance at most once per date, and ignore older completion dates. Category/difficulty mastery and missions remain planned, not implemented features.
