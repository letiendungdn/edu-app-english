wanted = {}
File.foreach("/tmp/need-examples.txt") { |line| wanted[line.strip] = true if line.strip != "" }

def unescape(text)
  text.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.hex].pack("U") }
      .gsub("\\n", " ")
      .gsub('\\"', '"')
      .gsub("\\/", "/")
      .gsub(/\s+/, " ")
      .strip
end

def contains_word?(text, word)
  text.match?(/\b#{Regexp.escape(word)}(?:s|es|ed|ing|er|est|ly|d)?\b/i)
end

count = 0
STDIN.each_line do |line|
  raw = line[/"word": "((?:\\.|[^"\\])*)", "lang": "English"/, 1]
  next if raw.nil?
  word = unescape(raw).downcase
  next unless wanted[word]
  section = line.split('"examples":', 2)[1].to_s
  section.scan(/"text": "((?:\\.|[^"\\])*)"/) do |match|
    text = unescape(match[0])
    next if text.length < 12 || text.length > 220
    next unless contains_word?(text, word)
    puts "#{word}\t#{text.gsub("\t", " ")}"
    count += 1
    break
  end
end
warn "extracted_examples=#{count}"
