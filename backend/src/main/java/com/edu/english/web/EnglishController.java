package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.AuthService;
import com.edu.english.service.ContentService;
import com.edu.english.service.VocabService;
import com.edu.english.web.ApiModels.AuthResponse;
import com.edu.english.web.ApiModels.DictationRequest;
import com.edu.english.web.ApiModels.ReviewRequest;
import com.edu.english.web.ApiModels.SubmitRequest;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class EnglishController {
  private final AuthService auth;
  private final VocabService vocab;
  private final ContentService content;

  public EnglishController(AuthService auth, VocabService vocab, ContentService content) {
    this.auth = auth;
    this.vocab = vocab;
    this.content = content;
  }

  @PostMapping("/auth/login")
  public AuthResponse login(@RequestBody LoginRequest body) {
    return auth.login(body.email(), body.password());
  }

  @PostMapping("/auth/register")
  public AuthResponse register(@RequestBody RegisterRequest body) {
    return auth.register(body.email(), body.password(), body.name());
  }

  @GetMapping("/auth/me")
  public ApiModels.UserView me() {
    return auth.me(CurrentUser.require());
  }

  @GetMapping("/vocab")
  public ApiModels.VocabPage vocab(
      @RequestParam(required = false) String level,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "30") int limit) {
    var user = CurrentUser.optional();
    return vocab.list(level, page, limit, user == null ? null : user.id());
  }

  @GetMapping("/vocab/picture")
  public ApiModels.PicturePage picture(
      @RequestParam(required = false) String level,
      @RequestParam(defaultValue = "false") boolean picturesOnly,
      @RequestParam(defaultValue = "200") int limit) {
    return vocab.picture(level, picturesOnly, limit);
  }

  @GetMapping("/vocab/review")
  public Object review() {
    return vocab.reviewQueue(CurrentUser.require().id());
  }

  @PostMapping("/vocab/review")
  public Map<String, Object> submitReview(@RequestBody ReviewRequest body) {
    var card = vocab.submitReview(CurrentUser.require().id(), body.vocabId(), body.quality());
    return Map.of("id", card.getId(), "interval", card.getIntervalDays(), "repetitions", card.getRepetitions());
  }

  @GetMapping("/grammar")
  public Object grammar(@RequestParam(required = false) String level) {
    return content.grammarTopics(level);
  }

  @GetMapping("/grammar/{id}")
  public Object grammarTopic(@PathVariable Long id) {
    return content.grammarTopic(id);
  }

  @GetMapping("/reading")
  public Object reading(@RequestParam(required = false) String level) {
    return content.readings(level);
  }

  @GetMapping("/reading/{id}")
  public Object readingDetail(@PathVariable Long id) {
    return content.reading(id);
  }

  @PostMapping("/reading/{id}/submit")
  public Object submitReading(@PathVariable Long id, @RequestBody SubmitRequest body) {
    var user = CurrentUser.optional();
    return content.submitReading(id, body.answers(), user == null ? null : user.id());
  }

  @GetMapping("/listening")
  public Object listening(@RequestParam(required = false) String level) {
    return content.listenings(level);
  }

  @GetMapping("/listening/{id}")
  public Object listeningDetail(@PathVariable Long id) {
    return content.listening(id);
  }

  @PostMapping("/listening/{id}/submit")
  public Object submitListening(@PathVariable Long id, @RequestBody SubmitRequest body) {
    var user = CurrentUser.optional();
    return content.submitListening(id, body.answers(), user == null ? null : user.id());
  }

  @GetMapping("/dictation")
  public Object dictation(
      @RequestParam(required = false) String level, @RequestParam(defaultValue = "20") int limit) {
    return content.dictationWords(level, limit);
  }

  @PostMapping("/dictation")
  public Map<String, Boolean> dictation(@RequestBody DictationRequest body) {
    var user = CurrentUser.optional();
    content.recordDictation(body.vocabId(), body.userInput(), body.correct(), user == null ? null : user.id());
    return Map.of("ok", true);
  }

  @GetMapping("/analytics")
  public Object analytics() {
    return content.analytics(CurrentUser.require().id());
  }

  public record LoginRequest(String email, String password) {}

  public record RegisterRequest(String email, String password, String name) {}
}
