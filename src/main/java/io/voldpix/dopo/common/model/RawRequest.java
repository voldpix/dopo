package io.voldpix.dopo.common.model;

import java.util.List;
import java.util.Objects;

public record RawRequest(List<String> directiveLines, String body) {

    public boolean hasBody() {
        return Objects.nonNull(body);
    }
}