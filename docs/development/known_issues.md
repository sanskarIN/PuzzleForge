# Known Issues

| ID | Severity | State | Description | Next action |
|---|---|---|---|---|
| PUB-001 | High | Resolved | `agent/complete-project` is now pushed and tracks `origin/agent/complete-project` on `https://github.com/sanskarIN/PuzzleForge.git`. | Keep the existing commit history; open a pull request after GitHub CLI authentication is renewed. |
| TOOL-001 | Medium | Open | GitHub CLI authentication reports an invalid stored token. | Run `gh auth login --hostname github.com`, then create a draft PR after the branch exists on the remote. |
| QA-001 | High | Resolved | Direct Gradle `assembleDebug`, `assembleRelease`, and `bundleRelease` complete with the populated offline cache and JDK 17. Release lint also passes after backup-rule and optional integration-test registrant fixes. | Keep JDK 17 selected for reproducible Android builds until the JDK 26 image-transform issue is resolved upstream. |
| QA-002 | High | Open | Android emulator/physical-device, TalkBack, background/resume, rotation, low-memory, profile performance, and signed AAB checks have not run. | Execute the manual release matrix on representative devices after an APK builds. |
| REL-001 | High | Open | Release outputs are unsigned because no upload keystore is stored in or available to this workspace. | Create/protect an upload keystore outside Git, configure `key.properties` in the release environment, rebuild, and verify Play App Signing metadata. |
