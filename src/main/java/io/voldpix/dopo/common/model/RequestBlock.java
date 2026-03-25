package io.voldpix.dopo.common.model;

import java.util.ArrayList;
import java.util.List;

public record RequestBlock(
        HttpMethod method,
        String url,
        List<Header> headers,
        List<QueryParam> queryParams
) {

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private HttpMethod method;
        private String url;
        private List<Header> headers = new ArrayList<>();
        private List<QueryParam> queryParams = new ArrayList<>();

        public Builder method(HttpMethod method) {
            this.method = method;
            return this;
        }

        public Builder url(String url) {
            this.url = url;
            return this;
        }

        public Builder header(Header header) {
            this.headers.add(header);
            return this;
        }

        public Builder queryParam(QueryParam queryParam) {
            this.queryParams.add(queryParam);
            return this;
        }

        public Builder queryParams(List<QueryParam> queryParams) {
            this.queryParams.addAll(queryParams);
            return this;
        }

        public RequestBlock build() {
            return new RequestBlock(
                    method,
                    url,
                    headers,
                    queryParams
            );
        }
    }
}
