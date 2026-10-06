package com.edu.english.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

/** Lưu file ghi âm Speaking trên đĩa. Database chỉ giữ đường dẫn tương đối. */
@Component
public class AudioStorage {
  private final Path root;

  public AudioStorage(@Value("${app.storage.dir}") String dir) {
    this.root = Path.of(dir).toAbsolutePath().normalize();
  }

  public String save(MultipartFile file) {
    String type = file.getContentType() == null ? "" : file.getContentType();
    if (!type.startsWith("audio/") && !type.equals("video/webm")) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File ghi âm phải là audio");
    }
    String extension = type.contains("ogg") ? ".ogg" : type.contains("mp4") || type.contains("m4a") ? ".m4a" : ".webm";
    String relative = "speaking/" + UUID.randomUUID() + extension;
    Path target = resolve(relative);
    try (InputStream in = file.getInputStream()) {
      Files.createDirectories(target.getParent());
      Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
    } catch (IOException ex) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Không lưu được file ghi âm", ex);
    }
    return relative;
  }

  public Resource open(String relative) {
    Path path = resolve(relative);
    if (!Files.isRegularFile(path)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không còn file ghi âm");
    return new FileSystemResource(path);
  }

  /** Chặn đường dẫn thoát ra ngoài thư mục lưu trữ ("../"). */
  private Path resolve(String relative) {
    Path path = root.resolve(relative).normalize();
    if (!path.startsWith(root)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đường dẫn không hợp lệ");
    return path;
  }
}
