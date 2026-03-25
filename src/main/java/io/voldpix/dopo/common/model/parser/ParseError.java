package io.voldpix.dopo.common.model.parser;

public record ParseError(String line, String hint) {

    @Override
    public String toString() {
        return """
                error: "%s"
                hint: %s""".formatted(line, hint);
    }
}
