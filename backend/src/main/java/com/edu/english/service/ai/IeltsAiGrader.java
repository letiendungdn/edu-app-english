package com.edu.english.service.ai;

import com.anthropic.client.AnthropicClient;
import com.anthropic.client.okhttp.AnthropicOkHttpClient;
import com.anthropic.core.JsonValue;
import com.anthropic.errors.AnthropicIoException;
import com.anthropic.errors.AnthropicServiceException;
import com.anthropic.errors.RateLimitException;
import com.anthropic.models.messages.StopReason;
import com.anthropic.models.messages.StructuredMessage;
import com.anthropic.models.messages.StructuredMessageCreateParams;
import com.anthropic.models.messages.MessageCreateParams;
import com.edu.english.config.AiProperties;
import com.edu.english.domain.SpeakingPrompt;
import com.edu.english.domain.WritingPrompt;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

/**
 * Chấm Writing và Speaking bằng Claude. Kết quả là JSON có schema cố định (structured output), không phải văn bản
 * tự do cần đoán cấu trúc.
 */
@Component
public class IeltsAiGrader {
  private final AiProperties properties;
  private final String writingRubric;
  private final String speakingRubric;
  private volatile AnthropicClient client;

  public IeltsAiGrader(AiProperties properties) {
    this.properties = properties;
    this.writingRubric = readResource("rubrics/writing.md");
    this.speakingRubric = readResource("rubrics/speaking.md");
  }

  public boolean enabled() {
    return properties.enabled();
  }

  public String model() {
    return properties.getModel();
  }

  public record Correction(
      @JsonPropertyDescription("Đoạn nguyên văn tiếng Anh của người học") String original,
      @JsonPropertyDescription("Cách viết/nói tốt hơn bằng tiếng Anh") String suggestion,
      @JsonPropertyDescription("Giải thích ngắn bằng tiếng Việt") String reason) {}

  public record WritingAssessment(
      @JsonPropertyDescription("Task Achievement (Task 1) hoặc Task Response (Task 2), số nguyên 0-9") int taskResponse,
      @JsonPropertyDescription("Coherence and Cohesion, số nguyên 0-9") int coherenceCohesion,
      @JsonPropertyDescription("Lexical Resource, số nguyên 0-9") int lexicalResource,
      @JsonPropertyDescription("Grammatical Range and Accuracy, số nguyên 0-9") int grammar,
      @JsonPropertyDescription("Nhận xét chung 2-3 câu bằng tiếng Việt") String summary,
      @JsonPropertyDescription("2-4 điểm mạnh, tiếng Việt") List<String> strengths,
      @JsonPropertyDescription("2-4 việc cần cải thiện để lên band, tiếng Việt") List<String> improvements,
      List<Correction> corrections) {}

  public record SpeakingAssessment(
      @JsonPropertyDescription("Fluency and Coherence, số nguyên 0-9") int fluencyCoherence,
      @JsonPropertyDescription("Lexical Resource, số nguyên 0-9") int lexicalResource,
      @JsonPropertyDescription("Grammatical Range and Accuracy, số nguyên 0-9") int grammar,
      @JsonPropertyDescription("Nhận xét chung 2-3 câu bằng tiếng Việt") String summary,
      @JsonPropertyDescription("2-4 điểm mạnh, tiếng Việt") List<String> strengths,
      @JsonPropertyDescription("2-4 việc cần cải thiện để lên band, tiếng Việt") List<String> improvements,
      List<Correction> corrections) {}

  /** Lỗi chấm có thông điệp hiển thị được cho người học, và cờ cho biết thử lại có ích không. */
  public static class GradingException extends RuntimeException {
    private final boolean retryable;

    public GradingException(String message, boolean retryable, Throwable cause) {
      super(message, cause);
      this.retryable = retryable;
    }

    public boolean retryable() {
      return retryable;
    }
  }

