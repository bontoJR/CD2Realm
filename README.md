# Core Data 2 Realm

This is an experimental script written in ruby to convert a Core Data xml schema (named `contents.xml`) to Realm classes in Swift for a fast and handy usage.

## Requirements

This script has been tested and written using Ruby 2.2.1p85.

## Quick usage

Clone this repo, access the directory and run:

```sh
$ ruby script.rb [path to your contents.xml file]
```

The output will be a list of `.swift` files under `output` directory.