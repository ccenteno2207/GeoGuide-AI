package ai.geoguide.admin.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;
import org.springframework.mock.web.MockHttpServletRequest;

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
}
