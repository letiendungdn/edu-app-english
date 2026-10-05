package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.ContentService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {
  private final ContentService content;

  public AnalyticsController(ContentService content) {
    this.content = content;
  }

  @GetMapping
  public Object analytics() {
    return content.analytics(CurrentUser.require().id());
  }
}
