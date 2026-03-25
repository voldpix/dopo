package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.Header;
import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;
import io.voldpix.dopo.common.utils.DslSymbols;

import java.util.Optional;

public class HeaderLineParser implements ContentParser {

    @Override
    public boolean canParse(String content) {
        return content.startsWith(DslSymbols.HEADER_PREFIX);
    }

    @Override
    public Optional<ParseError> parse(String line, RequestBlock.Builder builder) {
        var headerLine = line.substring(DslSymbols.HEADER_PREFIX.length()).trim();
        if (headerLine.isEmpty()) {
            return Optional.of(new ParseError(line,
                    "expected: -h <key>=<value>  e.g. -h Content-Type=application/json"));
        }

        var index = headerLine.indexOf('=');
        if (index == -1) {
            return Optional.of(new ParseError(line,
                    "expected: -h <key>=<value>  e.g. -h Content-Type=application/json"));
        }

        var key = headerLine.substring(0, index).trim();
        var value = headerLine.substring(index + 1).trim();

        if (key.isEmpty()) {
            return Optional.of(new ParseError(line,
                    "key is missing. expected: -h <key>=<value>  e.g. -h Content-Type=application/json"));
        }

        builder.header(new Header(key, value));
        return Optional.empty();
    }
}
