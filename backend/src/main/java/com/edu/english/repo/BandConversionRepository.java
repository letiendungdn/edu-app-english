package com.edu.english.repo;

import com.edu.english.domain.BandConversion;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.Skill;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BandConversionRepository extends JpaRepository<BandConversion, Long> {
  List<BandConversion> findBySkillAndModule(Skill skill, IeltsModule module);
}
