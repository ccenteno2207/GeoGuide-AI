package ai.geoguide.admin.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;
import org.springframework.mock.web.MockHttpServletRequest;
import ai.geoguide.admin.infrastructure.http.AdminCatalogController;
import org.springframework.security.access.prepost.PreAuthorize;

class AdminSecurityConfigurationTests {
    @Test
    void configurableRolesClaimMapsToSpringAuthorities() {
        var jwt = new Jwt("test-only-token", Instant.parse("2026-11-17T12:00:00Z"),
                Instant.parse("2026-11-17T12:05:00Z"), Map.of("alg", "none"),
                Map.of("sub", "editor-1", "roles", List.of("EDITOR")));
        var authentication = AdminSecurityConfiguration.jwtAuthenticationConverter("roles").convert(jwt);

        assertThat(authentication).isNotNull();
        assertThat(authentication.getAuthorities()).extracting("authority").containsExactly("ROLE_EDITOR");
        assertThatThrownBy(() -> AdminSecurityConfiguration.jwtAuthenticationConverter(" "))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void disabledAdminAccessDeniesEvenAuthenticatedEditors() {
        var editor = UsernamePasswordAuthenticationToken.authenticated("editor", "",
                List.of(new SimpleGrantedAuthority("ROLE_EDITOR")));
        var request = new RequestAuthorizationContext(new MockHttpServletRequest("GET", "/api/v1/admin/catalog"));

        assertThat(AdminSecurityConfiguration.adminAccessPolicy(false).check(() -> editor, request).isGranted())
                .isFalse();
        assertThat(AdminSecurityConfiguration.adminAccessPolicy(true).check(() -> editor, request).isGranted())
                .isTrue();
    }

    @Test
    void adminJwtMustCarryTheConfiguredApiAudience() {
        var validator = AdminSecurityConfiguration.audienceValidator("geoguide-admin-api");
        var good = new Jwt("test-token", Instant.parse("2026-11-17T12:00:00Z"),
                Instant.parse("2026-11-17T12:05:00Z"), Map.of("alg", "none"),
                Map.of("sub", "reviewer", "aud", List.of("geoguide-admin-api")));
        var wrong = new Jwt("test-token", Instant.parse("2026-11-17T12:00:00Z"),
                Instant.parse("2026-11-17T12:05:00Z"), Map.of("alg", "none"),
                Map.of("sub", "reviewer", "aud", List.of("other-api")));
        var missing = new Jwt("test-token", Instant.parse("2026-11-17T12:00:00Z"),
                Instant.parse("2026-11-17T12:05:00Z"), Map.of("alg", "none"),
                Map.of("sub", "reviewer"));
        assertThat(validator.validate(good)).isEqualTo(OAuth2TokenValidatorResult.success());
        assertThat(validator.validate(wrong).hasErrors()).isTrue();
        assertThat(validator.validate(missing).hasErrors()).isTrue();
    }

    @Test
    void enablingAdminSecurityWithoutAnIssuerOrAudienceFailsClosedBeforeNetworkAccess() {
        assertThatThrownBy(() -> new AdminSecurityConfiguration().adminJwtDecoder(" ", " ", ""))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("issuer URI and API audience are required");
    }

    @Test
    void internalJwkEndpointCanValidateTokensAgainstThePublicIssuer() {
        var decoder = new AdminSecurityConfiguration().adminJwtDecoder(
                "https://identity.example/auth/realms/geoguide-admin", "geoguide-admin-api",
                "http://keycloak:8080/auth/realms/geoguide-admin/protocol/openid-connect/certs");
        assertThat(decoder).isInstanceOf(org.springframework.security.oauth2.jwt.NimbusJwtDecoder.class);
    }

    @Test
    void activationEndpointsRequireAdministratorRoleAtMethodBoundary() throws Exception {
        var editorial = AdminCatalogController.class.getMethod("activation", java.util.UUID.class,
                AdminCatalogController.ActivationRequest.class, org.springframework.security.core.Authentication.class)
                .getAnnotation(PreAuthorize.class);
        var existing = AdminCatalogController.class.getMethod("setPoiActivation", java.util.UUID.class,
                AdminCatalogController.ExistingPoiActivationRequest.class, org.springframework.security.core.Authentication.class)
                .getAnnotation(PreAuthorize.class);
        assertThat(editorial.value()).isEqualTo("hasRole('ADMINISTRATOR')");
        assertThat(existing.value()).isEqualTo("hasRole('ADMINISTRATOR')");
    }
}
