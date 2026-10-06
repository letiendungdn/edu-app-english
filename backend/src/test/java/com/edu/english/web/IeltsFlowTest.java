package com.edu.english.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

@SpringBootTest(
    properties = {
      "spring.datasource.url=jdbc:h2:mem:ielts_flow;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1",
      "app.ai.api-key="
    })
@AutoConfigureMockMvc
class IeltsFlowTest {
  @Autowired private MockMvc mvc;
  @Autowired private ObjectMapper json;
  private String token;

  @BeforeEach
  void register() throws Exception {
    String email = "ielts." + UUID.randomUUID() + "@edu.app";
    String body = mvc.perform(
            post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"" + email + "\",\"password\":\"secret1\",\"name\":\"Learner\"}"))
        .andExpect(status().isOk())
        .andReturn()
        .getResponse()
        .getContentAsString();
    token = json.readTree(body).path("token").asText();
  }

  @Test
  void personalEndpointsRequireLogin() throws Exception {
    mvc.perform(get("/api/roadmap/today")).andExpect(status().isUnauthorized());
    mvc.perform(get("/api/ielts/profile")).andExpect(status().isUnauthorized());
  }

  @Test
  void onboardingCreatesRoadmapWithTodaysTasks() throws Exception {
    mvc.perform(auth(get("/api/ielts/profile"))).andExpect(status().isNotFound());
    saveProfile(5.5, 6.5);

    JsonNode today = read(auth(get("/api/roadmap/today")));
    assertThat(today.path("tasks").size()).isGreaterThan(0);
    assertThat(today.path("bands").path("target").asDouble()).isEqualTo(6.5);

    JsonNode roadmap = read(auth(get("/api/roadmap")));
    assertThat(roadmap.path("phases").get(0).path("kind").asText()).isEqualTo("FOUNDATION");
    assertThat(roadmap.path("tasksTotal").asInt()).isGreaterThan(50);

    mvc.perform(
            auth(put("/api/ielts/profile"))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"module\":\"ACADEMIC\",\"targetBand\":6.3}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void readingNeverLeaksAnswersAndGradesAllQuestionTypes() throws Exception {
    saveProfile(5.5, 6.5);
    long passageId = findId(read(get("/api/reading")), "The Return of the Urban Beekeeper");
    String raw = mvc.perform(get("/api/reading/" + passageId)).andReturn().getResponse().getContentAsString();
    assertThat(raw).doesNotContain("acceptedAnswers").doesNotContain("ornamental\"");

    // Câu cuối "a keeper" sai: đáp án là "(trained) keeper", mạo từ thừa không được chấp nhận.
    List<String> given =
        List.of("ii", "i", "v", "iv", "vi", "TRUE", "FALSE", "NOT GIVEN", "TRUE", "Ornamental", "stems", "pollinator corridors", "a keeper");
    Map<String, String> answers = answersFor(json.readTree(raw), given);

    JsonNode result =
        read(
            auth(post("/api/reading/" + passageId + "/submit"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("answers", answers))));
    assertThat(result.path("correct").asInt()).isEqualTo(12);
    assertThat(result.path("total").asInt()).isEqualTo(13);
    assertThat(result.path("estimatedBand").isNull()).isFalse();
  }

  @Test
  void placementTestGivesBandsAndUpdatesProfileWithoutAi() throws Exception {
    saveProfile(null, 7.0);
    JsonNode attempt = read(auth(post("/api/tests/placement/attempts")));
    long attemptId = attempt.path("id").asLong();
    assertThat(attempt.path("sections").size()).isEqualTo(4);

    Map<String, String> answers = new LinkedHashMap<>();
    for (JsonNode section : attempt.path("sections")) {
      for (JsonNode group : section.path("groups")) {
        for (JsonNode q : group.path("questions")) answers.put(q.path("id").asText(), "A");
      }
    }
    Long writingPromptId = null;
    for (JsonNode section : attempt.path("sections")) {
      if (section.path("skill").asText().equals("WRITING")) writingPromptId = section.path("refId").asLong();
    }
    String essay = "Some people think university should be free. ".repeat(10);
    mvc.perform(
            auth(patch("/api/tests/attempts/" + attemptId))
                .contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("answers", answers, "writingDrafts", Map.of(String.valueOf(writingPromptId), essay)))))
        .andExpect(status().isOk());

    JsonNode reopened = read(auth(post("/api/tests/placement/attempts")));
    assertThat(reopened.path("id").asLong()).isEqualTo(attemptId);
    assertThat(reopened.path("answers").size()).isEqualTo(answers.size());

    JsonNode submitted = read(auth(post("/api/tests/attempts/" + attemptId + "/submit")));
    assertThat(submitted.path("listening").path("total").asInt()).isEqualTo(20);
    assertThat(submitted.path("reading").path("total").asInt()).isEqualTo(13);

    JsonNode result = read(auth(get("/api/tests/attempts/" + attemptId + "/result")));
    assertThat(result.path("writing").get(0).path("status").asText()).isEqualTo("FAILED");
    assertThat(result.path("bandOverall").isNull()).isFalse();

    JsonNode profile = read(auth(get("/api/ielts/profile")));
    assertThat(profile.path("placementDone").asBoolean()).isTrue();
    assertThat(profile.path("currentBand").asDouble()).isEqualTo(result.path("bandOverall").asDouble());
  }

  @Test
  void writingSubmissionIsSavedWhenAiIsOff() throws Exception {
    JsonNode prompts = read(get("/api/writing/prompts"));
    long promptId = prompts.get(0).path("id").asLong();
    mvc.perform(
            auth(post("/api/writing/submissions"))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"promptId\":" + promptId + ",\"text\":\"too short\"}"))
        .andExpect(status().isBadRequest());
    mvc.perform(
            auth(post("/api/writing/submissions"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("promptId", promptId, "text", "The chart shows a clear rise. ".repeat(10)))))
        .andExpect(status().isAccepted())
        .andExpect(jsonPath("$.status").value("FAILED"))
        .andExpect(jsonPath("$.wordCount").value(60));
    mvc.perform(auth(get("/api/ielts/ai-status"))).andExpect(jsonPath("$.enabled").value(false));
  }

  private void saveProfile(Double current, double target) throws Exception {
    Map<String, Object> body = new LinkedHashMap<>();
    body.put("module", "ACADEMIC");
    body.put("currentBand", current);
    body.put("targetBand", target);
    body.put("examDate", LocalDate.now().plusWeeks(12).toString());
    body.put("dailyMinutes", 60);
    body.put("studyDaysPerWeek", 6);
    mvc.perform(auth(put("/api/ielts/profile")).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)))
        .andExpect(status().isOk());
  }

  private Map<String, String> answersFor(JsonNode passage, List<String> inOrder) {
    Map<String, String> answers = new LinkedHashMap<>();
    int i = 0;
    for (JsonNode group : passage.path("groups")) {
      for (JsonNode q : group.path("questions")) answers.put(q.path("id").asText(), inOrder.get(i++));
    }
    return answers;
  }

  private static long findId(JsonNode list, String title) {
    for (JsonNode item : list) if (item.path("title").asText().equals(title)) return item.path("id").asLong();
    throw new AssertionError("Không thấy " + title);
  }

  private MockHttpServletRequestBuilder auth(MockHttpServletRequestBuilder request) {
    return request.header("Authorization", "Bearer " + token);
  }

  private JsonNode read(MockHttpServletRequestBuilder request) throws Exception {
    String body = mvc.perform(request).andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
    return json.readTree(body);
  }
}
