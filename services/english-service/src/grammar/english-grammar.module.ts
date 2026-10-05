import { Module } from "@nestjs/common";
import { EnglishGrammarController } from "./english-grammar.controller";
import { EnglishGrammarService } from "./english-grammar.service";

@Module({
  controllers: [EnglishGrammarController],
  providers: [EnglishGrammarService],
})
export class EnglishGrammarModule {}
