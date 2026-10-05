package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.VocabService;
import com.edu.english.web.ApiModels.ReviewRequest;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/vocab")
public class VocabController {
  private final VocabService vocab;

  public VocabController(VocabService vocab) {
    this.vocab = vocab;
  }

  @GetMapping
  public ApiModels.VocabPage vocab(
      @RequestParam(required = false) String level,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "30") int limit) {
    var user = CurrentUser.optional();
    return vocab.list(level, page, limit, user == null ? null : user.id());
  }

  @GetMapping("/picture")
  public ApiModels.PicturePage picture(
      @RequestParam(required = false) String level,
      @RequestParam(defaultValue = "false") boolean picturesOnly,
      @RequestParam(defaultValue = "200") int limit) {
    return vocab.picture(level, picturesOnly, limit);
  }

  @GetMapping("/review")
  public Object review() {
    return vocab.reviewQueue(CurrentUser.require().id());
  }

  @PostMapping("/review")
  public Map<String, Object> submitReview(@RequestBody ReviewRequest body) {
    var card = vocab.submitReview(CurrentUser.require().id(), body.vocabId(), body.quality());
    return Map.of("id", card.getId(), "interval", card.getIntervalDays(), "repetitions", card.getRepetitions());
  }
}
