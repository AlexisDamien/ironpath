package com.ironpath.backend.shared.infrastructure;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private URI publicBaseUrl;
    private Mail mail = new Mail();
    private Cors cors = new Cors();
    private Security security = new Security();

    @Getter
    @Setter
    public static class Mail {

        private String from;
    }

    @Getter
    @Setter
    public static class Cors {

        private List<String> allowedOriginPatterns =
                new ArrayList<>();
    }

    @Getter
    @Setter
    public static class Security {

        private boolean publicDocs;
    }
}