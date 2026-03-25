package io.voldpix.dopo.engine.parser;

import io.voldpix.dopo.common.model.RequestBlock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BodyBlockParserTest {

    final BodyBlockParser parser = new BodyBlockParser();
    RequestBlock.Builder builder;

    @BeforeEach
    void setUp() {
        builder = RequestBlock.builder();
    }

    @Test
    void parse() {
        var body = "username=voldpix";
        parser.parse(body, builder);
        assertThat(builder.build().body())
                .contains("username=voldpix");
    }

    @Test
    void parseEmptyBody() {
        var body = "";
        var result = parser.parse(body, builder);
        assertThat(builder.build().body()).isNull();
        assertThat(result).isEmpty();
    }
}