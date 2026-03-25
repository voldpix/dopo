package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.exception.ParseException;
import io.voldpix.dopo.common.model.ParseResult;
import io.voldpix.dopo.common.model.RawRequest;
import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;

import java.util.LinkedList;
import java.util.List;

public class ContentProcessor {

    final RequestExtractor requestExtractor = new RequestExtractor();
    final RequestLineParser requestLineParser = new RequestLineParser();
    final BodyBlockParser bodyBlockParser = new BodyBlockParser();

    final List<ContentParser> parsers = List.of(
            new HeaderLineParser(),
            new QueryLineParser()
    );

    public ParseResult parse(String rawContent) {
        var errors = new LinkedList<ParseError>();
        var builder = RequestBlock.builder();

        RawRequest raw;
        try {
            raw = requestExtractor.extract(rawContent);
        } catch (ParseException e) {
            errors.add(new ParseError("<|...|>", e.getMessage()));
            return new ParseResult(null, List.copyOf(errors));
        }

        if (raw.directiveLines().isEmpty()) {
            errors.add(new ParseError("empty file", "file must contain a request"));
            return new ParseResult(null, List.copyOf(errors));
        }

        var firstLine = raw.directiveLines().getFirst();
        if (!requestLineParser.canParse(firstLine)) {
            errors.add(new ParseError(firstLine,
                    "file must start with a request line e.g. GET https://api.example.com"));
            return new ParseResult(null, List.copyOf(errors));
        }
        requestLineParser.parse(firstLine, builder).ifPresent(errors::add);

        for (var line : raw.directiveLines().subList(1, raw.directiveLines().size())) {
            parsers.stream()
                    .filter(p -> p.canParse(line))
                    .findFirst()
                    .ifPresentOrElse(
                            p -> p.parse(line, builder).ifPresent(errors::add),
                            () -> errors.add(new ParseError(line,
                                    "unrecognized directive: \"" + line + "\""))
                    );
        }

        bodyBlockParser.parse(raw.body(), builder).ifPresent(errors::add);

        return new ParseResult(
                errors.isEmpty() ? builder.build() : null,
                List.copyOf(errors)
        );
    }
}
