package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.exception.ParseException;
import io.voldpix.dopo.common.model.RawRequest;
import io.voldpix.dopo.common.utils.DslSymbols;

import java.util.List;

public class RequestExtractor {

    public RawRequest extract(String rawContent) {
        var lines = rawContent.lines()
                .map(String::trim)
                .filter(line -> !line.isEmpty())
                .filter(line -> !line.startsWith(DslSymbols.COMMENT_PREFIX))
                .map(this::collapseSpaces)
                .toList();

        int openIdx = indexOf(lines, DslSymbols.BODY_OPEN);
        int closeIdx = indexOf(lines, DslSymbols.BODY_CLOSE);

        validateDelimiters(lines, openIdx, closeIdx);

        if (openIdx == -1) {
            return new RawRequest(lines, null);
        }

        var directiveLines = new java.util.ArrayList<>(lines.subList(0, openIdx));
        directiveLines.addAll(lines.subList(closeIdx + 1, lines.size()));

        var bodyLines = lines.subList(openIdx + 1, closeIdx);
        var body = String.join("\n", bodyLines);

        return new RawRequest(
                List.copyOf(directiveLines),
                body.isBlank() ? null : body
        );
    }

    private int indexOf(List<String> lines, String marker) {
        for (int i = 0; i < lines.size(); i++) {
            if (lines.get(i).equals(marker)) return i;
        }
        return -1;
    }

    private String collapseSpaces(String line) {
        return line.replaceAll("\\s+", " ");
    }

    private void validateDelimiters(List<String> lines, int openIdx, int closeIdx) {
        long openCount = lines.stream().filter(l -> l.equals(DslSymbols.BODY_OPEN)).count();
        long closeCount = lines.stream().filter(l -> l.equals(DslSymbols.BODY_CLOSE)).count();

        if (openCount > 1)
            throw new ParseException("<| appears " + openCount + " times — only one body block is allowed");
        if (closeCount > 1)
            throw new ParseException("|> appears " + closeCount + " times — only one body block is allowed");
        if (openIdx != -1 && closeIdx == -1)
            throw new ParseException("<| opened but never closed with |>");
        if (closeIdx != -1 && openIdx == -1)
            throw new ParseException("|> found with no opening <|");
        if (openIdx != -1 && closeIdx < openIdx)
            throw new ParseException("|> appears before <|");
        if (openIdx != -1 && closeIdx == openIdx + 1)
            throw new ParseException("body block is empty - remove <| |> or add content");
    }
}
