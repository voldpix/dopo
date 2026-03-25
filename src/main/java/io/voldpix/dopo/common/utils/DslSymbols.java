package io.voldpix.dopo.common.utils;

public final class DslSymbols {

    private DslSymbols() {
    }

    public static final String COMMENT_PREFIX = "#";

    public static final String HEADER_SHORT = "-h";
    public static final String HEADER_LONG = "header";

    public static final String QUERY_SHORT = "-q";
    public static final String QUERY_LONG = "query";


    public static boolean matches(String line, String shortForm, String longForm) {
        return line.startsWith(shortForm) || line.startsWith(longForm);
    }

    public static String stripPrefix(String line, String shortForm, String longForm) {
        if (line.startsWith(shortForm)) return line.substring(shortForm.length()).trim();
        if (line.startsWith(longForm)) return line.substring(longForm.length()).trim();
        throw new IllegalArgumentException("line does not match either prefix: " + line);
    }
}
