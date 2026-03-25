package io.voldpix.dopo;

import io.voldpix.dopo.common.utils.ConsoleWriter;
import io.voldpix.dopo.engine.parser.ContentProcessor;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class Main {

    public static final String APP_NAME = "dopo";
    public static final String VERSION = "0.1-dev";

    static void main(String[] args) {
        if (args.length == 0) {
            printUsage();
            System.exit(1);
        }

        switch (args[0]) {
            case "--help", "-h" -> {
                printUsage();
                System.exit(0);
            }
            case "--version", "-v" -> {
                printVersion();
                System.exit(0);
            }
            default -> runFile(args[0]);
        }
    }

    // sample of run file logic
    private static void runFile(String filePath) {
        var path = resolvePath(filePath);

        if (!Files.exists(path)) {
            ConsoleWriter.error("file not found: " + filePath);
            System.exit(1);
        }
        if (!Files.isReadable(path)) {
            ConsoleWriter.error("cannot read file: " + filePath);
            System.exit(1);
        }

        String content;
        try {
            content = Files.readString(path);
        } catch (IOException e) {
            ConsoleWriter.error("failed to read file: " + e.getMessage());
            System.exit(1);
            return;
        }

        ConsoleWriter.section(path.getFileName().toString());

        var processor = new ContentProcessor();
        var result = processor.parse(content);

        if (result.hasErrors()) {
            result.errors().forEach(err ->
                    ConsoleWriter.parseError(err.line(), err.hint())
            );
            System.exit(1);
        }

        var request = result.request();
        ConsoleWriter.request(request.method().name(), request.url());

        if (!request.headers().isEmpty()) {
            ConsoleWriter.info("  headers:");
            request.headers().forEach(h -> ConsoleWriter.header(h.key(), h.value()));
        }

        if (!request.queryParams().isEmpty()) {
            ConsoleWriter.info("  query params:");
            request.queryParams().forEach(q ->
                    ConsoleWriter.header(q.name(), q.value().isEmpty() ? "(no value)" : q.value())
            );
        }

        ConsoleWriter.warn("HTTP execution not yet implemented — parsed OK");
    }

    private static void printUsage() {
        ConsoleWriter.section("dopo " + VERSION);
        System.out.println();
        ConsoleWriter.info("  Usage:   dopo <file.dopo>");
        ConsoleWriter.info("           dopo --help");
        ConsoleWriter.info("           dopo --version");
        System.out.println();
        ConsoleWriter.info("  Request file syntax:");
        ConsoleWriter.info("    GET https://api.example.com/users");
        ConsoleWriter.info("    -h Authorization=Bearer {{token}}");
        ConsoleWriter.info("    -q page=1");
        System.out.println();
        ConsoleWriter.info("  Options:");
        ConsoleWriter.info("    -h, --help       show this message");
        ConsoleWriter.info("    -v, --version    show version");
        System.out.println();
    }

    private static void printVersion() {
        ConsoleWriter.info(APP_NAME + " " + VERSION);
    }

    private static Path resolvePath(String filePath) {
        var given = Path.of(filePath);

        if (given.isAbsolute() || filePath.startsWith("./") || filePath.startsWith("../")) {
            return given;
        }

        try {
            var jarLocation = Main.class
                    .getProtectionDomain()
                    .getCodeSource()
                    .getLocation()
                    .toURI();
            return Path.of(jarLocation).getParent().resolve(filePath);
        } catch (Exception e) {
            // fallback to cwd
            return given;
        }
    }
}
