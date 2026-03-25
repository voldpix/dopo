package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;

import java.util.Objects;
import java.util.Optional;

public class BodyParser {

    public Optional<ParseError> parse(String body, RequestBlock.Builder builder) {
        if (Objects.isNull(body) || body.isBlank()) {
            return Optional.empty();
        }
        builder.body(body);
        return Optional.empty();
    }
}