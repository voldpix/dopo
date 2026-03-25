package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.HttpMethod;
import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;

import java.util.Optional;

public class RequestLineParser implements ContentParser {

    @Override
    public boolean canParse(String content) {
        var method = content.split(" ")[0].trim().toUpperCase();
        return HttpMethod.isValid(method);
    }

    @Override
    public Optional<ParseError> parse(String line, RequestBlock.Builder builder) {
        var parts = line.split(" ", 2);
        if (parts.length < 2)
            return Optional.of(new ParseError(line, "expected: http method and URL e.g. GET https://api.example.com"));

        var method = parts[0].trim().toUpperCase();
        if (!HttpMethod.isValid(method))
            return Optional.of(new ParseError(line, "expected: http method e.g. GET"));

        var url = parts[1].trim();
        if (url.isEmpty())
            return Optional.of(new ParseError(line, "expected: URL e.g. https://api.example.com"));

        // todo: validate url format valid

        // todo: check inline query params

        builder.method(HttpMethod.valueOf(method))
                .url(url);

        return Optional.empty();
    }
}
