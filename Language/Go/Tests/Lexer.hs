module Language.Go.Tests.Lexer (testsLexer) where

import Test.HUnit

import Language.Go.Parser.Lexer
import Language.Go.Parser.Parser (goTokenize)
import Language.Go.Parser.Tokens

testLex :: String -> String -> [GoToken] -> Test
testLex desc text ref = TestLabel desc $ TestCase $ assertEqual desc ref toks
  where toks = map strip $ goTokenize text
        strip (GoTokenPos _ tok) = tok

testRawString1 = testLex "raw string"
  "`hello`"
  [ GoTokStr (Just "`hello`") "hello"
  , GoTokSemicolon]

testRawString2 = testLex "raw multiline string"
  "`hello\n\tworld`"
  [ GoTokStr (Just "`hello\n\tworld`") "hello\n\tworld"
  , GoTokSemicolon]

testCharLit1 = testLex "rune literal for backslash"
  "'\\\\'"
  [ GoTokChar (Just "'\\\\'") '\\'
  , GoTokSemicolon]

testCharLit2 = testLex "rune literal for newline"
  "'\\n'"
  [ GoTokChar (Just "'\\n'") '\n'
  , GoTokSemicolon]

testCharLit3 = testLex "rune literal for e-acute"
  "'é'"
  [ GoTokChar (Just "'é'") 'é'
  , GoTokSemicolon]

testCharLit4 = testLex "rune literal with octal escaping"
  "'\\377'"
  [ GoTokChar (Just "'\\377'") '\xff'
  , GoTokSemicolon]

testString1 = testLex "string with backslash"
  "\"\\\\\""
  [ GoTokStr (Just "\"\\\\\"") "\\"
  , GoTokSemicolon]

testString2 = testLex "long string with backslash"
  "{\"\\\\\", \"a\", false, ErrBadPattern},"
  [ GoTokLBrace
  , GoTokStr (Just "\"\\\\\"") "\\"
  , GoTokComma,GoTokStr (Just "\"a\"") "a"
  , GoTokComma
  , GoTokId "false"
  , GoTokComma
  , GoTokId "ErrBadPattern"
  , GoTokRBrace
  , GoTokComma
  ]

testString3 = testLex "string with tab"
  "\"\t\""
  [ GoTokStr (Just "\"\t\"") "\t"
  , GoTokSemicolon]

testString4 = testLex "string literal with octal escaping"
  "\"\\377\""
  [ GoTokStr (Just "\"\\377\"") "\xff"
  , GoTokSemicolon]

testId1 = testLex "non-ASCII identifier"
  "α := 2"
  [ GoTokId "α"
  , GoTokColonEq
  , GoTokInt (Just "2") 2
  , GoTokSemicolon
  ]

testsLexer =
  [ testRawString1
  , testRawString2
  , testCharLit1
  , testCharLit2
  , testCharLit3
  , testCharLit4
  , testString1
  , testString2
  , testString3
  , testString4
  , testId1
  ]
