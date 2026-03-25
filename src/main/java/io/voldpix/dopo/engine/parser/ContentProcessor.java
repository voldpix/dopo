package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.ParseResult;
import io.voldpix.dopo.common.model.RequestBlock;
import io.voldpix.dopo.common.model.parser.ParseError;
import io.voldpix.dopo.common.utils.ContentCleaner;

import java.util.LinkedList;
import java.util.List;

public class ContentProcessor {

    final ContentCleaner contentCleaner = new ContentCleaner();
    final RequestLineParser requestLineParser = new RequestLineParser();

    private final List<ContentParser> parsers = List.of(
            new HeaderLineParser(),
            new QueryLineParser()
    );

    public ParseResult parse(String rawContent) {
        var lines = contentCleaner.clean(rawContent);
        var errors = new LinkedList<ParseError>();
        var builder = RequestBlock.builder();

        if (lines.isEmpty()) {
            errors.add(new ParseError("empty file", "file must contain a request"));
            return new ParseResult(null, List.copyOf(errors));
        }

        var firstLine = lines.getFirst();
        if (!requestLineParser.canParse(firstLine)) {
            errors.add(new ParseError(firstLine,
                    "file must start with a request line e.g. GET https://api.example.com"));
            return new ParseResult(null, List.copyOf(errors));
        }

        requestLineParser.parse(firstLine, builder);

        for (var line : lines.subList(1, lines.size())) {
            parsers.stream()
                    .filter(p -> p.canParse(line))
                    .findFirst()
                    .ifPresentOrElse(
                            p -> p.parse(line, builder).ifPresent(errors::add),
                            () -> errors.add(new ParseError(line, "unrecognized line: \"" + line + "\""))
                    );
        }
        return new ParseResult(builder.build(), List.copyOf(errors));
    }
}
