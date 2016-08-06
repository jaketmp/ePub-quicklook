# An EPUB QuickLook generator and Spotlight importer for Mac OS X

The **epub.qlgenerator** plugin is designed to extract the cover images from EPUB files to use as the file icon, and present a nice overview of the EPUB in QuickLook.

The **epub.mdimporter** plugin is designed to extract information from EPUB files (metadata as well as text content) and index it so that Spotlight can search it.

These plugins read the various information directly from the EPUB contents - so will work on books that haven't been imported into iTunes.

**Note**: When used on DRM protected files (Adobe, iBooks, Kobo, Barnes & Noble), metadata will only be read from the unencrypted part of the EPUB. Typically this means no cover image will be shown. Spotlight is also unable to index the text in DRM protected files, though it can still search the metadata in DRM protected files.

## Installation

### Homebrew [Caskroom](https://github.com/caskroom/homebrew-cask/)

    brew cask install epubquicklook epubmdimporter

### Manual

After downloading and extracting the zip files from the **[Releases](https://github.com/jaketmp/ePub-quicklook/releases/latest)** tab above, drag each of the plugins to the folder indicated. This will install the plugins for all users (you may need to enter the password for an administrator). If you lack administrator privileges or only wish to install for one user, follow the instructions below. 

Place the **epub.qlgenerator** file into `/Library/QuickLook` (for all users) or `~/Library/QuickLook` (for the current user only).

The Mac should notice the plugin appearing and start using it automatically. If it doesn't seem to, try logging out and in again, or run Terminal.app and enter this command:

    qlmanage -r

and press return.

Place the **epub.mdimporter** file into `/Library/Spotlight` (for all users) or `~/Library/Spotlight` (for the current user only).

To use the new Spotlight plugin you have to first make it index your EPUB files. This can be tricky. One way is to run Terminal.app and enter this command:

    mdimport -r /Library/Spotlight/epub.mdimporter

or:

    mdimport -r ~/Library/Spotlight/epub.mdimporter

if you installed it for the current user only) and press return. There are other ways to run mdimport which might also help - see its man page for more details.

Spotlight will begin indexing your EPUB files in the background.

### Conflict with other QuickLook generators

Under some circumstances, **epub.qlgenerator** can conflict with other QuickLook generators (notably BetterZipQL under OS X 10.6 and earlier). To fix this, rename **epub.qlgenerator** to come before the conflicting plugin alphabetically (for example **AA_epub.qlgenerator** should work).
