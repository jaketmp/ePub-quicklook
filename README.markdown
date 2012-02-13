# A QuickLook generator for Mac OS X

Designed to extract the cover images from ePub files to use as the file icon, and present a nice overview of the ePub in QuickLook.

This generator reads the various parameters directly from the ePub contents - so it will work on books that haven't been imported into iTunes.

**Note**: When used on DRM protected files (Adobe, iBooks, Kobo, Barnes & Noble), metadata will only be read from the unencrypted part of the ePub. Typically this means no cover image will be shown.

## Installation

Place the ePub.qlgenerator file into `/Library/QuickLook` (for all users) or `~/Library/QuickLook` (for the current user only).

### Conflict with other quicklook generators

Under some circumstances, epub.qlgenerator can conflict with other quicklook generators (notably BetterZipQL under OS X 10.6 and earlier). To fix this, rename epub.qlgenerator to come before the conflicting plugin alphabetically (AA_epub.qlgenerator should work).
