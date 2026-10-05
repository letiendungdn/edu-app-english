import { Module } from "@nestjs/common";
import { EnglishAuthModule } from "../auth/english-auth.module";
import { EnglishListeningController } from "./english-listening.controller";
import { EnglishListeningService } from "./english-listening.service";

@Module({
  imports: [EnglishAuthModule],
  controllers: [EnglishListeningController],
  providers: [EnglishListeningService],
})
export class EnglishListeningModule {}
