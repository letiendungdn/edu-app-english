package com.edu.english.service;

import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.IeltsProfile;
import com.edu.english.repo.BandRecordRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.web.IeltsModels.ProfileRequest;
import com.edu.english.web.IeltsModels.ProfileView;
import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ProfileService {
  private final IeltsProfileRepository profiles;
  private final BandRecordRepository bandRecords;
  private final RoadmapService roadmaps;
  private final Clock clock;

  public ProfileService(
      IeltsProfileRepository profiles, BandRecordRepository bandRecords, RoadmapService roadmaps, Clock clock) {
    this.profiles = profiles;
    this.bandRecords = bandRecords;
    this.roadmaps = roadmaps;
    this.clock = clock;
  }

  @Transactional(readOnly = true)
  public ProfileView get(Long userId) {
    IeltsProfile profile =
        profiles.findById(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Chưa có hồ sơ IELTS"));
    return toView(profile);
  }

  /** Tạo hoặc sửa hồ sơ, rồi sinh lại lộ trình từ hôm nay. */
  @Transactional
  public ProfileView save(Long userId, ProfileRequest body) {
    if (body == null) throw bad("Thiếu dữ liệu hồ sơ");
    IeltsModule module = parseModule(body.module());
    double target = requireBand(body.targetBand(), "Band mục tiêu");
    if (target < 4.0) throw bad("Band mục tiêu tối thiểu là 4.0");
    Double current = body.currentBand() == null ? null : requireBand(body.currentBand(), "Band hiện tại");
    int minutes = body.dailyMinutes() == null ? 60 : body.dailyMinutes();
    if (minutes < 15 || minutes > 300) throw bad("Thời gian học mỗi ngày phải từ 15 đến 300 phút");
    int days = body.studyDaysPerWeek() == null ? 6 : body.studyDaysPerWeek();
    if (days < 3 || days > 7) throw bad("Số ngày học mỗi tuần phải từ 3 đến 7");
    LocalDate today = LocalDate.now(clock);
    if (body.examDate() != null && !body.examDate().isAfter(today)) throw bad("Ngày thi phải sau hôm nay");

    IeltsProfile profile = profiles.findById(userId).orElseGet(IeltsProfile::new);
    profile.setUserId(userId);
    profile.setModule(module);
    profile.setTargetBand(target);
    profile.setCurrentBand(current);
    profile.setExamDate(body.examDate());
    profile.setDailyMinutes(minutes);
    profile.setStudyDaysPerWeek(days);
    profiles.save(profile);
    roadmaps.generate(userId);
    return toView(profile);
  }

  /** Placement test xong thì band hiện tại lấy theo kết quả, không theo người học tự khai. */
  @Transactional
  public void applyPlacement(Long userId, Double overall) {
    profiles
        .findById(userId)
        .ifPresent(
            profile -> {
              if (overall != null) profile.setCurrentBand(overall);
            });
  }

  private ProfileView toView(IeltsProfile p) {
    LocalDate today = LocalDate.now(clock);
    boolean placementDone =
        bandRecords.findByUserIdOrderByRecordedAtAsc(p.getUserId()).stream().anyMatch(r -> r.getSource() == BandSource.PLACEMENT);
    return new ProfileView(
        p.getModule().name(),
        p.getCurrentBand(),
        p.getTargetBand(),
        p.getExamDate(),
        p.getExamDate() == null ? null : (int) ChronoUnit.DAYS.between(today, p.getExamDate()),
        p.getDailyMinutes(),
        p.getStudyDaysPerWeek(),
        placementDone);
  }

  private static IeltsModule parseModule(String value) {
    if (value == null) return IeltsModule.ACADEMIC;
    return switch (value.trim().toUpperCase()) {
      case "ACADEMIC" -> IeltsModule.ACADEMIC;
      case "GENERAL" -> IeltsModule.GENERAL;
      default -> throw bad("Dạng bài phải là ACADEMIC hoặc GENERAL");
    };
  }

  private static double requireBand(Double value, String label) {
    if (value == null) throw bad(label + " là bắt buộc");
    if (value < 0 || value > 9 || Math.abs(value * 2 - Math.round(value * 2)) > 1e-9) {
      throw bad(label + " phải từ 0 đến 9, bước 0.5");
    }
    return value;
  }

  private static ResponseStatusException bad(String message) {
    return new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
  }
}
