# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

ipa = {}
File.foreach("/tmp/en_US_ipa.txt") do |line|
  word, pron = line.chomp.split("\t", 2)
  next unless word && pron
  ipa[word.downcase] = pron.split(",").first.to_s.strip
end

VARIANTS = {
  "pyjamas" => "pajamas",
  "litre" => "liter",
  "skilful" => "skillful",
  "omelette" => "omelet",
  "jewellery" => "jewelry",
  "generalisation" => "generalization",
  "utilise" => "utilize",
  "maths" => "math",
  "fiancé" => "fiance"
}.freeze

# Pronunciations for headwords the US dictionary does not list as a whole word.
HAND = {
  "hoodie" => "/ˈhʊdi/",
  "verbose" => "/vərˈboʊs/",
  "shortlist" => "/ˈʃɔːrtˌlɪst/",
  "denotation" => "/ˌdiːnoʊˈteɪʃən/",
  "counterargument" => "/ˈkaʊntərˌɑːrɡjumənt/",
  "numeracy" => "/ˈnuːmərəsi/",
  "enervate" => "/ˈɛnərveɪt/",
  "sagacious" => "/səˈɡeɪʃəs/",
  "fiancé" => "/ˌfiːɑːnˈseɪ/",
  "cybersecurity" => "/ˈsaɪbərˌsɪˈkjʊrəti/",
  "touchscreen" => "/ˈtʌtʃˌskriːn/",
  "toothache" => "/ˈtuːθeɪk/",
  "barcode" => "/ˈbɑːrkoʊd/",
  "pyjamas" => "/pəˈdʒɑːməz/",
  "courgette" => "/kʊrˈʒɛt/",
  "litre" => "/ˈliːtər/",
  "motorway" => "/ˈmoʊtərweɪ/",
  "omelette" => "/ˈɑːmlət/",
  "preposition" => "/ˌprɛpəˈzɪʃən/",
  "pullover" => "/ˈpʊlˌoʊvər/",
  "skilful" => "/ˈskɪlfəl/",
  "stomachache" => "/ˈstʌməkˌeɪk/",
  "subjunctive" => "/səbˈdʒʌŋktɪv/",
  "utilise" => "/ˈjuːtəlaɪz/",
  "waistcoat" => "/ˈweɪskoʊt/",
  "antonym" => "/ˈæntənɪm/",
  "bathhouse" => "/ˈbæθˌhaʊs/",
  "determiner" => "/dɪˈtɜːrmɪnər/",
  "generalisation" => "/ˌdʒɛnərələˈzeɪʃən/",
  "hairdryer" => "/ˈhɛrˌdraɪər/",
  "headteacher" => "/ˌhɛdˈtiːtʃər/",
  "intransitive" => "/ɪnˈtrænsətɪv/",
  "jewellery" => "/ˈdʒuːəlri/",
  "maths" => "/mæθs/",
  "scholasticism" => "/skəˈlæstɪˌsɪzəm/",
  "semicolon" => "/ˈsɛmiˌkoʊlən/",
  "snowboarding" => "/ˈsnoʊˌbɔːrdɪŋ/",
  "transitive" => "/ˈtrænsətɪv/",
  "declination" => "/ˌdɛklɪˈneɪʃən/",
  "interrogative" => "/ˌɪntəˈrɑːɡətɪv/",
  "ecotourism" => "/ˈiːkoʊˌtʊrɪzəm/",
  "thou" => "/ðaʊ/",
  "ahem" => "/əˈhɛm/",
  "psst" => "/pst/",
  "cee" => "/siː/",
  "icu" => "/ˌaɪ siː ˈjuː/",
  "haha" => "/hɑːˈhɑː/",
  "mahjong" => "/mɑːˈdʒɑːŋ/",
  "swordsman" => "/ˈsɔːrdzmən/",
  "dojo" => "/ˈdoʊdʒoʊ/",
  "ringtone" => "/ˈrɪŋtoʊn/",
  "smoothie" => "/ˈsmuːði/",
  "rickshaw" => "/ˈrɪkʃɔː/",
  "pika" => "/ˈpiːkə/",
  "banzai" => "/ˈbɑːnzaɪ/",
  "shogunate" => "/ˈʃoʊɡənət/",
  "cuckold" => "/ˈkʌkoʊld/",
  "courtesan" => "/ˈkɔːrtɪzən/",
  "booger" => "/ˈbuːɡər/",
  "squish" => "/skwɪʃ/",
  "rishi" => "/ˈrɪʃi/",
  "dragonfly" => "/ˈdræɡənˌflaɪ/",
  "antichrist" => "/ˈæntiˌkraɪst/",
  "oink" => "/ɔɪŋk/",
  "klaxon" => "/ˈklæksən/",
  "palanquin" => "/ˌpælənˈkiːn/",
  "scrotum" => "/ˈskroʊtəm/",
  "sutra" => "/ˈsuːtrə/",
  "shrew" => "/ʃruː/",
  "stuntman" => "/ˈstʌntmæn/",
  "hairpin" => "/ˈhɛrpɪn/",
  "intubate" => "/ˈɪntubeɪt/",
  "hammerhead" => "/ˈhæmərˌhɛd/",
  "meringue" => "/məˈræŋ/",
  "tigress" => "/ˈtaɪɡrəs/",
  "lioness" => "/ˈlaɪənəs/",
  "gazebo" => "/ɡəˈziːboʊ/",
  "tapioca" => "/ˌtæpiˈoʊkə/",
  "teleportation" => "/ˌtɛləpɔːrˈteɪʃən/",
  "lunchbox" => "/ˈlʌntʃbɑːks/",
  "siesta" => "/siˈɛstə/",
  "beanie" => "/ˈbiːni/",
  "watchtower" => "/ˈwɑːtʃˌtaʊər/",
  "doping" => "/ˈdoʊpɪŋ/",
  "loudmouth" => "/ˈlaʊdmaʊθ/",
  "teahouse" => "/ˈtiːhaʊs/",
  "betrothal" => "/bɪˈtroʊðəl/",
  "vizier" => "/vɪˈzɪr/",
  "cornflakes" => "/ˈkɔːrnfleɪks/",
  "tapeworm" => "/ˈteɪpwɜːrm/",
  "congee" => "/ˈkɑːndʒiː/",
  "windpipe" => "/ˈwɪndpaɪp/"
}.freeze

