package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.QueryParam;
import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;
import io.voldpix.dopo.common.utils.DslSymbols;

import java.util.Optional;

public class QueryLineParser implements ContentParser {

    @Override
    public boolean canParse(String line) {
        return DslSymbols.matches(line, DslSymbols.QUERY_SHORT, DslSymbols.QUERY_LONG);
    }

    @Override
    public Optional<ParseError> parse(String line, RequestBlock.Builder builder) {
        var queryString = DslSymbols.stripPrefix(line, DslSymbols.QUERY_SHORT, DslSymbols.QUERY_LONG);

        if (queryString.isEmpty()) {
            return Optional.of(new ParseError(line,
                    "expected: -q <key>=<value> e.g -q page=1"));
        }

        var index = queryString.indexOf("=");
        if (index == -1) {
            builder.queryParam(new QueryParam(queryString.trim(), ""));
            return Optional.empty();
        }

        var key = queryString.substring(0, index).trim();
        var value = queryString.substring(index + 1).trim();

        if (key.isEmpty()) {
            return Optional.of(new ParseError(line,
                    "key is missing. expected: -q <key>=<value>  e.g. -q page=1"));

        }

        builder.queryParam(new QueryParam(key, value));
        return Optional.empty();
    }
}