  public WritingAssessment gradeWriting(WritingPrompt prompt, String essay, int wordCount) {
    String task =
        """
        <task type="%s" module="%s" kind="%s" min_words="%d">
        %s
        </task>
        %s
        <response word_count="%d">
        %s
        </response>

        Assess this response.
        """
            .formatted(
                prompt.getTask(),
                prompt.getModule(),
                prompt.getTaskKind(),
                prompt.getMinWords(),
                prompt.getPrompt(),
                prompt.getChartData() == null ? "" : "<chart_data>\n" + prompt.getChartData() + "\n</chart_data>",
                wordCount,
                essay);
    return call(writingRubric, task, WritingAssessment.class);
  }

  public SpeakingAssessment gradeSpeaking(SpeakingPrompt prompt, String transcript, Integer durationSec) {
    String cue = prompt.getCueCardPoints().isEmpty() ? "" : "\nYou should say:\n- " + String.join("\n- ", prompt.getCueCardPoints());
    String task =
        """
        <question part="%d" topic="%s">
        %s%s
        </question>
        <transcript duration_seconds="%s">
        %s
        </transcript>

        Assess this answer.
        """
            .formatted(
                prompt.getPart(),
                prompt.getTopic(),
                prompt.getQuestion(),
                cue,
                durationSec == null ? "unknown" : durationSec.toString(),
                transcript);
    return call(speakingRubric, task, SpeakingAssessment.class);
  }

  private <T> T call(String system, String userMessage, Class<T> type) {
    if (!enabled()) throw new GradingException("AI chưa được cấu hình (APP_AI_API_KEY).", false, null);
    StructuredMessageCreateParams<T> params =
        MessageCreateParams.builder()
            .model(properties.getModel())
            .maxTokens(16000L)
            .system(system)
            .outputConfig(type)
            .addUserMessage(userMessage)
            // Khi bộ lọc an toàn từ chối, server tự chuyển sang model dự phòng thay vì dừng hẳn.
            .putAdditionalHeader("anthropic-beta", "server-side-fallback-2026-07-01")
            .putAdditionalBodyProperty("fallbacks", JsonValue.from("default"))
            .build();
    StructuredMessage<T> response;
    try {
      response = client().messages().create(params);
    } catch (RateLimitException ex) {
      throw new GradingException("Dịch vụ AI đang quá tải, thử lại sau ít phút.", true, ex);
    } catch (AnthropicServiceException ex) {
      boolean retryable = ex.statusCode() >= 500;
      throw new GradingException("Dịch vụ AI trả lỗi " + ex.statusCode() + ".", retryable, ex);
    } catch (AnthropicIoException ex) {
      throw new GradingException("Không kết nối được dịch vụ AI.", true, ex);
    }

    Optional<StopReason> stop = response.stopReason();
    if (stop.isPresent() && stop.get().equals(StopReason.REFUSAL)) {
      throw new GradingException("AI từ chối chấm bài này.", false, null);
    }
    if (stop.isPresent() && stop.get().equals(StopReason.MAX_TOKENS)) {
      throw new GradingException("Kết quả chấm bị cắt giữa chừng.", true, null);
    }
    return response.content().stream()
        .flatMap(block -> block.text().stream())
        .map(text -> text.text())
        .findFirst()
        .orElseThrow(() -> new GradingException("AI không trả kết quả chấm.", true, null));
  }

  private AnthropicClient client() {
    AnthropicClient current = client;
    if (current == null) {
      synchronized (this) {
        if (client == null) client = AnthropicOkHttpClient.builder().apiKey(properties.getApiKey()).build();
        current = client;
      }
    }
    return current;
  }

  private static String readResource(String path) {
    try (InputStream in = new ClassPathResource(path).getInputStream()) {
      return new String(in.readAllBytes(), StandardCharsets.UTF_8);
    } catch (IOException ex) {
      throw new IllegalStateException("Không đọc được " + path, ex);
    }
  }
}
