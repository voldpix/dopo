package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.Header;
import io.voldpix.dopo.common.model.RequestBlock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class HeaderLineParserTest {

    final HeaderLineParser parser = new HeaderLineParser();
    RequestBlock.Builder builder;

    @BeforeEach
    void setUp() {
        builder = RequestBlock.builder();
    }

    @Test
    void recognizeHeaderLines() {
        assertThat(parser.canParse("-h Content-Type=application/json")).isTrue();
        assertThat(parser.canParse("-h Authorization=Bearer token")).isTrue();
        assertThat(parser.canParse("-h Accept=*/*")).isTrue();
        assertThat(parser.canParse("GET https://api.example.com")).isFalse();
        assertThat(parser.canParse("-q page=1")).isFalse();
    }

    @Test
    void parseSimpleHeader() {
        var error = parser.parse("-h Content-Type=application/json", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().headers())
                .containsExactly(new Header("Content-Type", "application/json"));
    }

    @Test
    void parseBearerTokenHeader() {
        var error = parser.parse("-h Authorization=Bearer {{token}}", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().headers())
                .containsExactly(new Header("Authorization", "Bearer {{token}}"));
    }

    @Test
    void parseMultipleHeaders() {
        parser.parse("-h Content-Type=application/json", builder);
        parser.parse("-h Accept=application/json", builder);
        parser.parse("-h Authorization=Bearer {{token}}", builder);

        assertThat(builder.build().headers()).containsExactly(
                new Header("Content-Type", "application/json"),
                new Header("Accept", "application/json"),
                new Header("Authorization", "Bearer {{token}}")
        );
    }

    @Test
    void errorForMissingEquals() {
        var error = parser.parse("-h ContentType", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).contains("expected: -h <key>=<value>");
    }

    @Test
    void errorForMissingKey() {
        var error = parser.parse("-h =application/json", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).contains("key is missing");
    }

    @Test
    void errorForEmptyLine() {
        var error = parser.parse("-h", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).contains("expected: -h <key>=<value>");
    }

    @Test
    void parseHeaderWithTemplateVariable() {
        var error = parser.parse("-h X-Api-Key={{apiKey}}", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().headers())
                .containsExactly(new Header("X-Api-Key", "{{apiKey}}"));
    }
}