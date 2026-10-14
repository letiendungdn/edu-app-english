# frozen_string_literal: true

require "json"

vocab = JSON.parse(File.read("backend/src/main/resources/content/vocab.json"))
need = vocab["words"].select { |w| w["exampleEn"].to_s.strip.empty? }
puts "need=#{need.size}"

wiki = Hash.new { |h, k| h[k] = [] }
if File.exist?("/tmp/wiki-examples.tsv")
  File.foreach("/tmp/wiki-examples.tsv") do |line|
    word, ex = line.chomp.split("\t", 2)
    next if word.nil? || ex.nil?
    wiki[word.downcase] << ex
  end
end
puts "wiki_words=#{wiki.size}"
hit = need.count { |w| wiki.key?(w["word"].downcase) }
puts "need_with_any_wiki=#{hit}"

ipa = {}
if File.exist?("/tmp/en_US_ipa.txt")
  File.foreach("/tmp/en_US_ipa.txt") do |line|
    word, pron = line.chomp.split("\t", 2)
    next unless word && pron
    ipa[word.downcase] = pron.split(",").first.to_s.strip
  end
end
puts "ipa_dict=#{ipa.size}"

noipa = vocab["words"].select { |w| w["phonetic"].to_s.strip.empty? }
puts "noipa=#{noipa.size}"
full = 0
part = 0
none = 0
samples = []
noipa.each do |w|
  tokens = w["word"].downcase.gsub(/[^a-z '\-]/, "").split(/[\s\-]+/).reject(&:empty?)
  known = tokens.count { |t| ipa.key?(t) }
  if tokens.any? && known == tokens.size
    full += 1
  elsif known.positive?
    part += 1
    samples << w["word"] if samples.size < 8
  else
    none += 1
    samples << "NONE #{w["word"]}" if samples.size < 15
  end
end
puts "ipa_full_phrase=#{full} partial=#{part} none=#{none}"
puts samples.join("\n")
