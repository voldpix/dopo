package io.voldpix.dopo;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class MainTest {

    @Test
    void match() {
        assertThat(Main.APP_NAME).isEqualTo("dopo");
    }
}