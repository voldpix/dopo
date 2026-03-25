package io.voldpix.dopo.common.model;

import java.util.Arrays;

public enum HttpMethod {

    GET,
    POST,
    PUT,
    PATCH,
    DELETE,
//    HEAD,
//    OPTIONS,
//    TRACE,
    ;

    public static boolean isValid(String method) {
        return Arrays.stream(values())
                .anyMatch(v -> v.name().equalsIgnoreCase(method));
    }
}
