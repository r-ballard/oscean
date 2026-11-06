
## Article identity, title and hierarchy

Register each page in `src/lexicon`. A normal entry is one hexadecimal depth digit,
a literal space, and a lowercase name; keep entries in hierarchy order:

```text
0 home
1 about
2 russ ballard
3 cv
3 academic
3 professional
3 blog
2 meta
```

This is the current hierarchy. A child has a depth one greater than its parent. Place children immediately after their parent and preceding siblings;
return to the parent's depth for its next sibling. Prefer ordinary space entries.
Use a space after the depth. Upstream punctuation modules (`.`, `,`, `;`, `#`)
are reserved and are not enabled in this minimal page workflow.

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
6. Review the Git diff before committing authored inputs. Generated site pages,
   feed XML and blog/sitemap fragments are ignored; do not commit them as source.

Remove a page by removing its lexicon entry, fragment and incoming references,
then rebuild. The current `make run` clears generated `site/` pages before writing
them again. Do not hand-edit generated `site/*.html` as article source.
The build scripts do not push; use ordinary reviewed Git operations.

## Dated blog entries

The blog uses Gregorian `YYYY-MM-DD` dates exclusively. Dates are authored, not
inferred from the build clock or file modification times. Rebuilding preserves
the publication date. There is no separate journal page or Arvelie date input.

`src/blog/index.txt` lists one entry ID per line, newest publication date first:

```text
2026-11-05-sample-entry
```

Each ID is `YYYY-MM-DD-slug`; use a short lowercase ASCII slug with hyphens.
Create `src/blog/<ID>.htm`. Its first line is the plain title; the remaining lines
are the native HTML body, for example:

```html
Sample entry
<p><strong>Sample entry.</strong> This demonstrates the blog format.</p>
<p>See <a href="meta.html">meta</a> for how the wiki works.</p>
```

This first title line is specific to blog sources, not ordinary article fragments.
The blog generator validates dates, including leap days, and refuses invalid or
missing inputs. Register each ID once. Multiple entries on the same date retain
the manifest's chosen order. The generated URL is `blog.html#<ID>`; authored body
links and asset paths are relative to that page in `site/`.

Set `src/site-url.txt` to the absolute publication base URL, ending in `/`.
The current `https://r-ballard.github.io/oscean/` value is the proposed fork
Pages preview base, not a production cutover. Confirm it before deployment.
The feed generator requires it so readers can resolve entry links.

Run `bash scripts/build.sh` after changing entries. It rebuilds `src/htm/blog.htm`
and `links/log.xml` before the page engine. Those are generated outputs. Removing
an ID from the manifest and rebuilding removes its rendered entry and feed item.
An existing empty manifest generates a blog with a no-posts message and an empty
RSS channel; a missing manifest is an error. If changing a published ID, preserve
incoming links deliberately.

Use explicit ISO dates for any visible article timestamps too. RSS publication
dates use the standard Gregorian RSS date syntax required by feed readers; this
is serialization, not an additional authoring calendar. Feed descriptions are
date/title summaries, with absolute links to the full HTML entries.

The repository's initial entry is explicitly labeled sample content, not a real
personal event. Replace or remove it before publishing personal writing.
## Portability and exit

Keep articles as body HTML with standard tags and ordinary links. Avoid embedded
site-specific navigation and generator macros. Preserve original media separately.
Another generator can wrap these fragments in its own templates; no Markdown
conversion is needed to retain the authored content.

On exit, translate `src/lexicon` into the new generator's title/slug/parent metadata,
keep the published `<slug>.html` URL mapping where possible, and retain or rewrite
relative asset paths deliberately. Blog manifest order and title lines
need separate metadata translation. Blog dates already use ISO Gregorian form. Generated navigation, backlinks,
feeds and shared templates can be recreated from the authored inputs.
