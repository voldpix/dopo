package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.HttpMethod;
import io.voldpix.dopo.common.model.RequestBlock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RequestLineParserTest {

    final RequestLineParser parser = new RequestLineParser();
    RequestBlock.Builder builder;

    @BeforeEach
    void setUp() {
        builder = RequestBlock.builder();
    }

    @Test
    void parseSimpleGetRequest() {
        var error = parser.parse("GET https://api.example.com/users", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().method()).isEqualTo(HttpMethod.GET);
        assertThat(builder.build().url()).isEqualTo("https://api.example.com/users");
    }

    @Test
    void caseInsensitive() {
        var error = parser.parse("get https://api.example.com", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().method()).isEqualTo(HttpMethod.GET);
    }

    @Test
    void errorForUnknownMethod() {
        var error = parser.parse("FETCH https://api.example.com", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).contains("expected: http method");
    }

    @Test
    void errorForMissingUrl() {
        var error = parser.parse("GET", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).containsAnyOf("expected:", "URL");
    }
}