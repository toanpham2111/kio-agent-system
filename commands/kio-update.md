---
description: "Kio: check for a newer release and update"
argument-hint: "[check | update]"
---
Check whether a newer Kio release exists and help the user update. Show the versions first; run the installer only if the request says "update" or the user agrees.

1. Installed version: the first `## [x.y.z]` heading of `~/.kio/repo/CHANGELOG.md` (Windows: `$HOME\.kio\repo\CHANGELOG.md`). If that file does not exist, Kio was installed from a local checkout: read that checkout's `CHANGELOG.md` instead.
2. Latest release: run `git ls-remote --tags --refs --sort=-v:refname https://github.com/toanpham2111/kio-agent-system.git "v*"` and take the first tag. Without git, read https://github.com/toanpham2111/kio-agent-system/releases/latest.
3. Compare the two. If they match, say Kio is up to date and stop. If a newer one exists, show both versions, summarise what changed (the newer entries of the changelog, or the release page) and give the update command for the user's system:
   - Linux / macOS / WSL: `curl -fsSL https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.sh | bash`
   - Windows PowerShell: `irm https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.ps1 | iex`
4. After a successful update, tell the user to restart their AI tool so it reloads the skills and commands. If the installer fails, show its error and leave the installed copy as it is.

Request: $ARGUMENTS
(If the line above still shows a placeholder, the request is the text typed after the command.)

<!-- kio-command: managed by the Kio installer; local edits are replaced on update -->
