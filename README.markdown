# A QuickLook generator for Mac OS X

Designed to extract the cover images from ePub files to use as the file icon, and present a nice overview of the ePub in QuickLook.

This generator reads the various parameters directly from the ePub contents - so it will work on books that haven't been imported into iTunes.

**Note**: When used on DRM protected files (Adobe ADEPT or iBooks Fairplay), metadata will only be read from the unencrypted part of the ePub. Typically this means no cover image will be shown.

## Installation

Place the ePub.quicklook generator file into `/Library/QuickLook` (for all users) or `~/Library/QuickLook` (for the current user only).

## Building the plugin

The plugin requires the **GDataXMLDocument** class from the [Google Data APIs Objective-C Client Library](http://code.google.com/p/gdata-objectivec-client/). Download `GDataXMLNode.h` and `GDataXMLNode.m` and place them in the `epub` folder.
