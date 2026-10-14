# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

GROUPS = {
  "My Daily Routine" => {
    "type" => "MULTIPLE_CHOICE_MULTI",
    "instruction" => "Choose TWO letters, A-E.",
    "questions" => [
      {
        "prompt" => "Which TWO things does Lan do after school?",
        "answers" => ["A", "C"],
        "evidence" => "I do my homework and then I watch TV. I read a book before I sleep.",
        "options" => [
          { "key" => "A", "text" => "does her homework" },
          { "key" => "B", "text" => "plays football" },
          { "key" => "C", "text" => "reads a book" },
          { "key" => "D", "text" => "cooks breakfast" },
          { "key" => "E", "text" => "takes the bus" }
        ]
      }
    ]
  },
  "A Saturday Market" => {
    "type" => "MULTIPLE_CHOICE_MULTI",
    "instruction" => "Choose TWO letters, A-E.",
    "questions" => [
      {
        "prompt" => "Which TWO changes are planned for next Saturday?",
        "answers" => ["A", "D"],
        "evidence" => "the third row will close; hot drinks will stop at noon",
        "options" => [
          { "key" => "A", "text" => "The third row will close." },
          { "key" => "B", "text" => "The market will open at night." },
          { "key" => "C", "text" => "Mai will accept cards." },
          { "key" => "D", "text" => "Hot drinks will stop at noon." },
          { "key" => "E", "text" => "The car park will be free." }
        ]
      }
    ]
  },
  "The School Garden Project" => {
    "type" => "MULTIPLE_CHOICE_MULTI",
    "instruction" => "Choose TWO letters, A-E.",
    "questions" => [
      {
        "prompt" => "Which TWO results of the garden are mentioned?",
        "answers" => ["B", "E"],
        "evidence" => "68% said they had tried a vegetable; The school kitchen takes herbs and tomatoes",
        "options" => [
          { "key" => "A", "text" => "The garden feeds every student." },
          { "key" => "B", "text" => "Most surveyed students tried a new vegetable." },
          { "key" => "C", "text" => "Mr Cole teaches science in the garden." },
          { "key" => "D", "text" => "Every crop failed in 2021." },
          { "key" => "E", "text" => "The kitchen uses herbs and tomatoes." }
        ]
      }
    ]
  },
  "Westbrook Park" => {
    "type" => "MULTIPLE_CHOICE_MULTI",
    "instruction" => "Choose TWO letters, A-E.",
    "questions" => [
      {
        "prompt" => "Which TWO rules does the park state?",
        "answers" => ["A", "C"],
        "evidence" => "Boats are not allowed. Dogs are not allowed in the playground.",
        "options" => [
          { "key" => "A", "text" => "Boats are not allowed on the lake." },
          { "key" => "B", "text" => "The cafe closes at 9 p.m." },
          { "key" => "C", "text" => "Dogs are not allowed in the playground." },
          { "key" => "D", "text" => "The main gate is on the south side." },
          { "key" => "E", "text" => "Dogs may run free beside the lake." }
        ]
      }
    ]
  }
}.freeze

data = JSON.parse(File.read(PATH))
added = 0
GROUPS.each do |title, group|
  passage = data["passages"].find { |item| item["title"] == title }
  raise "missing #{title}" unless passage

  prompts = passage["groups"].flat_map { |item| item["questions"].map { |q| q["prompt"] } }
  next if prompts.include?(group["questions"][0]["prompt"])

  number = passage["groups"].flat_map { |item| item["questions"].map { |q| q["number"].to_i } }.max.to_i + 1
  group["questions"][0]["number"] = number
  passage["groups"] << group
  added += 1
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "added=#{added}"
