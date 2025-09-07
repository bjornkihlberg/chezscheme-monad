#!chezscheme

(library (monad)
  (export monad <-)

  (import (chezscheme))

  (define-syntax (<- code) (syntax-error code "misplaced aux keyword"))

  (define-syntax monad
    (syntax-rules (<- let let* letrec let-values let*-values)
      [(_ _ body) body]

      [(_ flat-map body body* ...)
        (not (identifier? #'flat-map))
        (let ([id flat-map]) (monad id body body* ...))]

      [(_ flat-map (<- x mx) body body* ...)
        (flat-map (lambda (x) (monad flat-map body body* ...)) mx)]

      [(_ flat-map (let name binding* ...) body body* ...)
        (identifier? #'name)
        (let name (binding* ...) (monad flat-map body body* ...))]

      [(_ flat-map (binding-form binding binding* ...) body body* ...)
        (or (free-identifier=? #'binding-form #'let)
            (free-identifier=? #'binding-form #'let*)
            (free-identifier=? #'binding-form #'letrec)
            (free-identifier=? #'binding-form #'let-values)
            (free-identifier=? #'binding-form #'let*-values))
        (binding-form (binding binding* ...) (monad flat-map body body* ...))]

      [(_ flat-map mx body body* ...)
        (flat-map (lambda (x) (monad flat-map body body* ...)) mx)])))
