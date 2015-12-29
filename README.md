# Lunrelm full text indexer

Copyright (c) 2016 Robin Luiten

## Deprecated
This package has been replaced by ElmTextSearch package.
* http://package.elm-lang.org/packages/rluiten/elm-text-search/latest

So this package will no longer be updated or maintained.

## Original documentation Below here.

This is a full text indexing engine inspired by lunr.js and written in Elm language.
See http://lunrjs.com/ for lunr.js

While Lunerlm has a good selection of tests this library is not battle tested and may contain some performance issues that need
addressing still.

Several packages were created for this project and published seperately for this package to depend on.

* trie
 * http://package.elm-lang.org/packages/rluiten/trie/latest
* stemmer
 * http://package.elm-lang.org/packages/rluiten/stemmer/latest
* sparsevector
 * http://package.elm-lang.org/packages/rluiten/sparsevector/latest



### Parts of lunr.js were left out

* This does not have an event system.
* Its internal data structure is not compatible.

### Notes captured along way writing this.

* lunr.js
 * tokenStore.remove does not decrement length, but it doesnt use length really only save/load
 * stemmer "lay" -> "lay" "try" -> "tri" is opposite to porter stemmer
* porter stemmer erlang implementation
 * step5b does not use endsWithDoubleCons which is required afaik to pass the voc.txt output.txt cases
