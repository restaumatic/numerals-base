{-# LANGUAGE NoImplicitPrelude, OverloadedStrings, UnicodeSyntax #-}

{-|
[@ISO639-1@]        fr

[@ISO639-2B@]       fre

[@ISO639-3@]        fra

[@Native name@]     Français

[@English name@]    French
-}

module Text.Numeral.Language.FR
    ( cardinal
    , struct
    , cardinalRepr
    ) where


--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Control.Monad ( (>=>) )
import Data.Bool     ( otherwise )
import Data.Function ( ($), const, fix )
import Data.Maybe    ( Maybe(Just) )
import Data.Monoid   ( Monoid )
import Data.Ord      ( (<) )
import Data.String   ( IsString )
import Prelude       ( Integral, (-), Integer )

-- from base-unicode-symbols:
import Data.Ord.Unicode ( (≤), (≥) )

-- from containers:
import qualified Data.Map as M ( fromList, lookup )

-- from numerals:
import Text.Numeral
import Text.Numeral.Misc ( dec )
import qualified Text.Numeral.BigNum      as BN
import qualified Text.Numeral.Exp.Classes as C


--------------------------------------------------------------------------------
-- FR
--------------------------------------------------------------------------------

{-
Sources:
  http://www.sf.airnet.ne.jp/~ts/language/number/french.html
  http://www.french-linguistics.co.uk/tutorials/numbers/
-}

cardinal ∷ (Monoid s, IsString s, Integral α, C.Scale α) ⇒ α → Maybe s
cardinal = struct >=> cardinalRepr

struct ∷ ( Integral α, C.Scale α
         , C.Lit β, C.Neg β, C.Add β, C.Mul β, C.Scale β
         )
       ⇒ α → Maybe β
struct = pos $ fix $ rule `combine` pelletierScale1 R L BN.rule
    where
      rule = findRule (   0, lit         )
                    [ (  11, add   10 L  )
                    , (  17, add   10 R  )
                    , (  20, lit         )
                    , (  21, add   20 R  )
                    , (  30, mul   10 R L)
                    , (  70, add   60 R  )
                    , (  80, mul   20 R L)
                    , (  89, add   80 R  )
                    , ( 100, lit         )
                    , ( 101, add  100 R  )
                    , ( 200, mul  100 R L)
                    , (1000, lit         )
                    , (1001, add 1000 R  )
                    , (2000, mul 1000 R L)
                    ]
                      (dec 6 - 1)

cardinalRepr ∷ (Monoid s, IsString s) ⇒ Exp → Maybe s
cardinalRepr = textify defaultRepr
               { reprValue = \n → M.lookup n symMap
               , reprScale = pelletierRepr
               , reprAdd   = (⊞)
               , reprMul   = (⊡)
               , reprNeg   = \_ → Just "moins "
               }
    where
      Lit n                ⊞ Lit 10       | n ≤ 6 = Just ""
      Lit 10               ⊞ Lit n        | n ≥ 7 = Just "-"
      (Lit 4 `Mul` Lit 20) ⊞ _                    = Just "-"
      _                    ⊞ (Lit 1 `Add` Lit 10) = Just " et "
      _                    ⊞ Lit 1                = Just " et "
      (Lit _ `Mul` Lit 10) ⊞ _                    = Just "-"
      Lit 20               ⊞ _                    = Just "-"
      _                    ⊞ _                    = Just " "

      _ ⊡ Lit 10 = Just ""
      _ ⊡ Lit 20 = Just "-"
      _ ⊡ _      = Just " "

      symMap = M.fromList
               [ (0, const "zéro")
               , (1, ten   "un"     "on"     "un")
               , (2, ten   "deux"   "dou"    "deux")
               , (3, ten   "trois"  "trei"   "tren")
               , (4, ten   "quatre" "quator" "quar")
               , (5, ten   "cinq"   "quin"   "cinqu")
               , (6, ten   "six"    "sei"    "soix")
               , (7, const "sept")
               , (8, const "huit")
               , (9, const "neuf")
               , (10, \c → case c of
                             CtxAddR (Lit n) _ | n < 7     → "ze"
                                               | otherwise → "dix"
                             CtxMulR (Lit 3) _             → "te"
                             CtxMulR {}                    → "ante"
                             _                             → "dix"
                 )
               , (20,   \c → case c of
                               CtxMulR _ CtxEmpty → "vingts"
                               _ → "vingt"
                 )
               , (100,  \c → case c of
                               CtxMulR _ CtxEmpty → "cents"
                               _ → "cent"
                 )
               , (1000, const "mille")
               ]

      ten n a m ctx = case ctx of
                        CtxAddL (Lit 10) _ → a
                        CtxMulL (Lit 10) _ → m
                        _                  → n

pelletierRepr ∷ (IsString s, Monoid s)
              ⇒ Integer → Integer → Exp → Ctx Exp → Maybe s
pelletierRepr = BN.pelletierRepr
                  "illion" "illions"
                  "illiard" "illiards"
                  [ (1, BN.forms "m"  "uno" "uno"  ""    "")
                  , (3, BN.forms "tr" "tré" "tres" "tri" "tre")
                  , (10, \c → case c of
                                CtxAddL (Lit 100) _             → "deci"
                                CtxMulR _ (CtxAddL (Lit 100) _) → "ginta"
                                CtxMulR {}                      → "gint"
                                _                               → "déc"
                    )
                  ]