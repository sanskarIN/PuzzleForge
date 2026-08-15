# Test Strategy

Use fixed seeds for reproducible rule tests and broader seed loops for property-like invariant coverage. Never mark a random failing seed as flaky: record it as a regression fixture. Widget tests use injected in-memory storage and fake URL launchers. Integration tests exercise a complete player journey on Android. Performance checks place explicit attempt and board-size bounds on generators and solvers.

A test may be quarantined only with an issue, owner, expiry, reason, and evidence that it does not hide a release-gate defect. Skipping or weakening assertions solely to make CI green is prohibited.
