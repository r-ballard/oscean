---
name: uxntal-development
description: Use when editing or debugging Uxntal ROMs, Drifblim assembly, Varvara devices, parser loops, stack effects, or halt and exit behavior in this Oscean repository. Article-only HTML edits use AUTHORING.md.
---

# Source-grounded Uxntal development

Use the pinned implementation and executable evidence rather than recalled
semantics from another Uxn emulator or assembler dialect. This skill adds no
runtime dependencies and does not authorize installs, merges or deployment.

Read [the source map](references/source-map.md) for the code relevant to the task.
Load only the needed sections of the bundled upstream manuals, not every manual.
The source map identifies revisions, artifact hashes and differences to verify.

Before changing a routine, identify its inputs/outputs and byte/short widths,
working/return-stack balance, memory limits, device-success checks and loop
progress condition. For a non-obvious branch, leave a short stack-effect comment.
Inspect an existing working routine using the same assembler syntax/device.

If a semantic point is uncertain, assemble a minimal fixture and run it through
the pinned CLI with a deadline before modifying the larger program. Begin with
`scripts/test-uxn.sh`; its source fixtures are in `tests/uxn/`. Add a targeted probe
only when it settles an actual uncertainty. Write expected status/output from the
source or documented contract independently of the new implementation.

Preserve the distinctions between:
- BRK ending an evaluation and the host process exiting;
- setting System/state and interrupting a running instruction loop;
- a failing ROM, a blocked console read, and a timeout;
- shell argv quoting and the assembler's console argument parser;
- an absent file, an empty file, a read failure and a short/truncated read.

For ROM tests, source `scripts/uxn-test-lib.sh`, set EMU to the pinned executable,
and call `uxn_test ROM [args...]`. It closes stdin and bounds execution. A timeout
aborts the suite even inside an expected-failure conditional. Expected failures
must assert the precise ROM status, rather than accepting any nonzero result. Assemble copied
fixtures using relative source/output names so console parsing does not depend
on checkout path characters.

Make the smallest source-supported change, run the relevant native regression
and build, then inspect generated output. Repeated builds should preserve authored
dates/content. A successful assembly is not proof of correct execution. Report
source revision, command, exit status and relevant output; identify any unverified
assumption instead of presenting it as language behavior.
