{-# LANGUAGE NoImplicitPrelude
           , PackageImports
           , TypeSynonymInstances
           , UnicodeSyntax
  #-}

module Text.Numeral.Exp.Classes
    ( Unknown(unknown, isUnknown)
    , Lit(lit)
    , Neg(neg)
    , Add(add)
    , Mul(mul)
    , Sub(sub)
    , Scale(scale)
    , Dual(dual)
    , Plural(plural)
    ) where

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------

import "base" Data.Bool ( Bool(False) )
import "base" Data.Function ( const )
import "base" Prelude ( (+), (*), (^), subtract, negate, fromInteger, error )
import "base-unicode-symbols" Prelude.Unicode ( ℤ, (⋅) )


-------------------------------------------------------------------------------
-- Exp classes
-------------------------------------------------------------------------------

-- | An unknown value. This is used to signal that a value can not be
-- represented in the expression language.
--
-- Law: isUnknown unknown == True
class Unknown α where
    unknown ∷ α
    isUnknown ∷ α → Bool

-- | A literal value.
--
-- Example in English:
--
-- > "three" = lit 3
class Lit α where lit ∷ ℤ → α

-- | Negation of a value.
--
-- Example in English:
--
-- > "minus two" = neg (lit 2)
class Neg α where neg ∷ α → α

-- | Addition of two values.
--
-- Example in English:
--
-- > "fifteen" = lit 5 `add` lit 10
class Add α where add ∷ α → α → α

-- | Multiplication of two values.
--
-- Example in English:
--
-- > "thirty" = lit 3 `mul` lit 10
class Mul α where mul ∷ α → α → α

-- | One value subtracted from another value.
--
-- Example in Latin:
--
-- > "duodēvīgintī" = lit 2 `sub` (lit 2 `mul` lit 10)
class Sub α where sub ∷ α → α → α

-- | A step in a scale of large values.
--
-- Should be interpreted as @10 ^ (rank * base + offset)@.
--
-- Example in English:
--
-- > "quadrillion" = scale 3 3 4
class Scale α where
    scale ∷ ℤ -- ^ Base.
          → ℤ -- ^ Offset.
          → α -- ^ Rank.
          → α

-- | A dual of a value.
--
-- This is used in some languages that express some values as the dual
-- of a smaller value. For instance, in Hebrew the number 20 is
-- expressed as the dual of 10.
class Dual α where dual ∷ α → α

-- | A plural of a value.
--
-- This is used in some languages that express some values as the
-- plural of a smaller value. For instance, in Hebrew the numbers
-- [30,40..90] are expressed as the plurals of [3..9].
class Plural α where plural ∷ α → α

infixl 6 `add`
infixl 6 `sub`
infixl 7 `mul`


-------------------------------------------------------------------------------
-- Integer instances
-------------------------------------------------------------------------------

instance Unknown ℤ where
    unknown   = error "unknown"
    isUnknown = const False
instance Lit ℤ where lit = fromInteger
instance Neg ℤ where neg = negate
instance Add ℤ where add = (+)
instance Mul ℤ where mul = (*)
instance Sub ℤ where sub = subtract
instance Scale ℤ where scale b o r = 10 ^ (r⋅b + o)
