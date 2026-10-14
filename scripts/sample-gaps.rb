# frozen_string_literal: true

require "json"

vocab = JSON.parse(File.read("backend/src/main/resources/content/vocab.json"))
need = {}
vocab["words"].each do |w|
  need[w["word"].downcase] = w if w["exampleEn"].to_s.strip.empty?
end

wiki = Hash.new { |h, k| h[k] = [] }
File.foreach("/tmp/wiki-examples.tsv") do |line|
  word, ex = line.chomp.split("\t", 2)
  next unless word && ex && need.key?(word.downcase)
  wiki[word.downcase] << ex
end

shown = 0
wiki.each do |word, examples|
  puts "#{word}: #{examples.first[0, 160]}"
  shown += 1
  break if shown == 20
end
puts "---"
ipa = {}
File.foreach("/tmp/en_US_ipa.txt") do |line|
  word, pron = line.chomp.split("\t", 2)
  next unless word && pron
  ipa[word.downcase] = true
end
missing = vocab["words"].select { |w| w["phonetic"].to_s.strip.empty? }
missing.each do |w|
  tokens = w["word"].downcase.gsub(/[^a-z '\-]/, "").split(/[\s\-]+/).reject(&:empty?)
  next if tokens.any? && tokens.all? { |t| ipa.key?(t) }
  puts "IPA #{w["word"]}"
end
