# Russ Ballard's wiki

A minimal personal wiki using [Oscean](https://github.com/XXIIVV/oscean), written in
Uxntal for Uxn. Native HTML fragments supply articles; a lexicon supplies hierarchy
and the generator builds navigation and incoming links. The blog uses explicit
Gregorian `YYYY-MM-DD` dates.

- [BUILDING.md](BUILDING.md): Windows/MSYS2 and Linux setup with pinned tools.
- [AUTHORING.md](AUTHORING.md): articles, links, hierarchy and dated blog entries.

The initial pages contain clearly marked writing placeholders and a sample blog
entry. The CV page links the existing PDF on r-ballard.github.io. This repository
is separate from that production site; no deployment or cutover is configured here.

## License and provenance

Generator code and the retained stylesheet derive from Oscean by Devine Lu Linvega
and contributors under the [MIT license](LICENSE). The original upstream article,
diary, media and demo collections have been removed. Source baseline:
`21b90a19f63ad92b42d8bc75e8a4057f43f1dc27`.

The native blog generator is adapted from the upstream dated-entry generator;
it uses explicit ISO-dated inputs rather than Arvelie periods. No Markdown
converter, Python runtime or external authoring dependency is required.
