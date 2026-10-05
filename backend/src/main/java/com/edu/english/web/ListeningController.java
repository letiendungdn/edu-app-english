package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.ContentService;
import com.edu.english.web.ApiModels.SubmitRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/listening")
public class ListeningController {
  private final ContentService content;

  public ListeningController(ContentService content) {
    this.content = content;
  }

  @GetMapping
  public Object listening(@RequestParam(required = false) String level) {
    return content.listenings(level);
  }

  @GetMapping("/{id}")
  public Object listeningDetail(@PathVariable Long id) {
    return content.listening(id);
  }

  @PostMapping("/{id}/submit")
  public Object submitListening(@PathVariable Long id, @RequestBody SubmitRequest body) {
    var user = CurrentUser.optional();
    return content.submitListening(id, body.answers(), user == null ? null : user.id());
  }
}
