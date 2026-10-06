package com.edu.english.service;

import com.edu.english.config.PlatformGateway;
import com.edu.english.domain.Enums.ContentType;
import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.SrsCard;
import com.edu.english.domain.StudySession;
import com.edu.english.domain.Vocabulary;
import com.edu.english.repo.SrsCardRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.VocabularyRepository;
import com.edu.english.web.ApiModels.PictureItem;
import com.edu.english.web.ApiModels.PicturePage;
import com.edu.english.web.ApiModels.ReviewCard;
import com.edu.english.web.ApiModels.SrsView;
import com.edu.english.web.ApiModels.TopicView;
import com.edu.english.web.ApiModels.VocabPage;
import com.edu.english.web.ApiModels.VocabView;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VocabService {
  private final VocabularyRepository vocabulary;
  private final SrsCardRepository cards;
  private final StudySessionRepository sessions;
  private final PlatformGateway platform;

  public VocabService(
      VocabularyRepository vocabulary,
      SrsCardRepository cards,
      StudySessionRepository sessions,
      PlatformGateway platform) {
    this.vocabulary = vocabulary;
    this.cards = cards;
    this.sessions = sessions;
    this.platform = platform;
  }

  @Transactional(readOnly = true)
  public VocabPage list(String levelParam, int page, int limit, Long userId) {
    if (userId != null) return loadPage(levelParam, page, limit, userId);
    String key = "vocab:" + (levelParam == null ? "" : levelParam) + ":" + page + ":" + limit;
    return platform.cache(key, VocabPage.class, () -> loadPage(levelParam, page, limit, null));
  }

  private VocabPage loadPage(String levelParam, int page, int limit, Long userId) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), 100);
    EnglishLevel level = AuthService.parseLevel(levelParam);
    var pageable =
        PageRequest.of(safePage - 1, safeLimit, Sort.by("sortOrder").ascending().and(Sort.by("id")));
    Page<Vocabulary> result =
        level == null ? vocabulary.findAll(pageable) : vocabulary.findByLevel(level, pageable);

    Map<Long, SrsCard> srs =
        userId == null
            ? Map.of()
            : cards.findByUserIdAndContentType(userId, ContentType.VOCABULARY).stream()
                .collect(Collectors.toMap(SrsCard::getContentId, Function.identity(), (a, b) -> a));

    List<VocabView> words = result.getContent().stream().map(w -> toView(w, srs.get(w.getId()))).toList();
    return new VocabPage(result.getTotalElements(), safePage, safeLimit, words);
  }

  @Transactional(readOnly = true)
  public PicturePage picture(String levelParam, boolean picturesOnly, int limit) {
    EnglishLevel level = AuthService.parseLevel(levelParam);
    int safeLimit = Math.min(Math.max(limit, 1), 200);
    List<Vocabulary> words =
        level == null
            ? vocabulary.findAllByOrderBySortOrderAscIdAsc(PageRequest.of(0, safeLimit))
            : vocabulary.findByLevelOrderBySortOrderAscIdAsc(level, PageRequest.of(0, safeLimit));
    List<PictureItem> items =
        words.stream()
            .map(this::toPicture)
            .filter(item -> !picturesOnly || (item.imageUrl() != null && !item.imageUrl().isBlank()))
            .toList();
    return new PicturePage(items.size(), items);
  }

  @Transactional
  public List<ReviewCard> reviewQueue(Long userId) {
    List<SrsCard> due =
        cards
            .findByUserIdAndContentTypeAndNextReviewAtLessThanEqualOrderByNextReviewAtAsc(
                userId, ContentType.VOCABULARY, Instant.now())
            .stream()
            .limit(20)
            .toList();
    if (due.isEmpty()) {
      enrollStarterCards(userId);
      due =
          cards
              .findByUserIdAndContentTypeAndNextReviewAtLessThanEqualOrderByNextReviewAtAsc(
                  userId, ContentType.VOCABULARY, Instant.now())
              .stream()
              .limit(20)
              .toList();
    }
    return due.stream()
        .map(
            card -> {
              Vocabulary word = vocabulary.findById(card.getContentId()).orElse(null);
              return new ReviewCard(card.getId(), word == null ? null : toView(word, card));
            })
        .filter(card -> card.vocab() != null)
        .toList();
  }

  @Transactional
  public SrsCard submitReview(Long userId, Long vocabId, int quality) {
    if (vocabId == null || !vocabulary.existsById(vocabId)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Từ vựng không tồn tại");
    }
    SrsCard card =
        cards
            .findByUserIdAndContentTypeAndContentId(userId, ContentType.VOCABULARY, vocabId)
            .orElseGet(
                () -> {
                  SrsCard created = new SrsCard();
                  created.setUserId(userId);
                  created.setContentType(ContentType.VOCABULARY);
                  created.setContentId(vocabId);
                  created.setNextReviewAt(Instant.now());
                  return created;
                });
    Sm2.apply(card, quality);
    cards.save(card);
    addStudy(userId, 20, 1);
    platform.publish(
        PlatformGateway.VOCAB_REVIEWED,
        Map.of("userId", userId, "vocabId", vocabId, "quality", quality));
    return card;
  }

  @Transactional
  public void enrollStarterCards(Long userId) {
    List<Long> existing =
        cards.findByUserIdAndContentType(userId, ContentType.VOCABULARY).stream()
            .map(SrsCard::getContentId)
            .toList();
    List<Vocabulary> starters =
        vocabulary.findByLevelOrderBySortOrderAscIdAsc(EnglishLevel.A1, PageRequest.of(0, 8));
    for (Vocabulary word : starters) {
      if (existing.contains(word.getId())) continue;
      SrsCard card = new SrsCard();
      card.setUserId(userId);
      card.setContentType(ContentType.VOCABULARY);
      card.setContentId(word.getId());
      card.setNextReviewAt(Instant.now());
      cards.save(card);
    }
  }

  @Transactional
  public void addStudy(Long userId, int seconds, int cardsStudied) {
    LocalDate today = LocalDate.now();
    StudySession session =
        sessions
            .findByUserIdAndStudyDate(userId, today)
            .orElseGet(
                () -> {
                  StudySession created = new StudySession();
                  created.setUserId(userId);
                  created.setStudyDate(today);
                  return created;
                });
    session.setSeconds(session.getSeconds() + seconds);
    session.setCardsStudied(session.getCardsStudied() + cardsStudied);
    sessions.save(session);
  }

  private VocabView toView(Vocabulary w, SrsCard card) {
    return new VocabView(
        w.getId(),
        w.getWord(),
        w.getPhonetic(),
        w.getMeaningVi(),
        w.getMeaningEn(),
        w.getLevel().name(),
        w.getPartOfSpeech() == null ? null : w.getPartOfSpeech().name(),
        w.getExampleEn(),
        w.getExampleVi(),
        w.getImageUrl(),
        w.getTopic() == null ? null : new TopicView(w.getTopic().getName(), w.getTopic().getIcon()),
        card == null ? null : new SrsView(card.getNextReviewAt(), card.getRepetitions()));
  }

  private PictureItem toPicture(Vocabulary w) {
    return new PictureItem(
        w.getId(),
        w.getWord(),
        w.getPhonetic(),
        w.getMeaningVi(),
        w.getLevel().name(),
        w.getPartOfSpeech() == null ? null : w.getPartOfSpeech().name(),
        w.getExampleEn(),
        w.getTopic() == null ? null : new TopicView(w.getTopic().getName(), w.getTopic().getIcon()),
        w.getImageUrl());
  }
}
