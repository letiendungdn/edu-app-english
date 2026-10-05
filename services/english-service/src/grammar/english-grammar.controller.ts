import { Controller, Get, Param, ParseIntPipe, Query } from "@nestjs/common";
import { Public, RawResponse } from "@app/common";
import { EnglishGrammarService } from "./english-grammar.service";

@Public()
@RawResponse()
@Controller("api/english/grammar")
export class EnglishGrammarController {
  constructor(private readonly grammarService: EnglishGrammarService) {}

  @Get()
  listTopics(@Query("level") level: string | undefined) {
    return this.grammarService.listTopics(level);
  }

  @Get(":topicId")
  getTopic(@Param("topicId", ParseIntPipe) topicId: number) {
    return this.grammarService.getTopic(topicId);
  }
}
