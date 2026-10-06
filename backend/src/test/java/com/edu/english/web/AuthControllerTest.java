package com.edu.english.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest(properties = "spring.datasource.url=jdbc:h2:mem:english_p0;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1")
@AutoConfigureMockMvc
class AuthControllerTest {
  @Autowired private MockMvc mvc;

  @Test
  void registerLoginAndMe() throws Exception {
    String email = ("P0." + UUID.randomUUID() + "@Edu.App").toLowerCase();
    String body =
        """
        {"email":"%s","password":"secret1","name":"P0"}
        """
            .formatted(email);

    mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON).content(body))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.token").isNotEmpty())
        .andExpect(jsonPath("$.user.email").value(email))
        .andExpect(jsonPath("$.user.name").value("P0"))
        .andExpect(jsonPath("$.user.role").value("USER"));

    mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON).content(body))
        .andExpect(status().isConflict())
        .andExpect(jsonPath("$.error").value("Email đã tồn tại"));

    MvcResult loggedIn =
        mvc.perform(
                post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        """
                        {"email":"%s","password":"secret1"}
                        """
                            .formatted(email)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").isNotEmpty())
            .andReturn();

    String token = com.jayway.jsonpath.JsonPath.read(loggedIn.getResponse().getContentAsString(), "$.token");

    mvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + token))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.email").value(email))
        .andExpect(jsonPath("$.name").value("P0"));
  }

  @Test
  void loginRejectsWrongPassword() throws Exception {
    String email = ("bad." + UUID.randomUUID() + "@edu.app");
    mvc.perform(
            post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {"email":"%s","password":"secret1","name":"Bad"}
                    """
                        .formatted(email)))
        .andExpect(status().isOk());

    mvc.perform(
            post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {"email":"%s","password":"wrong-pass"}
                    """
                        .formatted(email)))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error").value("Email hoặc mật khẩu không đúng"));
  }

  @Test
  void registerRejectsShortPassword() throws Exception {
    mvc.perform(
            post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {"email":"short-%s@edu.app","password":"123","name":"X"}
                    """
                        .formatted(UUID.randomUUID())))
        .andExpect(status().isBadRequest());
  }

  @Test
  void meRequiresToken() throws Exception {
    mvc.perform(get("/api/auth/me"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error").value("Unauthorized"));
  }

  @Test
  void seededContentIsReadableWithoutAuth() throws Exception {
    mvc.perform(get("/api/reading"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[?(@.title == 'My Daily Routine')]").exists());
    mvc.perform(get("/api/vocab").param("level", "A1"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.words[?(@.word == 'hello')]").exists());
    mvc.perform(get("/api/grammar"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[?(@.title == 'Present Simple')]").exists());
    mvc.perform(get("/api/listening"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[?(@.title == 'At the Cafe')]").exists());
  }
}
