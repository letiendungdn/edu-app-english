# frozen_string_literal: true

require "json"

VOCAB = "backend/src/main/resources/content/vocab.json"
DICT_DIR = "/tmp/wordset"

def usable?(meaning)
  labels = meaning["labels"] || []
  return false if labels.any? { |label| label["is_dialect"] || label["name"].to_s.match?(/slang|archaic|obsolete|rare|dialect/i) }
  text = meaning["def"].to_s
  return false if text.match?(/\A\s*\(/)
  return false if text.match?(/\[Obs\.\]|\bthou\b|\bthee\b/i)

  true
end

def score(meaning, word)
  return -100 unless usable?(meaning)

  text = meaning["def"].to_s
  value = 0
  value -= 12 if text.match?(/organized crime|mother superior|stringy slimy|course of instruction|shade of|colo[u]r of|without undergrowth|police register|card game|excretory|deteriorate|facility that provides|four elements|yeast cells|pretend|gambling|casino|porous calcified|earth's surface covered|group of fish|formally educated/i)
  value -= 4 if text.match?(/\A\s*(a|an) term of address\b/i)
  value += 2 if text.downcase.include?(word.downcase)
  value += 4 if text.match?(/given birth|male parent|same parents|retail sale|living quarters|receive education|licensed medical|take in solid food|joy or pleasure|first meal|natural stream|fixed wing|skeleton/i)
  value += 3 if text.match?(/\b(person|child|parent|woman|man|food|meal|liquid|building|place|feeling|joy|object|dwelling)\b/i)
  value += 2 if text.length.between?(20, 150)
  value += 1 if meaning["example"]
  value -= 2 if text.length > 200
  value
end

def clean(text)
  gloss = text.to_s.gsub(/\s+/, " ").strip
  gloss = gloss.sub(/\Ato /i, "") if gloss.match?(/\Ato /i)
  return nil if gloss.empty? || gloss.length < 3
  return nil if gloss.match?(/\[Obs\.\]|\bthou\b|\bthee\b/i)
  if gloss.length > 240
    cut = gloss[0, 240]
    space = cut.rindex(" ")
    gloss = space && space > 80 ? cut[0, space] : cut
  end
  gloss = gloss[0].upcase + gloss[1..]
  gloss.end_with?(".", "!", "?") ? gloss : "#{gloss}."
end

data = JSON.parse(File.read(VOCAB))
need = {}
data["words"].each { |item| need[item["word"].downcase] = true }

found = {}
Dir["#{DICT_DIR}/*.json"].each do |path|
  JSON.parse(File.read(path)).each do |key, entry|
    name = key.to_s.downcase
    next unless need[name]

    found[name] ||= { "meanings" => [] }
    (entry["meanings"] || []).each do |meaning|
      defs = found[name]["meanings"]
      defs << meaning unless defs.any? { |old| old["def"] == meaning["def"] }
    end
  end
end

filled = 0
missed = 0
data["words"].each do |item|
  entry = found[item["word"].downcase]
  if entry.nil?
    missed += 1
    next
  end
  meanings = entry["meanings"] || []
  pos = item["partOfSpeech"].to_s
  matches = meanings.select { |meaning| meaning["speech_part"] == pos }
  matches = meanings if matches.empty? && %w[phrase phrasal_verb].include?(pos)
  best = matches.max_by { |meaning| score(meaning, item["word"]) }
  best_score = best ? score(best, item["word"]) : -100
  if best.nil? || best_score < 2
    item.delete("meaningEn")
    missed += 1
    next
  end
  gloss = clean(best["def"])
  if gloss.nil? || gloss.length > 255
    item.delete("meaningEn")
    missed += 1
    next
  end
  item["meaningEn"] = gloss
  filled += 1
end

File.write(VOCAB, JSON.pretty_generate(data) + "\n")
puts "filled=#{filled} missed=#{missed} words=#{data["words"].size}"
%w[bone mother father shop book water eat happy school friend house river airplane breakfast brother orchard].each do |name|
  word = data["words"].find { |item| item["word"] == name }
  puts "#{name}: #{word ? word["meaningEn"] : "ABSENT"}"
end
