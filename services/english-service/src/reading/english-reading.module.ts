import { Module } from "@nestjs/common";
import { EnglishAuthModule } from "../auth/english-auth.module";
import { EnglishReadingController } from "./english-reading.controller";
import { EnglishReadingService } from "./english-reading.service";

@Module({
  imports: [EnglishAuthModule],
  controllers: [EnglishReadingController],
  providers: [EnglishReadingService],
})
export class EnglishReadingModule {}
