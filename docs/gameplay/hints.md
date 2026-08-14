# Hint Economy

Players earn free hint tokens through play. A hint request follows a transaction-like flow:

1. Confirm an active, unsolved state.
2. Ask the module for a stable hint ID and localized explanation key.
3. Ignore a repeated hint ID for charging purposes.
4. Verify a token is available only when a charge is needed.
5. Deliver the hint, then persist the debit and delivery atomically.

Generation failure, an already-solved puzzle, or a duplicate hint never consumes another token. Accessibility does not change prices or place essential mechanics behind hints.
