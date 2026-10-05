import { Module } from "@nestjs/common";
import { EnglishAuthModule } from "../auth/english-auth.module";
import { EnglishDictationController } from "./english-dictation.controller";
import { EnglishDictationService } from "./english-dictation.service";

@Module({
  imports: [EnglishAuthModule],
  controllers: [EnglishDictationController],
  providers: [EnglishDictationService],
})
export class EnglishDictationModule {}
