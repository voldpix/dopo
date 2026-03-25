package io.voldpix.dopo.common.utils;

import static java.util.Objects.isNull;
import static java.util.Objects.nonNull;

public final class ConsoleWriter {

    private static final boolean COLOR_ENABLED = detectColorSupport();

    public static boolean isColorSupported() {
        return COLOR_ENABLED;
    }

    private static boolean detectColorSupport() {
        if (nonNull(System.getenv("NO_COLOR"))) return false;
        if (nonNull(System.getenv("FORCE_COLOR"))) return true;
        if (isNull(System.console())) return false;
        var os = System.getProperty("os.name", "").toLowerCase();
        if (os.contains("win")) {
            return nonNull(System.getenv("WT_SESSION"))
                    || nonNull(System.getenv("TERM"));
        }

        return true;
    }

    private static final String RESET = "\u001B[0m";
    private static final String BOLD = "\u001B[1m";
    private static final String DIM = "\u001B[2m";

    private static final String RED = "\u001B[31m";
    private static final String GREEN = "\u001B[32m";
    private static final String YELLOW = "\u001B[33m";
    private static final String BLUE = "\u001B[34m";
    private static final String MAGENTA = "\u001B[35m";
    private static final String CYAN = "\u001B[36m";
    private static final String WHITE = "\u001B[37m";
    private static final String GRAY = "\u001B[90m";

    private static final String CHECK = "✓";
    private static final String CROSS = "✗";
    private static final String ARROW = "→";
    private static final String BULLET = "•";
    private static final String HINT = "↳";

    private ConsoleWriter() {
    }

    public static void request(String method, String url) {
        var m = method.toUpperCase();
        if (COLOR_ENABLED) {
            System.out.println(
                    GRAY + ARROW + RESET +
                            BOLD + methodColor(m) + " " + m + RESET + " " +
                            WHITE + url + RESET
            );
        } else {
            System.out.println(ARROW + " " + m + " " + url);
        }
    }

    public static void response(int statusCode, String statusText, long millis) {
        if (COLOR_ENABLED) {
            System.out.println(
                    statusColor(statusCode) + BOLD + statusCode + " " + statusText + RESET +
                            GRAY + "  " + millis + "ms" + RESET
            );
        } else {
            System.out.println(statusCode + " " + statusText + "  " + millis + "ms");
        }
    }

    public static void header(String key, String value) {
        if (COLOR_ENABLED) {
            System.out.println(
                    GRAY + "  " + BULLET + " " + RESET +
                            CYAN + key + RESET +
                            GRAY + ": " + RESET +
                            DIM + value + RESET
            );
        } else {
            System.out.println("  " + BULLET + " " + key + ": " + value);
        }
    }

    public static void error(String message) {
        if (COLOR_ENABLED) {
            System.err.println(BOLD + RED + CROSS + " " + message + RESET);
        } else {
            System.err.println(CROSS + " " + message);
        }
    }

    public static void hint(String message) {
        if (COLOR_ENABLED) {
            System.err.println(GRAY + "  " + HINT + " hint: " + message + RESET);
        } else {
            System.err.println("  " + HINT + " hint: " + message);
        }
    }

    public static void parseError(String line, String hintText) {
        error("parse error near: \"" + line + "\"");
        hint(hintText);
    }

    public static void success(String message) {
        if (COLOR_ENABLED) {
            System.out.println(BOLD + GREEN + CHECK + " " + message + RESET);
        } else {
            System.out.println(CHECK + " " + message);
        }
    }

    public static void warn(String message) {
        if (COLOR_ENABLED) {
            System.out.println(YELLOW + "⚠ " + message + RESET);
        } else {
            System.out.println("! " + message);
        }
    }

    public static void info(String message) {
        if (COLOR_ENABLED) {
            System.out.println(GRAY + message + RESET);
        } else {
            System.out.println(message);
        }
    }

    public static void section(String label) {
        if (COLOR_ENABLED) {
            System.out.println(
                    "\n" + BOLD + BLUE + "── " + label + " " + RESET +
                            BLUE + "─".repeat(Math.max(0, 50 - label.length())) + RESET
            );
        } else {
            System.out.println("\n── " + label + " " + "─".repeat(Math.max(0, 50 - label.length())));
        }
    }

    private static String methodColor(String method) {
        return switch (method) {
            case "GET" -> CYAN;
            case "POST" -> GREEN;
            case "PUT" -> YELLOW;
            case "PATCH" -> MAGENTA;
            case "DELETE" -> RED;
            default -> WHITE;
        };
    }

    private static String statusColor(int code) {
        if (code >= 500) return RED;
        if (code >= 400) return YELLOW;
        if (code >= 300) return CYAN;
        if (code >= 200) return GREEN;
        return WHITE;
    }

    private static String padRight(String s, int width) {
        return String.format("%-" + width + "s", s);
    }
}
