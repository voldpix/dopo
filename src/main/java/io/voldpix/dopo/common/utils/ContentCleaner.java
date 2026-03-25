package io.voldpix.dopo.common.utils;

import java.util.List;

public class ContentCleaner {

    public List<String> clean(String content) {
        return content
                .lines()
                .map(String::trim)
                .filter(line -> !line.isEmpty())
                .filter(line -> !line.startsWith(DslSymbols.COMMENT_PREFIX))
                .map(this::collapseSpaces)
                .toList();
    }

    private String collapseSpaces(String line) {
        return line.replaceAll("\\s+", " ");
    }
}
