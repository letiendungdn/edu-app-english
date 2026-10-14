# Reads English Wiktionary JSONL on stdin. Writes word, pos, Vietnamese gloss.
wanted = {}
File.foreach("/tmp/wanted-en-words.txt") { |line| wanted[line.strip] = true }

def unescape(text)
  text.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.hex].pack("U") }
      .gsub("\\n", " ")
      .gsub('\\"', '"')
      .gsub("\\/", "/")
      .gsub(/\s+/, " ")
      .strip
end

def good_vi?(text, word)
  return false if text.nil? || text.empty? || text.length > 80
  return false if text.casecmp?(word)
  return false if text.match?(/[<{]|http|form of|synonym of/i)
  text.match?(/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i)
end

count = 0
STDIN.each_line do |line|
  word = line[/"word": "((?:\\.|[^"\\])*)", "lang": "English"/, 1]
  next if word.nil?
  key = unescape(word).downcase
  next unless wanted[key]
  pos = line[/\A\{"pos": "([^"]+)"/, 1] || line[/"pos": "([^"]+)"/, 1]
  section = line.split('"translations":', 2)[1].to_s
  gloss = nil
  section.scan(/"lang_code": "vi".{0,900}?"word": "((?:\\.|[^"\\])*)"/) do |match|
    candidate = unescape(match[0])
    if good_vi?(candidate, key)
      gloss = candidate
      break
    end
  end
  next if gloss.nil?
  puts "#{key}\t#{pos}\t#{gloss.gsub("\t", " ")}"
  count += 1
end
warn "extracted=#{count}"
