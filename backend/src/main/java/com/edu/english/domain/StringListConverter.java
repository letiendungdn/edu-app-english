package com.edu.english.domain;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.ArrayList;
import java.util.List;

/** Lưu List<String> thành mảng JSON trong cột VARCHAR, chạy giống nhau trên H2 và Postgres. */
@Converter
public class StringListConverter implements AttributeConverter<List<String>, String> {
  private static final ObjectMapper JSON = new ObjectMapper();
  private static final TypeReference<List<String>> TYPE = new TypeReference<>() {};

  @Override
  public String convertToDatabaseColumn(List<String> values) {
    if (values == null) return null;
    try {
      return JSON.writeValueAsString(values);
    } catch (JsonProcessingException ex) {
      throw new IllegalArgumentException("Không ghi được danh sách", ex);
    }
  }

  @Override
  public List<String> convertToEntityAttribute(String column) {
    if (column == null || column.isBlank()) return new ArrayList<>();
    try {
      return new ArrayList<>(JSON.readValue(column, TYPE));
    } catch (JsonProcessingException ex) {
      throw new IllegalArgumentException("Cột JSON không hợp lệ: " + column, ex);
    }
  }
}
