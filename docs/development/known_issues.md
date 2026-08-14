# Known Issues

| ID | Severity | State | Description | Next action |
|---|---|---|---|---|
| TOOL-001 | Medium | Open | GitHub CLI authentication reports an invalid stored token. | Retry Git push with Git credentials, then re-authenticate `gh` if a draft PR cannot be created. |
| QA-001 | Medium | Open | Dependencies, analyzer, tests, and Android build have not yet run. | Run all gates after the first functional implementation batch. |
