package com.edu.english.service;

import com.edu.english.repo.WritingPhraseRepository;
import com.edu.english.web.IeltsModels.WritingPhraseView;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Ngân hàng cụm từ Writing. Nội dung tĩnh, nạp từ content/phrases.json. */
@Service
public class PhraseService {
  private final WritingPhraseRepository phrases;

  public PhraseService(WritingPhraseRepository phrases) {
    this.phrases = phrases;
  }

  @Transactional(readOnly = true)
  public List<WritingPhraseView> all() {
    return phrases.findAllByOrderBySortOrderAscIdAsc().stream()
        .map(p -> new WritingPhraseView(p.getId(), p.getTask(), p.getCategory(), p.getPhrase(), p.getMeaningVi(), p.getExample(), p.getBandMin()))
        .toList();
  }
}
