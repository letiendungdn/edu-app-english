package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.WritingService;
import com.edu.english.web.IeltsModels.WritingPromptView;
import com.edu.english.web.IeltsModels.WritingSubmissionView;
import com.edu.english.web.IeltsModels.WritingSubmitRequest;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/writing")
public class WritingController {
  private final WritingService writing;

  public WritingController(WritingService writing) {
    this.writing = writing;
  }

  @GetMapping("/prompts")
  public List<WritingPromptView> prompts() {
    var user = CurrentUser.optional();
    return writing.prompts(user == null ? null : user.id());
  }

  @GetMapping("/prompts/{id}")
  public WritingPromptView prompt(@PathVariable Long id) {
    var user = CurrentUser.optional();
    return writing.prompt(id, user == null ? null : user.id());
  }

  /** Trả 202: bài được chấm nền, frontend hỏi lại GET /submissions/{id} tới khi status khác PENDING. */
  @PostMapping("/submissions")
  @ResponseStatus(HttpStatus.ACCEPTED)
  public WritingSubmissionView submit(@RequestBody WritingSubmitRequest body) {
    return writing.submit(CurrentUser.require().id(), body.promptId(), body.text(), body.timeSpentSec());
  }

  @GetMapping("/submissions")
  public List<WritingSubmissionView> history() {
    return writing.history(CurrentUser.require().id());
  }

  @GetMapping("/submissions/{id}")
  public WritingSubmissionView submission(@PathVariable Long id) {
    return writing.get(CurrentUser.require().id(), id);
  }

  @PostMapping("/submissions/{id}/regrade")
  @ResponseStatus(HttpStatus.ACCEPTED)
  public WritingSubmissionView regrade(@PathVariable Long id) {
    return writing.regrade(CurrentUser.require().id(), id);
  }
}
