import { Module } from "@nestjs/common";
import { EnglishAuthModule } from "../auth/english-auth.module";
import { EnglishVocabController } from "./english-vocab.controller";
import { EnglishVocabService } from "./english-vocab.service";

@Module({
  imports: [EnglishAuthModule],
  controllers: [EnglishVocabController],
  providers: [EnglishVocabService],
})
export class EnglishVocabModule {}
