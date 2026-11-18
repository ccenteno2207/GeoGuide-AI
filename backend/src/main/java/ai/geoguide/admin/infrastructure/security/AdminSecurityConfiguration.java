package ai.geoguide.admin.infrastructure.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.authorization.AuthorizationManager;
import org.springframework.security.authorization.AuthorityAuthorizationManager;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtDecoders;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

/** Admin API protection is deny-by-default until an OIDC issuer is explicitly configured. */
@Configuration
@EnableMethodSecurity
public class AdminSecurityConfiguration {

    @Bean
    @ConditionalOnProperty(name = "geoguide.admin.security.enabled", havingValue = "true")
    JwtDecoder adminJwtDecoder(@Value("${geoguide.admin.security.issuer-uri}") String issuerUri) {
        if (issuerUri == null || issuerUri.isBlank()) {
            throw new IllegalStateException("An OIDC issuer URI is required when admin security is enabled.");
        }
        return JwtDecoders.fromIssuerLocation(issuerUri);
    }

    @Bean
    SecurityFilterChain apiSecurityFilterChain(HttpSecurity http,
            @Value("${geoguide.admin.security.enabled:false}") boolean enabled,
            @Value("${geoguide.admin.security.roles-claim:roles}") String rolesClaim) throws Exception {
        http.csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorize -> {
                    if (enabled) {
                        authorize.requestMatchers("/api/v1/admin/**")
                                .access(adminAccessPolicy(true));
                    } else {
                        authorize.requestMatchers("/api/v1/admin/**").access(adminAccessPolicy(false));
                    }
                    authorize.anyRequest().permitAll();
                });
        if (enabled) {
            http.oauth2ResourceServer(resourceServer -> resourceServer.jwt(jwt ->
                    jwt.jwtAuthenticationConverter(jwtAuthenticationConverter(rolesClaim))));
        }
        return http.build();
    }

    static Converter<Jwt, ? extends AbstractAuthenticationToken> jwtAuthenticationConverter(String rolesClaim) {
        if (rolesClaim == null || rolesClaim.isBlank()) {
            throw new IllegalArgumentException("A JWT roles claim name is required when admin security is enabled.");
        }
        JwtGrantedAuthoritiesConverter authorities = new JwtGrantedAuthoritiesConverter();
        authorities.setAuthoritiesClaimName(rolesClaim);
        authorities.setAuthorityPrefix("ROLE_");
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(authorities);
        return converter;
    }

    static AuthorizationManager<RequestAuthorizationContext> adminAccessPolicy(boolean enabled) {
        if (!enabled) {
            return (authentication, context) -> new AuthorizationDecision(false);
        }
        return AuthorityAuthorizationManager.hasAnyRole("ADMINISTRATOR", "EDITOR", "REVIEWER");
    }
}
