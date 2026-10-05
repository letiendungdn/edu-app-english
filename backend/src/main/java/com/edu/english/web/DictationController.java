package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.ContentService;
import com.edu.english.web.ApiModels.DictationRequest;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dictation")
public class DictationController {
  private final ContentService content;

  public DictationController(ContentService content) {
    this.content = content;
  }

  @GetMapping
  public Object dictation(
      @RequestParam(required = false) String level, @RequestParam(defaultValue = "20") int limit) {
    return content.dictationWords(level, limit);
  }

  @PostMapping
  public Map<String, Boolean> dictation(@RequestBody DictationRequest body) {
    var user = CurrentUser.optional();
    content.recordDictation(body.vocabId(), body.userInput(), body.correct(), user == null ? null : user.id());
    return Map.of("ok", true);
  }
}
