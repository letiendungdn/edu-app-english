package com.edu.english.service;

import com.edu.english.domain.Enums.QuestionType;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Chấm một câu trả lời Reading/Listening. Hàm thuần, không đụng database.
 *
 * <p>Quy tắc theo cách chấm IELTS: không phân biệt hoa thường, vượt giới hạn số từ là sai dù đúng nội dung, TRUE
 * không được thay bằng YES, câu "Choose TWO letters" tính mỗi chữ đúng một điểm.
 */
public final class AnswerGrader {
  private static final Pattern OPTIONAL_PART = Pattern.compile("\\(([^()]*)\\)");
  private static final Pattern THOUSANDS_COMMA = Pattern.compile("(?<=\\d),(?=\\d{3}\\b)");
  private static final Pattern EDGE_PUNCTUATION = Pattern.compile("^[\\s.,;:!?\"'()\\[\\]]+|[\\s.,;:!?\"'()\\[\\]]+$");
  private static final Pattern SPACES = Pattern.compile("\\s+");
  private static final Pattern KEY_SPLIT =
      Pattern.compile("[\\s,;/&]+|\\band\\b", Pattern.CASE_INSENSITIVE);

  private AnswerGrader() {}

  /** Số điểm tối đa của một câu. "Choose TWO letters" được 2 điểm như hai câu trên đề thật. */
  public static int maxPoints(QuestionType type, List<String> accepted) {
    if (type == QuestionType.MULTIPLE_CHOICE_MULTI) return Math.max(1, accepted.size());
    return 1;
  }

  public static int grade(QuestionType type, List<String> accepted, Integer wordLimit, String given) {
    if (given == null || given.isBlank() || accepted == null || accepted.isEmpty()) return 0;
    return switch (type) {
      case TRUE_FALSE_NOT_GIVEN -> judgement(given, "TRUE", "FALSE", accepted) ? 1 : 0;
      case YES_NO_NOT_GIVEN -> judgement(given, "YES", "NO", accepted) ? 1 : 0;
      case MULTIPLE_CHOICE_MULTI -> multi(given, accepted);
      default -> type.isTyped() ? (typed(given, accepted, wordLimit) ? 1 : 0) : (key(given, accepted) ? 1 : 0);
    };
  }

  /** Hiển thị đáp án chuẩn cho người học sau khi nộp. */
  public static String display(QuestionType type, List<String> accepted) {
    if (accepted == null || accepted.isEmpty()) return "";
    if (type == QuestionType.MULTIPLE_CHOICE_MULTI) return String.join(", ", accepted);
    return accepted.get(0);
  }

  /** Bỏ dấu câu ở hai đầu, hạ chữ thường, gộp khoảng trắng, chuẩn hoá dấu nháy và gạch ngang. */
  static String normalize(String value) {
    String text =
        value
            .replace('’', '\'')
            .replace('‘', '\'')
            .replace('“', '"')
            .replace('”', '"')
            .replace('–', '-')
            .replace('—', '-')
            .toLowerCase(Locale.ROOT);
    text = THOUSANDS_COMMA.matcher(text).replaceAll("");
    text = SPACES.matcher(text).replaceAll(" ");
    text = EDGE_PUNCTUATION.matcher(text).replaceAll("");
    text = text.replace(" %", "%");
    return text.trim();
  }

  static int wordCount(String normalized) {
    if (normalized.isEmpty()) return 0;
    return normalized.split(" ").length;
  }

  /** "(the) river (bank)" → mọi tổ hợp có hoặc không có phần trong ngoặc. */
  static List<String> expandOptional(String answer) {
    Matcher m = OPTIONAL_PART.matcher(answer);
    if (!m.find()) return List.of(answer);
    String with = answer.substring(0, m.start()) + m.group(1) + answer.substring(m.end());
    String without = answer.substring(0, m.start()) + answer.substring(m.end());
    List<String> result = new ArrayList<>(expandOptional(with));
    result.addAll(expandOptional(without));
    return result;
  }

  private static boolean typed(String given, List<String> accepted, Integer wordLimit) {
    String answer = normalize(given);
    if (answer.isEmpty()) return false;
    if (wordLimit != null && wordLimit > 0 && wordCount(answer) > wordLimit) return false;
    for (String option : accepted) {
      for (String variant : expandOptional(option)) {
        if (normalize(variant).equals(answer)) return true;
      }
    }
    return false;
  }

  private static boolean key(String given, List<String> accepted) {
    String answer = normalizeKey(given);
    return accepted.stream().anyMatch(a -> normalizeKey(a).equals(answer));
  }

  private static String normalizeKey(String value) {
    return normalize(value).replace(" ", "").toUpperCase(Locale.ROOT);
  }

  private static boolean judgement(String given, String positive, String negative, List<String> accepted) {
    String canonical = canonicalJudgement(given, positive, negative);
    if (canonical == null) return false;
    String expected = canonicalJudgement(accepted.get(0), positive, negative);
    return canonical.equals(expected);
  }

  private static String canonicalJudgement(String value, String positive, String negative) {
    String v = normalize(value).replaceAll("[^a-z ]", "").replace(" ", "");
    if (v.equals(positive.toLowerCase(Locale.ROOT)) || v.equals(positive.substring(0, 1).toLowerCase(Locale.ROOT))) {
      return positive;
    }
    if (v.equals(negative.toLowerCase(Locale.ROOT)) || v.equals(negative.substring(0, 1).toLowerCase(Locale.ROOT))) {
      return negative;
    }
    if (v.equals("notgiven") || v.equals("ng")) return "NOT GIVEN";
    return null;
  }

  private static int multi(String given, List<String> accepted) {
    Set<String> expected = new LinkedHashSet<>();
    for (String a : accepted) expected.add(normalizeKey(a));
    Set<String> chosen = new LinkedHashSet<>();
    for (String part : KEY_SPLIT.split(given.toUpperCase(Locale.ROOT))) {
      String k = normalizeKey(part);
      if (k.isEmpty()) continue;
      // "AC" gõ liền nhau: tách từng chữ khi mọi đáp án là một chữ cái.
      if (k.length() > 1 && k.chars().allMatch(Character::isLetter) && expected.stream().allMatch(e -> e.length() == 1)) {
        for (char c : k.toCharArray()) chosen.add(String.valueOf(c));
      } else {
        chosen.add(k);
      }
    }
    long hits = chosen.stream().filter(expected::contains).count();
    // Chọn thừa chữ thì trừ điểm, để không "chọn hết" mà vẫn đủ điểm.
    long penalty = Math.max(0, chosen.size() - expected.size());
    return (int) Math.max(0, hits - penalty);
  }
}
