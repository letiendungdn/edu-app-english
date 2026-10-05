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
@RequestMapping("/api/reading")
public class ReadingController {
  private final ContentService content;

  public ReadingController(ContentService content) {
    this.content = content;
  }

  @GetMapping
  public Object reading(@RequestParam(required = false) String level) {
    return content.readings(level);
  }

  @GetMapping("/{id}")
  public Object readingDetail(@PathVariable Long id) {
    return content.reading(id);
  }

  @PostMapping("/{id}/submit")
  public Object submitReading(@PathVariable Long id, @RequestBody SubmitRequest body) {
    var user = CurrentUser.optional();
    return content.submitReading(id, body.answers(), user == null ? null : user.id());
  }
}
