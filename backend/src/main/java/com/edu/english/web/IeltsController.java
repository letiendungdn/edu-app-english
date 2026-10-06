package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.AiUsage;
import com.edu.english.service.BandService;
import com.edu.english.service.ProfileService;
import com.edu.english.web.IeltsModels.AiStatus;
import com.edu.english.web.IeltsModels.BandSummary;
import com.edu.english.web.IeltsModels.ProfileRequest;
import com.edu.english.web.IeltsModels.ProfileView;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ielts")
public class IeltsController {
  private final ProfileService profiles;
  private final BandService bands;
  private final AiUsage ai;

  public IeltsController(ProfileService profiles, BandService bands, AiUsage ai) {
    this.profiles = profiles;
    this.bands = bands;
    this.ai = ai;
  }

  /** 404 nghĩa là chưa onboarding. */
  @GetMapping("/profile")
  public ProfileView profile() {
    return profiles.get(CurrentUser.require().id());
  }

  /** Tạo hoặc sửa hồ sơ. Lộ trình được sinh lại từ hôm nay. */
  @PutMapping("/profile")
  public ProfileView saveProfile(@RequestBody ProfileRequest body) {
    return profiles.save(CurrentUser.require().id(), body);
  }

  @GetMapping("/bands")
  public BandSummary bands() {
    return bands.summary(CurrentUser.require().id());
  }

  @GetMapping("/ai-status")
  public AiStatus aiStatus() {
    return ai.status(CurrentUser.require().id());
  }
}
