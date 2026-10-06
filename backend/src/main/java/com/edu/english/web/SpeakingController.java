package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.SpeakingService;
import com.edu.english.web.IeltsModels.SpeakingPromptView;
import com.edu.english.web.IeltsModels.SpeakingSubmissionView;
import java.util.List;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/speaking")
public class SpeakingController {
  private final SpeakingService speaking;

  public SpeakingController(SpeakingService speaking) {
    this.speaking = speaking;
  }

  @GetMapping("/prompts")
  public List<SpeakingPromptView> prompts() {
    var user = CurrentUser.optional();
    return speaking.prompts(user == null ? null : user.id());
  }

  @GetMapping("/prompts/{id}")
  public SpeakingPromptView prompt(@PathVariable Long id) {
    var user = CurrentUser.optional();
    return speaking.prompt(id, user == null ? null : user.id());
  }

  /** multipart: promptId, transcript (trình duyệt nhận dạng), durationSec, audio (tùy chọn). */
  @PostMapping(value = "/submissions", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  @ResponseStatus(HttpStatus.ACCEPTED)
  public SpeakingSubmissionView submit(
      @RequestParam Long promptId,
      @RequestParam(required = false) String transcript,
      @RequestParam(required = false) Integer durationSec,
      @RequestPart(required = false) MultipartFile audio) {
    return speaking.submit(CurrentUser.require().id(), promptId, transcript, durationSec, audio);
  }

  @GetMapping("/submissions")
  public List<SpeakingSubmissionView> history() {
    return speaking.history(CurrentUser.require().id());
  }

  @GetMapping("/submissions/{id}")
  public SpeakingSubmissionView submission(@PathVariable Long id) {
    return speaking.get(CurrentUser.require().id(), id);
  }

  @GetMapping("/submissions/{id}/audio")
  public ResponseEntity<Resource> audio(@PathVariable Long id) {
    Resource audio = speaking.audio(CurrentUser.require().id(), id);
    MediaType type = MediaTypeFactory.getMediaType(audio).orElse(MediaType.parseMediaType("audio/webm"));
    return ResponseEntity.ok().contentType(type).body(audio);
  }

  @PostMapping("/submissions/{id}/regrade")
  @ResponseStatus(HttpStatus.ACCEPTED)
  public SpeakingSubmissionView regrade(@PathVariable Long id) {
    return speaking.regrade(CurrentUser.require().id(), id);
  }
}
