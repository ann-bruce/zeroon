package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.blankOrNullString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(properties = {
    "zeroon.auth.admin-emails=zeroon_ai@outlook.com",
    "zeroon.auth.email-verification-code-request-cooldown-seconds=0",
    "zeroon.auth.email-verification-code-hourly-limit=10000",
    "zeroon.auth.email-verification-code-ip-hourly-limit=10000",
    "zeroon.auth.email-verification-code-device-login-limit=10000",
    "zeroon.auth.email-verification-code-ip-login-limit=10000"
})
@AutoConfigureMockMvc
class AdminAuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditEventRepository auditEventRepository;

    @Test
    void allowlistedEmailCanLoginWithoutCreatingAnAppUserSession() throws Exception {
        requestAdminCode("ZEROON_AI@OUTLOOK.COM");

        String body = mockMvc.perform(post("/api/v1/admin/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "zeroon_ai@outlook.com",
                                  "code": "000000",
                                  "deviceId": "admin-browser-session"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken", not(blankOrNullString())))
                .andExpect(jsonPath("$.expiresIn").isNumber())
                .andExpect(jsonPath("$.admin.email").value("zeroon_ai@outlook.com"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode response = objectMapper.readTree(body);
        String token = response.path("accessToken").asText();
        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        UserEntity admin = userRepository.findByEmail("zeroon_ai@outlook.com").orElseThrow();
        assertThat(admin.getRoles()).isEqualTo(Set.of(UserRole.ADMIN));
        assertThat(auditEventRepository.findAll())
                .extracting(AuditEventEntity::getAction)
                .contains("ADMIN_AUTH_CODE_REQUESTED", "ADMIN_AUTH_LOGIN_SUCCEEDED");

        requestUserCode("zeroon_ai@outlook.com");
        mockMvc.perform(post("/api/v1/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "zeroon_ai@outlook.com",
                                  "code": "000000",
                                  "deviceId": "ordinary-app-session"
                                }
                                """))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void adminCodeIsIsolatedFromOrdinaryEmailLogin() throws Exception {
        requestAdminCode("zeroon_ai@outlook.com");

        mockMvc.perform(post("/api/v1/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "zeroon_ai@outlook.com",
                                  "code": "000000",
                                  "deviceId": "ordinary-device"
                                }
                                """))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/admin/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "zeroon_ai@outlook.com",
                                  "code": "000000",
                                  "deviceId": "admin-device"
                                }
                                """))
                .andExpect(status().isOk());
    }

    @Test
    void unapprovedEmailGetsGenericCodeResponseButCannotLogin() throws Exception {
        requestAdminCode("not-an-admin@example.com");

        mockMvc.perform(post("/api/v1/admin/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "not-an-admin@example.com",
                                  "code": "000000",
                                  "deviceId": "unknown-admin-device"
                                }
                                """))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error").value("unauthorized"));

        assertThat(userRepository.findByEmail("not-an-admin@example.com")).isEmpty();
    }

    @Test
    void ordinaryLoginNeverCarriesAdminAuthority() throws Exception {
        UserEntity user = new UserEntity("dual-role-user", null, "dual-role@example.com");
        user.grantRole(UserRole.ADMIN);
        userRepository.save(user);

        requestUserCode("dual-role@example.com");
        String body = mockMvc.perform(post("/api/v1/auth/email/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "dual-role@example.com",
                                  "code": "000000",
                                  "deviceId": "ordinary-dual-role-device"
                                }
                                """))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String token = objectMapper.readTree(body).path("accessToken").asText();
        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    private void requestAdminCode(String email) throws Exception {
        mockMvc.perform(post("/api/v1/admin/auth/email/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\"}"))
                .andExpect(status().isAccepted());
    }

    private void requestUserCode(String email) throws Exception {
        mockMvc.perform(post("/api/v1/auth/email/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\"}"))
                .andExpect(status().isAccepted());
    }
}
