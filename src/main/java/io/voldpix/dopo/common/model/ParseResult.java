package io.voldpix.dopo.common.model;

import io.voldpix.dopo.common.model.parser.ParseError;
import io.voldpix.dopo.common.utils.ConsoleWriter;

import java.util.List;

import static java.util.Objects.nonNull;

public record ParseResult(
        RequestBlock request,
        List<ParseError> errors
) {

    public boolean hasErrors() {
        return nonNull(errors) && !errors.isEmpty();
    }

    public boolean isSuccess() {
        return nonNull(errors) && errors.isEmpty();
    }

    public void printErrors(String fileName) {
        ConsoleWriter.error("Failed to parse: " + fileName + "\n");
        errors.forEach(error -> ConsoleWriter.parseError(error.line(), error.hint()));
    }
}
