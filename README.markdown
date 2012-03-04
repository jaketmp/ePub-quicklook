# An EPUB QuickLook generator and Spotlight importer for Mac OS X

The epub.qlgenerator plugin is designed to extract the cover images from ePub files to use as the file icon, and present a nice overview of the ePub in QuickLook.

The epub.mdimporter plugin is designed to extract information from ePub files (including text content) and index it so that Spotlight can search it.

These plugins read the various information directly from the ePub contents - so will work on books that haven't been imported into iTunes.

**Note**: When used on DRM protected files (Adobe, iBooks, Kobo, Barnes & Noble), metadata will only be read from the unencrypted part of the ePub. Typically this means no cover image will be shown. Spotlight is unable to index the text in DRM protected files.

## Installation

Place the epub.qlgenerator file into `/Library/QuickLook` (for all users) or `~/Library/QuickLook` (for the current user only).

Place the epub.mdimporter file into `/Library/Spotlight` (for all users) or `~/Library/Spotlight` (for the current user only).

### Conflict with other QuickLook generators

Under some circumstances, epub.qlgenerator can conflict with other quicklook generators (notably BetterZipQL under OS X 10.6 and earlier). To fix this, rename epub.qlgenerator to come before the conflicting plugin alphabetically (AA_epub.qlgenerator should work).
