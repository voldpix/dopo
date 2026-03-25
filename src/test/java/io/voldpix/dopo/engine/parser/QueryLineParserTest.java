package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.QueryParam;
import io.voldpix.dopo.common.model.RequestBlock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class QueryLineParserTest {

    final QueryLineParser parser = new QueryLineParser();
    RequestBlock.Builder builder;

    @BeforeEach
    void setUp() {
        builder = RequestBlock.builder();
    }

    @Test
    void recognizeQueryLines() {
        assertThat(parser.canParse("-q page=1")).isTrue();
        assertThat(parser.canParse("-q filter=active")).isTrue();
        assertThat(parser.canParse("GET https://api.example.com")).isFalse();
        assertThat(parser.canParse("-h Content-Type=json")).isFalse();
    }

    @Test
    void parseKeyValueParam() {
        var error = parser.parse("-q page=1", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().queryParams())
                .containsExactly(new QueryParam("page", "1"));
    }

    @Test
    void parseParamWithNoValue() {
        var error = parser.parse("-q debug", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().queryParams())
                .containsExactly(new QueryParam("debug", ""));
    }

    @Test
    void parseMultipleParams() {
        parser.parse("-q page=1", builder);
        parser.parse("-q limit=10", builder);
        parser.parse("-q filter=active", builder);

        assertThat(builder.build().queryParams()).containsExactly(
                new QueryParam("page", "1"),
                new QueryParam("limit", "10"),
                new QueryParam("filter", "active")
        );
    }

    @Test
    void parseTemplateVariableAsValue() {
        var error = parser.parse("-q userId={{userId}}", builder);

        assertThat(error).isEmpty();
        assertThat(builder.build().queryParams())
                .containsExactly(new QueryParam("userId", "{{userId}}"));
    }

    @Test
    void returnErrorForMissingKey() {
        var error = parser.parse("-q", builder);

        assertThat(error).isPresent();
        assertThat(error.get().hint()).contains("expected: -q <key>=<value>");
    }
}