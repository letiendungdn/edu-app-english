package com.edu.english.web;

import java.util.regex.Pattern;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.NOT_FOUND;

/** File nghe và hình minh hoạ đặt trong resources/media. */
@RestController
public class MediaController {
  private static final Pattern NAME = Pattern.compile("[a-z0-9][a-z0-9.-]{0,80}");

  @GetMapping("/api/media/{name}")
  public ResponseEntity<Resource> media(@PathVariable String name) {
    if (!NAME.matcher(name).matches()) {
      throw new ResponseStatusException(NOT_FOUND);
    }
    Resource resource = new ClassPathResource("media/" + name);
    if (!resource.exists()) {
      throw new ResponseStatusException(NOT_FOUND);
    }
    return ResponseEntity.ok().contentType(typeOf(name)).body(resource);
  }

  private static MediaType typeOf(String name) {
    if (name.endsWith(".svg")) return MediaType.valueOf("image/svg+xml");
    if (name.endsWith(".m4a")) return MediaType.valueOf("audio/mp4");
    return MediaType.APPLICATION_OCTET_STREAM;
  }
}
