# Native HTML authoring contract

Articles use Oscean's existing HTML-fragment workflow. There is no Markdown
conversion or new authoring dependency. Optional conversion is deferred in HAR-120.
Use the toolchain and commands in [BUILDING.md](BUILDING.md).

## Article identity, title and hierarchy

Register each page in `src/lexicon`. A normal entry is one hexadecimal depth digit,
a literal space, and a lowercase name; keep entries in hierarchy order:

```text
0 home
1 about
1 topics
2 small systems
2 durable notes
```

This illustrates a small future lexicon; do not replace the current lexicon with
it before the content replacement work. A child has a depth one greater than its
parent. Place children immediately after their parent and preceding siblings;
return to the parent's depth for its next sibling. Prefer ordinary space entries.
Punctuation after the depth selects upstream modules (`.`, `,`, `;`, `#`), so it
is not interchangeable with a space.

The lexicon name supplies the page label and title. Keep names short, unique,
lowercase ASCII words separated by single spaces, at most 21 characters including spaces.
The name/parent buffers have 22 bytes including their terminator. Use letters and digits; avoid
punctuation, slashes and underscores in the name. These are authoring conventions,
not a new validator. Oscean has fixed memory buffers; keep articles and the lexicon
small and review diagnostics as content grows.

The name `small systems` maps to:

| Purpose | Path |
| --- | --- |
| Authored fragment | `src/htm/small_systems.htm` |
| Generated page | `site/small_systems.html` |
| Link from another article | `small_systems.html` |

Treat that name/slug as permanent once published. Renaming changes URLs and requires
updating links and deciding whether the old URL needs preservation.

## HTML fragment

Write UTF-8 text with LF endings. Use an editor that preserves those settings.
The fragment contains article body HTML, without `doctype`, `html`, `head`, `body`
or a second navigation/header/footer. Oscean adds the shared page structure.
Use descriptive headings, paragraphs, lists, code and ordinary anchors. Existing
articles commonly begin with an `h2` introduction.

For `src/htm/small_systems.htm`:

```html
<h2>Keeping useful systems understandable.</h2>

<p>A small system should be easy to inspect and maintain.
See <a href="durable_notes.html">durable notes</a> for a related practice.</p>

<h3 id="maintenance">Maintenance</h3>
<p>Keep source files, build instructions and assets together.</p>

<ul>
  <li>Prefer ordinary text and standard HTML.</li>
  <li>Record decisions that affect future maintenance.</li>
</ul>
```

Create and register `durable notes` as well before using that example link. A second
fragment can link back with `<a href="small_systems.html">small systems</a>`.
An empty or missing article fragment is not a substitute for authored content.

## Links and assets

Use ordinary HTML links, not wiki-link or template syntax:

- Same-site article: `<a href="small_systems.html">small systems</a>`.
- Same-page section: `<a href="#maintenance">maintenance</a>` with a matching `id`.
- Other article section: `<a href="small_systems.html#maintenance">maintenance</a>`.
- External page: `<a href="https://example.org/">example</a>`.
- Image: `<img src="../media/articles/example.png" alt="Description">`.
- Download: `<a href="../media/articles/example.pdf">Download PDF</a>`.

Store original assets under `media/` and retain their licensing/provenance.
Paths are relative to the generated `site/` page, not the source directory.
Avoid root-absolute `/site/...` paths so project-site previews remain possible.

Use lowercase `href=` with a single- or double-quoted value and no spaces around
the equals sign. The backlink scanner expects that spelling; it is not a full HTML
parser. The generator scans these article links to collect incoming links and reports
unknown internal targets. The exact target page must be in the lexicon. Review
its diagnostics; plain hierarchy entries without incoming links can produce
orphan warnings. Local assets and section IDs also need manual review: a successful
build is not a complete browser/link validator.

## Build and review

1. Register the name/depth in `src/lexicon`.
2. Create its matching `src/htm/<slug>.htm` fragment and add any original assets.
3. Add a link from an existing article so the new page is discoverable.
4. From an LF checkout in the configured shell, run `bash scripts/build.sh`.
5. Read the diagnostics, inspect `site/<slug>.html`, and check hierarchy, links,
   incoming links and assets in a browser.
6. Review the Git diff before committing authored inputs. The current upstream
   build also rewrites generated pages, feeds and REPL assets; minimal publish
   output is separate roadmap work in HAR-113.

Remove a page by removing its lexicon entry, fragment and incoming references,
then rebuild. The current `make run` clears generated `site/` pages before writing
them again. Do not hand-edit generated `site/*.html` as article source.
Do not run the bundled `make push` target; use ordinary reviewed Git operations.

## Dates and the existing journal

Evergreen articles do not need journal records. If a visible article date is useful,
write an ISO date such as `2026-11-05` in the body; it does not automatically become
a journal entry or feed item.

Retaining the journal is still an owner decision for HAR-111. Until then, preserve
the existing journal mechanism: `src/logs/NN.tsv` records use upstream Arvelie date
codes, a topic name and a description separated by real tab characters. Topic names
must exactly match lexicon names. A date such as `20V14+000` is an upstream code,
not an ISO date; do not invent Gregorian-to-Arvelie conversions. The generator has
hardcoded year ranges, so a new year or calendar change requires inspecting the
existing Uxntal sources and rebuilding the relevant ROMs.

Journal, events and sitemap fragments are generated during the build. Shared
`meta_head`, `meta_header` and `meta_footer` fragments are also part of the page
system. Do not remove these as ordinary articles when stripping upstream content.

## Portability and exit

Keep articles as body HTML with standard tags and ordinary links. Avoid embedded
site-specific navigation and generator macros. Preserve original media separately.
Another generator can wrap these fragments in its own templates; no Markdown
conversion is needed to retain the authored content.

On exit, translate `src/lexicon` into the new generator's title/slug/parent metadata,
keep the published `<slug>.html` URL mapping where possible, and retain or rewrite
relative asset paths deliberately. Journal TSV/date codes and module punctuation
need separate metadata/calendar translation. Generated navigation, backlinks,
feeds and shared templates can be recreated from the authored inputs.
