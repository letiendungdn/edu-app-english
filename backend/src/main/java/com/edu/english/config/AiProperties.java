package com.edu.english.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.ai")
public class AiProperties {
  private String apiKey = "";
  private String model = "claude-opus-5-5";
  private int dailyLimit = 10;

  public boolean enabled() {
    return apiKey != null && !apiKey.isBlank();
  }

  public String getApiKey() {
    return apiKey;
  }

  public void setApiKey(String apiKey) {
    this.apiKey = apiKey;
  }

  public String getModel() {
    return model;
  }

  public void setModel(String model) {
    this.model = model;
  }

  public int getDailyLimit() {
    return dailyLimit;
  }

  public void setDailyLimit(int dailyLimit) {
    this.dailyLimit = dailyLimit;
  }
}
