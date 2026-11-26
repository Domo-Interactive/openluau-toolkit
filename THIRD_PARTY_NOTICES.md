# Third-party notices

No third-party implementation code, assets or runtime packages are bundled in the toolkit source. The Domo Interactive logo was supplied by the project owner. Links in research documentation are references, not declared runtime dependencies or endorsements.

## Development tools

The optional development installer downloads official [Luau](https://github.com/luau-lang/luau) 0.748 executables into the ignored `.tools/` directory and checks the published archive SHA-256 values. Luau is MIT-licensed; it remains an upstream development tool and is not redistributed as toolkit source.

The GitHub workflow uses [actions/checkout](https://github.com/actions/checkout) v7.0.1, pinned to commit `3d3c42e5aac5ba805825da76410c181273ba90b1`. Its source is not bundled here. These tools retain their own licences.

Before adding or copying a dependency, record its upstream URL, exact version/commit, licence, modifications and required notices. Preserve all applicable terms in any distributed artefact; the toolkit's MIT licence does not replace a third party's licence.
