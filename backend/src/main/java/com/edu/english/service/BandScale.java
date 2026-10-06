package com.edu.english.service;

import java.util.Collection;
import java.util.List;
import java.util.Objects;

/** Quy tắc làm tròn và quy đổi band IELTS. Hàm thuần. */
public final class BandScale {
  private static final double EPS = 1e-9;

  private BandScale() {}

  public record Range(int rawMin, int rawMax, double band) {}

  /**
   * Band tổng: trung bình làm tròn đến 0.5 gần nhất, phần lẻ .25 làm tròn lên .5 và .75 làm tròn lên số nguyên kế
   * tiếp. Ví dụ 6.25 → 6.5, 6.75 → 7.0, 6.125 → 6.0.
   */
  public static double roundOverall(double average) {
    double whole = Math.floor(average + EPS);
    double fraction = average - whole;
    if (fraction < 0.25 - EPS) return whole;
    if (fraction < 0.75 - EPS) return whole + 0.5;
    return whole + 1.0;
  }

  /** Làm tròn đến 0.5 gần nhất (dùng cho band trung bình theo thời gian). */
  public static double roundHalf(double value) {
    return Math.round(value * 2) / 2.0;
  }

  /** Trung bình các band có giá trị rồi làm tròn kiểu band tổng. NULL nếu không có band nào. */
  public static Double overall(Collection<Double> bands) {
    List<Double> present = bands.stream().filter(Objects::nonNull).toList();
    if (present.isEmpty()) return null;
    return roundOverall(present.stream().mapToDouble(Double::doubleValue).average().orElse(0));
  }

  /** Band từ điểm các tiêu chí Writing/Speaking (0-9 mỗi tiêu chí). */
  public static double fromCriteria(double... scores) {
    double sum = 0;
    for (double s : scores) sum += s;
    return roundOverall(sum / scores.length);
  }

  /** Band Writing của một bài thi: Task 2 có trọng số gấp đôi Task 1. */
  public static Double writing(Double task1, Double task2) {
    if (task1 == null && task2 == null) return null;
    if (task1 == null) return task2;
    if (task2 == null) return task1;
    return roundOverall((task1 + 2 * task2) / 3);
  }

  /**
   * Quy đổi điểm thô sang band. Bài ít hơn 40 câu được quy về thang 40 trước khi tra bảng, nên chỉ là ước lượng.
   */
  public static double fromRaw(List<Range> table, int raw, int total) {
    if (total <= 0) return 0;
    int scaled = total == 40 ? raw : (int) Math.round(raw * 40.0 / total);
    int clamped = Math.max(0, Math.min(40, scaled));
    return table.stream()
        .filter(r -> clamped >= r.rawMin() && clamped <= r.rawMax())
        .mapToDouble(Range::band)
        .findFirst()
        .orElse(0);
  }
}
