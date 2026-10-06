package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.TestService;
import com.edu.english.web.IeltsModels.AttemptResult;
import com.edu.english.web.IeltsModels.AttemptSaveRequest;
import com.edu.english.web.IeltsModels.AttemptSummary;
import com.edu.english.web.IeltsModels.AttemptView;
import com.edu.english.web.IeltsModels.TestListItem;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/tests")
public class TestController {
  private final TestService tests;

  public TestController(TestService tests) {
    this.tests = tests;
  }

  @GetMapping
  public List<TestListItem> list() {
    var user = CurrentUser.optional();
    return tests.list(user == null ? null : user.id());
  }

  @PostMapping("/{id}/attempts")
  public AttemptView start(@PathVariable Long id) {
    return tests.start(CurrentUser.require().id(), id);
  }

  @PostMapping("/placement/attempts")
  public AttemptView startPlacement() {
    return tests.startPlacement(CurrentUser.require().id());
  }

  @GetMapping("/attempts")
  public List<AttemptSummary> history() {
    return tests.history(CurrentUser.require().id());
  }

  @GetMapping("/attempts/{id}")
  public AttemptView attempt(@PathVariable Long id) {
    return tests.get(CurrentUser.require().id(), id);
  }

  /** Lưu tự động: frontend gọi mỗi 30 giây và khi chuyển phần. */
  @PatchMapping("/attempts/{id}")
  public Map<String, Boolean> save(@PathVariable Long id, @RequestBody AttemptSaveRequest body) {
    tests.save(CurrentUser.require().id(), id, body);
    return Map.of("ok", true);
  }

  @PostMapping("/attempts/{id}/submit")
  public AttemptResult submit(@PathVariable Long id, @RequestBody(required = false) AttemptSaveRequest body) {
    return tests.submit(CurrentUser.require().id(), id, body);
  }

  @GetMapping("/attempts/{id}/result")
  public AttemptResult result(@PathVariable Long id) {
    return tests.result(CurrentUser.require().id(), id);
  }
}
