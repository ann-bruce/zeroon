package ai.zeroon.prompt;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;

@SpringBootTest
@AutoConfigureMockMvc
class AdminPromptTemplateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PromptTemplateRepository promptTemplateRepository;

    @Autowired
    private UserRepository userRepository;

    @Test
    void adminCanListAndReadPromptTemplates() throws Exception {
        PromptTemplateEntity template = promptTemplateRepository.save(new PromptTemplateEntity(
                "COMPANION_REFLECTION",
                "Companion Reflection",
                "Stay brief and non-diagnostic.",
                true,
                1));
        String token = loginAdmin("13800138000");

        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(template.getId()))
                .andExpect(jsonPath("$.items[0].code").value("COMPANION_REFLECTION"))
                .andExpect(jsonPath("$.items[0].version").value(1));

        mockMvc.perform(get("/api/v1/admin/prompts/{promptId}", template.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(template.getId()))
                .andExpect(jsonPath("$.content").value("Stay brief and non-diagnostic."));
    }

    @Test
    void promptAdminRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/admin/prompts"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void normalUserCannotAccessPromptAdmin() throws Exception {
        String token = login("13800138001");

        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    private String loginAdmin(String mobile) throws Exception {
        UserEntity admin = new UserEntity("admin-prompt-test", mobile);
        admin.grantRole(UserRole.ADMIN);
        userRepository.save(admin);
        return login(mobile);
    }

    private String login(String mobile) throws Exception {
        mockMvc.perform(post("/api/v1/auth/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mobile\":\"" + mobile + "\"}"))
                .andExpect(status().isAccepted());
        String body = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                  {
                                    "mobile": "%s",
                                    "code": "000000",
                                    "deviceId": "admin-prompt-test"
                                  }
                                  """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
