package com.edu.english.domain;

public final class Enums {
  private Enums() {}

  public enum Role {
    USER,
    ADMIN
  }

  public enum EnglishLevel {
    A1,
    A2,
    B1,
    B2,
    C1,
    C2
  }

  public enum PartOfSpeech {
    noun,
    verb,
    adjective,
    adverb,
    preposition,
    conjunction,
    pronoun,
    interjection,
    phrase,
    phrasal_verb
  }

  public enum ContentType {
    VOCABULARY,
    GRAMMAR
  }
}
