# Oscean agent guidance

Work from the oscean repository root. Opening a sibling repository does not make
this repo's skills or permissions automatically active; ask the owner to open
oscean as the Codex workspace when necessary. Do not change global configuration.

## Source and scope

- Native Uxntal and HTML are the supported workflow. Add no runtime/authoring
  dependencies or alternative implementation languages without an owner decision.
- For TAL, assembler, device, parser or halt/exit changes, read
  `.agents/skills/uxntal-development/SKILL.md` and its relevant source references.
  Confirm uncertain behavior against the pinned source and a minimal ROM probe.
- For article-only edits, use AUTHORING.md. Tool setup is in BUILDING.md.
- Reuse the pinned CLI and bundled Drifblim via scripts/bootstrap.sh. Do not
  replace the assembler with a similarly named tool or assume dialect equivalence.
- Work notes stay in ignored .github/development/. Durable guidance, references
  and actual source/tests may be versioned. Keep production and upstream untouched.

## Verification

From Bash (MSYS2 MSYS on Windows), after `bash scripts/bootstrap.sh`:

```sh
bash scripts/test-uxn.sh
bash scripts/test-build-guards.sh
bash scripts/build.sh
bash scripts/test-blog.sh
```

TAL/runtime changes need applicable semantic probes, native regressions and the
build. Content changes need a build and affected links/output inspection. Pure
prose edits need source/link review; avoid rerunning unrelated runtime tests.
ROM tests use the existing GNU timeout tool and close stdin. Treat timeout as a
failure, never as an expected parser rejection. Distinguish assembly failure,
runtime failure, waiting for input and nontermination.

Read the relevant source before changing a routine. State its stack effect,
widths, memory bounds, device results and loop progress where those matter.
Prefer a small, independently expected fixture to speculative broad rewrites.
Keep branches and stack operations readable instead of compressing new TAL into
long chains. Preserve working source idioms unless the change requires otherwise.

Implement routine authorized steps without repeated permission questions. Ask
when a product decision is missing or an external action needs authorization;
do not introduce an additional process for ordinary native changes. Verify before
claiming completion. Push/merge/deploy only within the owner's authorized scope;
never write to XXIIVV/oscean or cut over the production site implicitly.