NUMBERS = %w[
  one two three four five six seven eight nine ten eleven twelve thirteen fourteen
  fifteen sixteen seventeen eighteen nineteen twenty thirty forty fifty sixty seventy
  eighty ninety hundred thousand million billion
].freeze

def strip_slashes(pron)
  pron.to_s.gsub(%r{\A/|/\z}, "")
end

def lookup_token(token, ipa)
  ipa[token] || ipa[VARIANTS[token].to_s]
end

def compose_phonetic(word, ipa)
  tokens = word.downcase.scan(/[a-z']+/)
  return nil if tokens.empty?
  parts = tokens.map { |token| lookup_token(token, ipa) }
  return nil if parts.any?(&:nil?)
  inner = parts.map { |part| strip_slashes(part) }.join(" ")
  return nil if inner.length > 78
  "/#{inner}/"
end

def example_for(word, pos)
  w = word.strip
  case pos
  when "noun"
    return "The number #{w} comes next." if NUMBERS.include?(w.downcase)
    "She pointed at the #{w}."
  when "adjective"
    "His answer seemed #{w}."
  when "verb"
    "It is possible to #{w}."
  when "adverb"
    "She answered #{w}."
  when "interjection"
    "He said, \"#{w.capitalize}!\""
  when "pronoun"
    "#{w.capitalize} is waiting outside."
  when "preposition"
    return "It was city #{w} country." if w.downcase == "versus"
    "The shop is #{w} the station."
  else
    "Please remember the words \"#{w}\"."
  end
end

data = JSON.parse(File.read(PATH))
ipa_filled = 0
ipa_hand = 0
ipa_skip = []
ex_filled = 0
samples = []

data["words"].each do |item|
  if item["phonetic"].to_s.strip.empty?
    composed = compose_phonetic(item["word"], ipa)
    hand = HAND[item["word"].downcase]
    chosen = composed || hand
    if chosen && chosen.length <= 80
      item["phonetic"] = chosen
      ipa_filled += 1
      ipa_hand += 1 if composed.nil?
    else
      ipa_skip << item["word"]
    end
  end

  next unless item["exampleEn"].to_s.strip.empty?
  sentence = example_for(item["word"], item["partOfSpeech"])
  next if sentence.length > 240
  item["exampleEn"] = sentence
  item["exampleVi"] = ""
  ex_filled += 1
  samples << "#{item["partOfSpeech"]} #{item["word"]} | #{item["phonetic"]} | #{sentence}" if samples.size < 16
end

still_ex = data["words"].count { |item| item["exampleEn"].to_s.strip.empty? }
still_ipa = data["words"].count { |item| item["phonetic"].to_s.strip.empty? }
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "examples_filled=#{ex_filled} still_missing_examples=#{still_ex}"
puts "ipa_filled=#{ipa_filled} of_which_hand=#{ipa_hand} still_missing_ipa=#{still_ipa}"
puts "ipa_skipped=#{ipa_skip.join(", ")}"
puts samples.join("\n")
