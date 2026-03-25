package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;

import java.util.Optional;

public interface ContentParser {

    default boolean canParse(String line) {
        return false;
    }

    Optional<ParseError> parse(String line, RequestBlock.Builder builder);
}
