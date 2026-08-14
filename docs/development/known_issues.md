# Known Issues

| ID | Severity | State | Description | Next action |
|---|---|---|---|---|
| TOOL-001 | Medium | Open | GitHub CLI authentication reports an invalid stored token. | Retry Git push with Git credentials, then re-authenticate `gh` if a draft PR cannot be created. |
| QA-001 | Medium | Partially resolved | Dependencies, analyzer, and 31 unit/rule tests pass; Android build and UI tests are still pending. | Run UI tests and Android build after the application shell is implemented. |
