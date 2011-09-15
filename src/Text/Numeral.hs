module Text.Numeral
    ( -- * Overview
      -- $overview

      -- ** Expression language
      -- $dsl

      -- ** Rules
      -- $rules

      -- ** Rendering
      -- $render

      module Text.Numeral.Exp
    , module Text.Numeral.Render
    , module Text.Numeral.Rules
    )
    where

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------

-- from numerals:
import Text.Numeral.Exp
import Text.Numeral.Render
import Text.Numeral.Rules

-------------------------------------------------------------------------------
-- Documentation
-------------------------------------------------------------------------------

{- $overview

The general idea behind this package is to take a number, convert that
number to an abstract representation of its spoken form and finally
render that representation to a string-like value.

-}

{- $dsl

Numerals are represented by a small expression language defined in the
"Text.Numeral.Exp.Classes" module. This language is also reified as
the concrete type 'Exp' in the "Text.Numeral.Exp" module.

-}

{- $rules

Conversion from numbers to numerals is the responsibility of
rules. The 'Rule' type itself and a number of useful rules are defined
in the "Text.Numeral.Rules" module. All rules are completely
polymorphic in their types. Their result types are only constrained by
the type classes that make up the numeral expression language.

-}

{- $render

Finally, the "Text.Numeral.Render" module is responsible for
converting the numeral expression language to a string-like
value. This happens via the 'render' function. Render is parametrised
with a 'Repr' value which contains all the knowledge on how to convert
the abstract expression to a concrete string-like value. The
expression itself is passed as a concrete 'Exp' value. The only
constrained on the final value is that it is a 'Monoid'.

-}
