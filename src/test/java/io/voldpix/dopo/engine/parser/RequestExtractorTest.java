package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.exception.ParseException;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RequestExtractorTest {

    final RequestExtractor extractor = new RequestExtractor();

    @Test
    void noBodyReturnsAllLinesAsDirectives() {
        var raw = extractor.extract("""
                GET https://api.example.com/users
                -h Authorization=Bearer token
                -q page=1
                """);

        assertThat(raw.hasBody()).isFalse();
        assertThat(raw.directiveLines()).containsExactly(
                "GET https://api.example.com/users",
                "-h Authorization=Bearer token",
                "-q page=1"
        );
    }

    @Test
    void extractsBodyBlock() {
        var raw = extractor.extract("""
                POST https://api.example.com/users
                -h Content-Type=application/json
                <|
                { "name": "alice" }
                |>
                """);

        assertThat(raw.hasBody()).isTrue();
        assertThat(raw.body()).isEqualTo("{ \"name\": \"alice\" }");
        assertThat(raw.directiveLines()).containsExactly(
                "POST https://api.example.com/users",
                "-h Content-Type=application/json"
        );
    }

    @Test
    void extractsMultilineBody() {
        var raw = extractor.extract("""
                POST https://api.example.com/users
                <|
                {
                  "name": "alice",
                  "role": "admin"
                }
                |>
                """);

        assertThat(raw.body()).isEqualTo("""
                {
                "name": "alice",
                "role": "admin"
                }""");
    }

    @Test
    void directivesAfterBodyAreIncluded() {
        var raw = extractor.extract("""
                POST https://api.example.com/users
                -h      Content-Type=application/json
                <|
                { "name": "alice" }
                |>
                -a status=201
                """);

        assertThat(raw.directiveLines()).containsExactly(
                "POST https://api.example.com/users",
                "-h Content-Type=application/json",
                "-a status=201"
        );
        assertThat(raw.body()).isEqualTo("{ \"name\": \"alice\" }");
    }

    @Test
    void stripsCommentsAndBlankLines() {
        var raw = extractor.extract("""
                # create a user
                POST https://api.example.com/users
                
                -h Content-Type=application/json
                <|
                { "name": "alice" }
                |>
                """);

        assertThat(raw.directiveLines()).containsExactly(
                "POST https://api.example.com/users",
                "-h Content-Type=application/json"
        );
        assertThat(raw.body()).containsAnyOf("name", "alice", "{", "}");
    }

    @Test
    void throwsWhenOpenWithoutClose() {
        assertThatThrownBy(() -> extractor.extract("""
                POST https://api.example.com/users
                <|
                { "name": "alice" }
                """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("never closed");
    }

    @Test
    void throwsWhenCloseWithoutOpen() {
        assertThatThrownBy(() -> extractor.extract("""
                POST https://api.example.com/users
                { "name": "alice" }
                |>
                """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("no opening");
    }

    @Test
    void throwsWhenCloseBeforeOpen() {
        assertThatThrownBy(() -> extractor.extract("""
                POST https://api.example.com/users
                |>
                { "name": "alice" }
                <|
                """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("|> appears before <|");
    }

    @Test
    void throwsWhenMultipleOpenDelimiters() {
        assertThatThrownBy(() -> extractor.extract("""
                POST https://api.example.com/users
                <|
                { "name": "alice" }
                <|
                |>
                """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("appears 2 times");
    }

    @Test
    void throwsWhenBodyIsEmpty() {
        assertThatThrownBy(() -> extractor.extract("""
                POST https://api.example.com/users
                <|
                |>
                """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("empty");
    }

    @Test
    void throwsWhenDelimiterHasInlineText() {
        assertThatThrownBy(() -> extractor.extract("""
            POST https://api.example.com/users
            <| json
            { "name": "alice" }
            |>
            """))
                .isInstanceOf(ParseException.class)
                .hasMessageContaining("no opening");
    }
}