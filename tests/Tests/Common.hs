-- |
-- Module      : Tests.Common
-- Copyright   : (c) 2013 Rémy Oudompheng
-- License     : GPLv3 (see COPYING)
-- 
-- This module provides utility functions for concise syntax
-- of test cases.

module Tests.Common where

import Test.Tasty
import Test.Tasty.HUnit

import Text.Parsec.Combinator (eof, optional)
import Text.Parsec.Error

import Language.Go.Parser.Parser
import Language.Go.Parser.Tokens
import Language.Go.Syntax.AST

strerror :: Either ParseError a -> Either String a
strerror (Left err) = Left (show err)
strerror (Right x) = Right x

testParse :: (Show a, Eq a) => String -> GoParser a -> String -> a -> TestTree
testParse desc parser text ref = testCase desc $ assertEqual desc want got
    where got = strerror $ goParseTestWith (do { p <- parser; optional goTokSemicolon; eof; return p }) text
          want = Right ref

testParseFail :: (Show a, Eq a) => String -> GoParser a -> String -> TestTree
testParseFail desc parser text = testCase desc $ assertBool (show got) isLeft
    where got = goParseTestWith (do { p <- parser; optional goTokSemicolon; eof; return p }) text
          isLeft = case got of Left _ -> True; Right _ -> False

namedType :: String -> GoType
namedType = GoTypeName Nothing . GoId

ident :: String -> GoExpr
ident s = GoPrim $ GoQual Nothing (GoId s)


