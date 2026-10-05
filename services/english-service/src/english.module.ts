import { Module } from "@nestjs/common";
import { EnglishPrismaModule } from "@app/prisma-english";
import { EnglishAnalyticsModule } from "./analytics/english-analytics.module";
import { EnglishAuthModule } from "./auth/english-auth.module";
import { EnglishDictationModule } from "./dictation/english-dictation.module";
import { EnglishGrammarModule } from "./grammar/english-grammar.module";
import { EnglishListeningModule } from "./listening/english-listening.module";
import { EnglishReadingModule } from "./reading/english-reading.module";
import { EnglishVocabModule } from "./vocab/english-vocab.module";

@Module({
  imports: [
    EnglishPrismaModule,
    EnglishAuthModule,
    EnglishVocabModule,
    EnglishGrammarModule,
    EnglishReadingModule,
    EnglishListeningModule,
    EnglishDictationModule,
    EnglishAnalyticsModule,
  ],
  exports: [
    EnglishAuthModule,
    EnglishVocabModule,
    EnglishGrammarModule,
    EnglishReadingModule,
    EnglishListeningModule,
    EnglishDictationModule,
    EnglishAnalyticsModule,
  ],
})
export class EnglishModule {}
