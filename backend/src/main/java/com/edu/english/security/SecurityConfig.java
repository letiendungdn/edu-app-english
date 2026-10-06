package com.edu.english.security;

import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class SecurityConfig {
  private final JwtAuthFilter jwtAuthFilter;
  private final String corsOrigins;

  public SecurityConfig(
      JwtAuthFilter jwtAuthFilter, @Value("${app.cors-origins}") String corsOrigins) {
    this.jwtAuthFilter = jwtAuthFilter;
    this.corsOrigins = corsOrigins;
  }

  @Bean
  PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http.csrf(AbstractHttpConfigurer::disable)
        .cors(Customizer.withDefaults())
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(
            auth ->
                auth.requestMatchers("/h2/**", "/actuator/health", "/actuator/health/**", "/actuator/prometheus", "/ws/**")
                    .permitAll()
                    .requestMatchers("/api/auth/**")
                    .permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/vocab/review")
                    .authenticated()
                    .requestMatchers(HttpMethod.POST, "/api/vocab/review")
                    .authenticated()
                    .requestMatchers(HttpMethod.GET, "/api/analytics")
                    .authenticated()
                    // Dữ liệu cá nhân: hồ sơ, band, lộ trình, bài làm.
                    .requestMatchers(
                        HttpMethod.GET,
                        "/api/ielts/**",
                        "/api/roadmap/**",
                        "/api/tests/attempts/**",
                        "/api/writing/submissions/**",
                        "/api/speaking/submissions/**")
                    .authenticated()
                    .requestMatchers(HttpMethod.GET, "/api/**")
                    .permitAll()
                    .requestMatchers(HttpMethod.POST, "/api/reading/**", "/api/listening/**", "/api/dictation")
                    .permitAll()
                    .anyRequest()
                    .authenticated())
        .exceptionHandling(
            e ->
                e.authenticationEntryPoint(
                    (req, res, ex) -> {
                      res.setStatus(401);
                      res.setContentType("application/json");
                      res.getWriter().write("{\"error\":\"Unauthorized\"}");
                    }))
        .headers(h -> h.frameOptions(f -> f.sameOrigin()))
        .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of(corsOrigins.split(",")));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    config.setAllowedHeaders(List.of("*"));
    config.setAllowCredentials(true);
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);
    return source;
  }
}
