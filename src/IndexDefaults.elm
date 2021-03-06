module IndexDefaults
    ( indexVersion
    , lunrelmIndexType
    , defaultTransformFactories
    , defaultFilterFactories
    , defaultTokenTrimmerFuncCreator
    , defaultStemmerFuncCreator
    , defaultStopWordFilterFuncCreator
    , getDefaultIndexConfig
    ) where

{-| Where to get defaults for Lunrelm Index options.

## Lunrelm Index Storage Engine Version and Type
@docs indexVersion
@docs lunrelmIndexType


## Built in Transforms and Filters
@docs defaultTransformFactories
@docs defaultFilterFactories
@docs defaultTokenTrimmerFuncCreator
@docs defaultStemmerFuncCreator
@docs defaultStopWordFilterFuncCreator


## Config type adapters
@docs getDefaultIndexConfig

Copyright (c) 2016 Robin Luiten
-}

import Stemmer

import IndexModel exposing (TransformFactory, FilterFactory)
import IndexUtils
import StopWordFilter
import TokenProcessors


{-| The version of index, for loading a saved index.

This is not the same as Lunrelm package version.

This needs to change if the encoded format changes.
-}
indexVersion : String
indexVersion = "1.0.0"


{-| The type of index Lunrelm defaults to using.

It defines the default token transforms and filters.
-}
lunrelmIndexType : String
lunrelmIndexType = "-= Lunrelm Index Type 1 =-"


{-| Lunrelm index default transform factories. -}
defaultTransformFactories : List (TransformFactory doc)
defaultTransformFactories =
    [ defaultTokenTrimmerFuncCreator
    , defaultStemmerFuncCreator
    ]


{-| Lunrelm index default filter factories. -}
defaultFilterFactories : List (FilterFactory doc)
defaultFilterFactories =
    [ defaultStopWordFilterFuncCreator
    ]


{-| The default token trimmer transform function creator.
Normally applied first in transform functions.
-}
defaultTokenTrimmerFuncCreator : TransformFactory doc
defaultTokenTrimmerFuncCreator =
    IndexUtils.createFuncCreator TokenProcessors.trimmer


{-| The default token stemmer transform function creator. -}
defaultStemmerFuncCreator : TransformFactory doc
defaultStemmerFuncCreator =
    IndexUtils.createFuncCreator Stemmer.stem


{-| The default stop word filter function creator. -}
defaultStopWordFilterFuncCreator : FilterFactory doc
defaultStopWordFilterFuncCreator =
    StopWordFilter.createDefaultFilterFunc


{-| Convert IndexModel.SimpleConfig to IndexModel.Config

Filling in default values for fields not in SimpleConfig

This is the definition of the default index configuration.
-}
getDefaultIndexConfig : IndexModel.SimpleConfig doc -> IndexModel.Config doc
getDefaultIndexConfig {indexType, ref, fields} =
      { indexType = indexType
      , ref = ref
      , fields = fields
      , transformFactories = defaultTransformFactories
      , filterFactories = defaultFilterFactories
      }
