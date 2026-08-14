# Known Issues

| ID | Severity | State | Description | Next action |
|---|---|---|---|---|
| PUB-001 | High | Blocked by environment | `git push -u origin agent/complete-project` could not connect to GitHub from the sandbox. The required network escalation was rejected because the environment usage limit was reached. | Push the existing local branch after outbound GitHub access is approved; do not recreate or squash its commits. |
| TOOL-001 | Medium | Open | GitHub CLI authentication reports an invalid stored token. | Run `gh auth login --hostname github.com`, then create a draft PR after the branch exists on the remote. |
| QA-001 | High | Blocked by environment | `flutter build apk --debug` reached Gradle, then failed because the sandbox denied the required network connection. The approval retry was rejected because the environment usage limit was reached, not because of a source compiler error. | Rerun with Gradle/Maven network access or a populated Gradle cache; fix any resulting source/resource error before release. |
| QA-002 | High | Open | Android emulator/physical-device, TalkBack, background/resume, rotation, low-memory, profile performance, and signed AAB checks have not run. | Execute the manual release matrix on representative devices after an APK builds. |
