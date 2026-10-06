package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.RoadmapService;
import com.edu.english.web.IeltsModels.RoadmapView;
import com.edu.english.web.IeltsModels.TaskUpdateRequest;
import com.edu.english.web.IeltsModels.TaskView;
import com.edu.english.web.IeltsModels.TodayView;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/roadmap")
public class RoadmapController {
  private final RoadmapService roadmap;

  public RoadmapController(RoadmapService roadmap) {
    this.roadmap = roadmap;
  }

  @GetMapping
  public RoadmapView roadmap() {
    return roadmap.view(CurrentUser.require().id());
  }

  @PostMapping("/generate")
  public RoadmapView generate() {
    return roadmap.generate(CurrentUser.require().id());
  }

  @GetMapping("/today")
  public TodayView today() {
    return roadmap.today(CurrentUser.require().id());
  }

  @PatchMapping("/tasks/{id}")
  public TaskView updateTask(@PathVariable Long id, @RequestBody TaskUpdateRequest body) {
    return roadmap.updateTask(CurrentUser.require().id(), id, body == null ? null : body.status());
  }
}
