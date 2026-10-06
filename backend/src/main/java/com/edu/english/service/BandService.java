package com.edu.english.service;

import com.edu.english.domain.BandRecord;
import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.IeltsProfile;
import com.edu.english.repo.BandConversionRepository;
import com.edu.english.repo.BandRecordRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.web.IeltsModels.BandPoint;
import com.edu.english.web.IeltsModels.BandSummary;
import java.time.Clock;
import java.time.Duration;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BandService {
  /** Band hiện tại tính trên kết quả trong khoảng này; cũ hơn coi như không còn phản ánh trình độ. */
  static final Duration WINDOW = Duration.ofDays(60);

  private static final List<Skill> SKILLS = List.of(Skill.LISTENING, Skill.READING, Skill.WRITING, Skill.SPEAKING);

  private final BandConversionRepository conversions;
  private final BandRecordRepository records;
  private final IeltsProfileRepository profiles;
  private final Clock clock;

  public BandService(
      BandConversionRepository conversions,
      BandRecordRepository records,
      IeltsProfileRepository profiles,
      Clock clock) {
    this.conversions = conversions;
    this.records = records;
    this.profiles = profiles;
    this.clock = clock;
  }

  /** Listening dùng chung một bảng; Reading có bảng riêng cho Academic và General Training. */
  @Transactional(readOnly = true)
  public double convert(Skill skill, IeltsModule module, int raw, int total) {
    IeltsModule tableModule =
        skill == Skill.LISTENING ? IeltsModule.BOTH : module == IeltsModule.GENERAL ? IeltsModule.GENERAL : IeltsModule.ACADEMIC;
    List<BandScale.Range> table =
        conversions.findBySkillAndModule(skill, tableModule).stream()
            .map(c -> new BandScale.Range(c.getRawMin(), c.getRawMax(), c.getBand()))
            .toList();
    return BandScale.fromRaw(table, raw, total);
  }

  @Transactional
  public void record(Long userId, Skill skill, double band, BandSource source, Long refId) {
    BandRecord record = new BandRecord();
    record.setUserId(userId);
    record.setSkill(skill);
    record.setBand(band);
    record.setSource(source);
    record.setSourceRefId(refId);
    record.setRecordedAt(clock.instant());
    records.save(record);
  }

  /**
   * Band hiện tại từng kỹ năng: trung bình có trọng số các kết quả gần đây, bài thi (placement, mock) nặng gấp đôi
   * bài luyện lẻ. Kỹ năng chưa có kết quả thì không có trong map.
   */
  @Transactional(readOnly = true)
  public Map<Skill, Double> currentSkillBands(Long userId) {
    Map<Skill, double[]> sums = new EnumMap<>(Skill.class);
    for (BandRecord r : records.findByUserIdAndRecordedAtAfterOrderByRecordedAtDesc(userId, clock.instant().minus(WINDOW))) {
      if (r.getSkill() == Skill.OVERALL) continue;
      double weight = r.getSource() == BandSource.PRACTICE ? 1 : 2;
      double[] acc = sums.computeIfAbsent(r.getSkill(), k -> new double[2]);
      acc[0] += r.getBand() * weight;
      acc[1] += weight;
    }
    Map<Skill, Double> result = new EnumMap<>(Skill.class);
    sums.forEach((skill, acc) -> result.put(skill, BandScale.roundHalf(acc[0] / acc[1])));
    return result;
  }

  @Transactional(readOnly = true)
  public BandSummary summary(Long userId) {
    Map<Skill, Double> bands = currentSkillBands(userId);
    IeltsProfile profile = profiles.findById(userId).orElse(null);
    Double overall = bands.size() == 4 ? BandScale.overall(bands.values()) : null;
    if (overall == null && profile != null && profile.getCurrentBand() != null) overall = profile.getCurrentBand();
    List<BandPoint> history = new ArrayList<>();
    for (BandRecord r : records.findByUserIdOrderByRecordedAtAsc(userId)) {
      history.add(new BandPoint(r.getSkill().name(), r.getBand(), r.getSource().name(), r.getRecordedAt()));
    }
    return new BandSummary(
        bands.get(Skill.LISTENING),
        bands.get(Skill.READING),
        bands.get(Skill.WRITING),
        bands.get(Skill.SPEAKING),
        overall,
        profile == null ? null : profile.getTargetBand(),
        history);
  }

  static List<Skill> skills() {
    return SKILLS;
  }
}
