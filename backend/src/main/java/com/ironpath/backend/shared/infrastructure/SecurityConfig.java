package com.ironpath.backend.shared.infrastructure;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AuthorizeHttpRequestsConfigurer;
import org.springframework.security.config.annotation.web.configurers.CsrfConfigurer;
import org.springframework.security.config.annotation.web.configurers.ExceptionHandlingConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;

@Configuration
@EnableConfigurationProperties(AppProperties.class)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final AppProperties appProperties;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter,
            AppProperties appProperties
    ) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.appProperties = appProperties;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration apiConfiguration = new CorsConfiguration();

        apiConfiguration.setAllowedOriginPatterns(
                appProperties.getCors().getAllowedOriginPatterns()
        );
        apiConfiguration.setAllowedMethods(
                List.of(
                        HttpMethod.GET.name(),
                        HttpMethod.POST.name(),
                        HttpMethod.PUT.name(),
                        HttpMethod.DELETE.name(),
                        HttpMethod.OPTIONS.name()
                )
        );
        apiConfiguration.setAllowedHeaders(
                List.of("Authorization", "Content-Type", "Accept")
        );

        /*
         * Les JWT sont envoyés dans l'en-tête Authorization,
         * et non dans des cookies de session.
         */
        apiConfiguration.setAllowCredentials(false);
        apiConfiguration.setMaxAge(Duration.ofHours(1));

        /*
         * Le formulaire HTML de réinitialisation est public et protégé par
         * un jeton aléatoire, temporaire et à usage unique. Cette configuration
         * évite que Spring rejette son POST lorsque la page est ouverte via
         * un tunnel local ou un reverse proxy utilisant une origine différente.
         */
        CorsConfiguration passwordResetConfiguration = new CorsConfiguration();
        passwordResetConfiguration.setAllowedOriginPatterns(List.of("*"));
        passwordResetConfiguration.setAllowedMethods(
                List.of(
                        HttpMethod.GET.name(),
                        HttpMethod.POST.name(),
                        HttpMethod.OPTIONS.name()
                )
        );
        passwordResetConfiguration.setAllowedHeaders(
                List.of("Content-Type", "Accept", "Origin")
        );
        passwordResetConfiguration.setAllowCredentials(false);
        passwordResetConfiguration.setMaxAge(Duration.ofHours(1));

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration(
                "/api/auth/reset-password-page",
                passwordResetConfiguration
        );
        source.registerCorsConfiguration(
                "/api/auth/reset-password-form",
                passwordResetConfiguration
        );
        source.registerCorsConfiguration("/**", apiConfiguration);

        return source;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(CsrfConfigurer::disable)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .exceptionHandling(this::configureExceptionHandling)
                .authorizeHttpRequests(this::configureAuthorization)
                .addFilterBefore(
                        jwtAuthenticationFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }

    private void configureExceptionHandling(
            ExceptionHandlingConfigurer<HttpSecurity> exceptions
    ) {
        exceptions
                .authenticationEntryPoint((request, response, exception) ->
                        writeJsonError(
                                response,
                                HttpServletResponse.SC_UNAUTHORIZED,
                                "Token absent, invalide ou expiré"
                        )
                )
                .accessDeniedHandler((request, response, exception) ->
                        writeJsonError(
                                response,
                                HttpServletResponse.SC_FORBIDDEN,
                                "Accès interdit"
                        )
                );
    }

    private void configureAuthorization(
            AuthorizeHttpRequestsConfigurer<HttpSecurity>
                    .AuthorizationManagerRequestMatcherRegistry auth
    ) {
        auth.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll();

        auth.requestMatchers(
                HttpMethod.POST,
                "/api/auth/register",
                "/api/auth/login",
                "/api/auth/refresh",
                "/api/auth/forgot-password",
                "/api/auth/reset-password",
                "/api/auth/reset-password-form"
        ).permitAll();

        auth.requestMatchers(
                HttpMethod.GET,
                "/api/auth/verify-email",
                "/api/auth/reset-password-page",
                "/password-reset/**",
                "/actuator/health"
        ).permitAll();

        if (appProperties.getSecurity().isPublicDocs()) {
            auth.requestMatchers(
                    "/swagger-ui/**",
                    "/swagger-ui.html",
                    "/v3/api-docs/**",
                    "/api-docs/**",
                    "/webjars/**"
            ).permitAll();
        }

        auth.anyRequest().authenticated();
    }

    private static void writeJsonError(
            HttpServletResponse response,
            int status,
            String message
    ) throws IOException {
        response.setStatus(status);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("{\"error\":\"" + message + "\"}");
    }
}
