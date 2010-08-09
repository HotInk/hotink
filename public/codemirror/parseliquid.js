var LiquidParser = Editor.Parser = (function() {
  function tokenizeLiquid(source) {
    while (!source.endOfLine()) source.next();
    return "text";
  }
  function parseLiquid(source) {
    function indentTo(n) {return function() {return n;}}
    source = tokenizer(source, tokenizeLiquid);
    var space = 0;

    var iter = {
      next: function() {
        var tok = source.next();
        if (tok.type == "whitespace") {
          if (tok.value == "\n") tok.indentation = indentTo(space);
          else space = tok.value.length;
        }
        return tok;
      },
      copy: function() {
        var _space = space;
        return function(_source) {
          space = _space;
          source = tokenizer(_source, tokenizeLiquid);
          return iter;
        };
      }
    };
    return iter;
  }
  return {make: parseLiquid};
})();
