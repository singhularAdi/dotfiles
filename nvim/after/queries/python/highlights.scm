;; extends

; Additional treesitter highlight for python
; see $VIMPLUG/nvim-treesitter/queries/python/highlights.scm



; Use a highlight group for test function/method definitions
((class_definition
  body: (block
          (function_definition
            name: (identifier) @function.method.test)))
 (#lua-match? @function.method.test "^test_"))

((function_definition
  name: (identifier) @function.test)
 (#lua-match? @function.test "^test_"))


; Highlight multi-line strings that start with a shebang
; see python/injections.scm
(((string_content) @string.injection)
 (#match? @string.injection "^#!/bin/bash\n"))
(((string_content) @string.injection)
 (#lua-match? @string.injection "^[%s]*#!/usr/bin/env python[%d.]*\n"))


; docstring for class fields or top-level defs, right below/adjacent to the field definition
((expression_statement (assignment)) ; field: type = value
  . (comment)*
  . (expression_statement
      (string
        (string_start) @_string_start
        )) @string.documentation
  (#match? @_string_start "\"\"\"|'''$"))
