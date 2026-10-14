package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.MistakeService;
import com.edu.english.web.ApiModels.MistakeView;
import com.edu.english.web.ApiModels.QuestionTypeStat;
import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/mistakes")
public class MistakeController {
  private final MistakeService mistakes;

  public MistakeController(MistakeService mistakes) {
    this.mistakes = mistakes;
  }

  /** Sổ lỗi sai. skill: LISTENING | READING, bỏ trống là cả hai. */
  @GetMapping
  public List<MistakeView> list(@RequestParam(required = false) String skill) {
    return mistakes.mistakes(CurrentUser.require().id(), skill);
  }

  /** Số câu đang sai, cho huy hiệu trên menu. */
  @GetMapping("/count")
  public Map<String, Long> count() {
    return Map.of("open", mistakes.openCount(CurrentUser.require().id()));
  }

  @PostMapping("/{questionId}/reviewed")
  public ResponseEntity<Void> reviewed(@PathVariable Long questionId) {
    mistakes.markReviewed(CurrentUser.require().id(), questionId);
    return ResponseEntity.noContent().build();
  }

  /** Độ chính xác theo dạng câu hỏi trong 90 ngày. */
  @GetMapping("/question-types")
  public List<QuestionTypeStat> questionTypes() {
    return mistakes.stats(CurrentUser.require().id());
  }
}
