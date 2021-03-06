module IndexTests where

import Dict
import ElmTest exposing (..)
import String

import Index
import IndexModel exposing ( Index(..) )


-- useful with |> thenAnd chaining. avoid infix
thenAnd = flip Result.andThen


tests : Test
tests =
    suite "Index tests"
      [ suite "Index search tests" (List.map searchTest searchCases)
      , searchErr1 ()
      , searchErr2 ()
      , searchErr3 ()
      , idfCache1 ()
      , idfCache2 ()
      , addErr1 ()
      , addErr2 ()
      , addErr3 ()
      , removeErr1 ()
      , removeErr2 ()
      ]


-- example record type for tests
type alias MyDoc =
    { cid : String
    , title : String
    , author : String
    , body : String
    }


-- example index
index0 : Index MyDoc
index0 =
    Index.new
      { indexType = "- IndexTest Type -"
      , ref = .cid
      , fields =
          [ ( .title, 5 )
          , ( .body, 1 )
          ]
      }


type alias IndexResult = Result String (Index MyDoc)
type alias IndexAndListResult = Result String (Index MyDoc, List (String, Float))


{-
These are convenience functions to create tests.
They remove having to deal with Result types.
For use with cases that don't have setups that cause Err Results
-}
safeIndex : (() -> IndexResult) -> Index MyDoc
safeIndex result = Result.withDefault index0 (result ())


safeSearch : (() -> IndexAndListResult) -> (Index MyDoc, List (String, Float))
safeSearch result = Result.withDefault (index0, []) (result ())


safeSearchIndex : (() -> IndexAndListResult) -> Index MyDoc
safeSearchIndex result = fst (safeSearch result)


safeSearchList : (() -> IndexAndListResult) -> List (String, Float)
safeSearchList result = snd (safeSearch result)


index1 : () -> IndexResult
index1 _ = Index.add (index0) (doc1 ())


index2 : () -> IndexResult
index2 _ = Index.add (safeIndex index1) (doc2 ())


index2_banana : () -> IndexAndListResult
index2_banana _ = Index.search (safeIndex index2) "banana"


index3 : () -> IndexResult
index3 _ = Index.add (safeIndex index2) (doc3 ())


doc1 : () -> MyDoc
doc1 _ =
    { cid = "doc1"
    , title = "Examples of a Banana"
    , author = "Sally Apples"
    , body = "Sally writes words about a grown banana."
    }


doc2 : () -> MyDoc
doc2 _ =
    { cid = "doc2"
    , title = "Grown Bananas and there appeal"
    , author = "John Banana"
    , body = "An example of apple engineering."
    }


doc3 : () -> MyDoc
doc3 _ =
    { cid = "doc3"
    , title = "Kites and Trees a tail of misery"
    , author = "Adam Winddriven"
    , body = "When a flyer meets an Elm it maybe a problem."
    }


-- document has empty indexing fields
doc4 : () -> MyDoc
doc4 _ =
    { cid = "doc4"
    , title = ""
    , author = "Some Author"
    , body = ""
    }


-- document has empty reference
doc5 : () -> MyDoc
doc5 _ =
    { cid = ""
    , title = "Empty Reference Title"
    , author = "Some Author"
    , body = "Empty Reference Body"
    }


searchCases =
    [ ( "two docs one with term in title first", "example"
      , ["doc1", "doc2"], (safeIndex index2))
    , ( "two docs one with term in title first", "grown"
      , ["doc2", "doc1"], (safeIndex index2))
    , ( "returns doc with one of the words", "-misery! .appeal,"
      , ["doc2"], (safeIndex index2))
    , ( "with doc3 returns no docs with both words", "-misery! .appeal,"
      , [], (safeIndex index3))
    ]


searchTest (name, input, expect, index) =
    test ("search \"" ++ input ++ "\" " ++ name) <|
      assertEqual expect <|
        let
          result = Index.search index input
        in
          case result of
            Ok (index, docs) -> (List.map fst docs)
            Err _ -> ([]) -- Debug.crash(name)


searchErr1 _ =
    test "empty query returns Err" <|
      assertEqual (Err "Error query is empty.") <|
        Index.search (safeIndex index2) ""


searchErr2 _ =
    test "query full of stop words (filtered out words) returns Err" <|
      assertEqual (Err "Error after tokenisation there are no terms to search for.") <|
        Index.search (safeIndex index2) "if and but "


searchErr3 _ =
    test "no document returns Err" <|
      assertEqual (Err "Error there are no documents in index to search.") <|
        Index.search index0 "hello world"


idfCache1 _ =
    test "idfCache is cleared after a successful remove document." <|
      assertEqual (Ok "IDF Cache Empty")
        ( (Index.remove (safeSearchIndex index2_banana) (doc1 ()))
          |> thenAnd (\u2index2 -> (idfCacheStateTestMessage u2index2))
        )


idfCache2 _ =
    test "idfCache is cleared after a successful add document." <|
      assertEqual (Ok "IDF Cache Empty")
        ( (Index.add (safeSearchIndex index2_banana) (doc3 ()))
          |> thenAnd (\u2index2 -> (idfCacheStateTestMessage u2index2))
        )


addErr1 _ =
    test "Add a doc with has all index fields empty returns Err" <|
      assertEqual (Err "Error after tokenisation there are no terms to index.") <|
        Index.add index0 (doc4 ())


addErr2 _ =
    test "Add a doc with Err field empty returns Err" <|
      assertEqual (Err "Error document has an empty unique id (ref).") <|
        Index.add index0 (doc5 ())


addErr3 _ =
    test "Add a doc allready in index returns Err" <|
      assertEqual (Err "Error adding document that allready exists.") <|
        Index.add (safeIndex index2) (doc1 ())


documentStoreStateTestMessage index =
    if (Dict.size index.documentStore) == 0 then
      Ok "Document Store Empty"
    else
      Err "ERROR Document Store is NOT Empty"


idfCacheStateTestMessage (Index irec) =
    if (Dict.size irec.idfCache) == 0 then
      Ok "IDF Cache Empty"
    else
      Err "ERROR IDF Cache Empty is NOT Empty"


removeErr1 _ =
    test "Remove a doc with ref not in index returns Err." <|
      assertEqual (Err "Error document is not in index.") <|
        Index.remove (safeIndex index2) (doc3 ())


removeErr2 _ =
    test "Remove a doc with Err field empty is an error." <|
      assertEqual (Err "Error document has an empty unique id (ref).") <|
        Index.remove (safeIndex index2) (doc5 ())
