# Fn

Fn is a utility library for working with functions in Elixir.

It is inspired by
[`goog.functions`](https://google.github.io/closure-library/api/goog.functions.html)
from the
[Google Closure](https://github.com/google/closure-library)
JavaScript library.

```
| Fn           | goog.functions |
| ------------ | -------------- |
| _false/0     | FALSE( arg0 ) → boolean |
| _nil/0       | NULL( arg0 ) → null |
| _true/0      | TRUE( arg0 ) → boolean |
| ok/0         | *NA* |
| ok/1         | *NA* |
| error/0      | *NA* |
| error/1      | *NA* |
| _and/1       | and( ...var_args ) → function(...?): boolean |
| xxx          | cacheReturnValue<T>( fn ) → function(): T |
| compose/1    | compose<T>( fn, ...var_args ) → function(...?): T |
| rcompose/1   | *NA* |
| constant/1   | constant<T>( retValue ) → function(): T |
| *NA*         | create<T>( constructor, ...var_args ) → T |
| xxx          | debounce<SCOPE>( f, interval, opt_scope ) → function(...?): undefined |
| xxx          | equalTo( value, opt_useLooseComparison ) → function(*): boolean |
| xxx          | error( message ) → Function |
| _raise/1     | fail( err ) → Function |
| xxx          | identity<T>( opt_returnValue, ...var_args ) → T |
| xxx          | lock( f, opt_numArgs ) → Function |
| xxx          | not( f ) → function(...?): boolean |
| xxx          | nth( n ) → Function |
| xxx          | once( f ) → function(): undefined |
| _or/1        | or( ...var_args ) → function(...?): boolean |
| partial/2    | goog.partial |
| partial/3    | goog.partial |
| rpartial/2   | partialRight( fn, ...var_args ) → Function |
| rpartial/3   | goog.partial |
| xxx          | sequence( ...var_args ) → Function |
| xxx          | throttle<SCOPE>( f, interval, opt_scope ) → function(...?): undefined |
| xxx          | withReturnValue<T>( f, retValue ) → function(...?): T |
| arity/1      | - |
```
