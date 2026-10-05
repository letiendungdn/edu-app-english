package com.edu.english.web;

import com.edu.english.service.ContentService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/grammar")
public class GrammarController {
  private final ContentService content;

  public GrammarController(ContentService content) {
    this.content = content;
  }

  @GetMapping
  public Object grammar(@RequestParam(required = false) String level) {
    return content.grammarTopics(level);
  }

  @GetMapping("/{id}")
  public Object grammarTopic(@PathVariable Long id) {
    return content.grammarTopic(id);
  }
}
