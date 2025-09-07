# chezscheme-monad

Haskell style `do`-notation in Chez Scheme

---

# library `(monad)`

## syntax `<-`

Auxiliary keyword for syntax `monad`.

## syntax `monad`

Mimics [Haskell's `do`-notation](https://en.wikibooks.org/wiki/Haskell/do_notation).

```scheme
(monad flat-map e e* ...)
```

- `flat-map` needs to be a valid flat map implementation
- the last form in `e e*...` must be a valid monadic value
- `e` may be a valid monadic value
- `e` may be a monadic binding form `(<- x mx)` where
  - `x` is a bound variable
  - `mx` must be a valid monadic value
- `e` may be a non-binding form
  - `(let binding binding* ...)` corresponds to `(let (binding binding* ...) (monad flat-map e* ...))`
  - `(let* binding binding* ...)` corresponds to `(let* (binding binding* ...) (monad flat-map e* ...))`
  - `(letrec binding binding* ...)` corresponds to `(letrec (binding binding* ...) (monad flat-map e* ...))`
  - `(let-values binding binding* ...)` corresponds to `(let-values (binding binding* ...) (monad flat-map e* ...))`
  - `(let*-values binding binding* ...)` corresponds to `(let*-values (binding binding* ...) (monad flat-map e* ...))`
- `e` may be a named non-binding form
  - `(let name binding binding* ...)` corresponds to `(let name (binding binding* ...) (monad flat-map e* ...))`

### Examples

#### flat-map implementations

```scheme
(define none '#(none))

(define (option-flat-map f mx)
  (if (eq? mx none) mx (f mx)))
```

```scheme
(define (list-flat-map f xs)
  (apply append (map f xs)))
```

```scheme
(define (identity-flat-map f x) (f x))
```

#### identity

```scheme
(monad option-flat-map 42)
; 42
```

```scheme
(monad list-flat-map (list 1 2 3))
; (1 2 3)
```

#### monadic binding

```scheme
(monad option-flat-map
  (<- x 5)
  (<- y 4)
  (+ x y))
; 9
```

```scheme
(monad option-flat-map
  (<- x 5)
  (<- y none)
  (+ x y))
; #(none)
```

```scheme
(monad list-flat-map
  (<- x (list 1 2 3))
  (<- y (list 4 5))
  (list (cons x y)))
; ([1 . 4] [1 . 5] [2 . 4] [2 . 5] [3 . 4] [3 . 5])
```

#### non-monadic binding

```scheme
(monad option-flat-map
  (let [x 7]
       [y none])
  x)
; 7
```

```scheme
(monad option-flat-map
  (let [x 7]
       [y none])
  y
  x)
; #(none)
```

```scheme
(monad identity-flat-map
  (let loop [i 1] [acc 0])
  (if (<= i 10)
      (loop (add1 i) (+ acc i))
      acc))
; 55
```
